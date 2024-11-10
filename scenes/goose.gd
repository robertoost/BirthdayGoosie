class_name Goose 
extends CharacterBody2D

const SPEED = 800.0
const START_SPEED = 300.0
const SPEEDUP_TIME = 0.3
const JUMP_VELOCITY = -600.0

@onready var animation = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D
@onready var footstep_audio = $Footsteps
@onready var jump_animation = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D
@onready var flip_cam = $AnimatedSprite2D/FlipCam

signal honked

var current_speed = START_SPEED
var prev_horiz_dir = 0
var prev_vert_dir = 0
var speedup_timer = 0
var finish_frame = 0

var game_running = false

func _on_game_started():
	game_running = true

func _physics_process(delta: float) -> void:
	if not game_running:
		return
	
	if Input.is_action_just_pressed("honk"):
		audio.play(0)
		honked.emit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	var vert_direction := Input.get_axis("up", "down")
	
	
	# Turned around or just started moving, or just not moving
	var started_moving_horiz = (direction and prev_horiz_dir == 0)
	var started_moving_vert = (vert_direction and prev_vert_dir == 0)
	var started_moving = (started_moving_horiz and not vert_direction) or (started_moving_vert and not direction)
	var turned_horiz_around = prev_horiz_dir + direction == 0 and prev_horiz_dir != direction
	var turned_vert_around = prev_vert_dir + vert_direction == 0 and prev_vert_dir != vert_direction
		
	if started_moving or (turned_horiz_around and turned_vert_around):
		speedup_timer = 0
	if direction or vert_direction:
		speedup_timer += delta
		speedup_timer = minf(speedup_timer, SPEEDUP_TIME)
		var A = START_SPEED
		var B = SPEED - START_SPEED
		var C = speedup_timer / SPEEDUP_TIME
		current_speed = A + B * C
	
	
	var use_speed = 0.75 * current_speed if direction and vert_direction else current_speed
	
	_handle_animation(delta, direction, vert_direction)
	
	prev_horiz_dir = direction
	prev_vert_dir = vert_direction

	
	if vert_direction:
		velocity.y = vert_direction * use_speed
	else:
		velocity.y = move_toward(velocity.y, 0, use_speed)
	
	if direction:
		velocity.x = direction * use_speed
	else:
		velocity.x = move_toward(velocity.x, 0, use_speed)

	move_and_slide()

func _handle_animation(delta, direction, vert_direction):
	
	var animation_name = ""
	if audio.playing:
		animation_name = "honk_"
	
	# Try to finish the current frame before switching back to idle.
	#
	var was_walking = "walk" in animation.animation and not direction and not vert_direction
	if was_walking:
		if prev_horiz_dir or prev_vert_dir:
			finish_frame = animation.frame_progress
		else:
			finish_frame += delta * animation.speed_scale * 5
		if finish_frame >= 0.95:
			was_walking = false
			finish_frame = 0
			$Footsteps.play()
	else:
		finish_frame = 0
		
	var was_jumping = "jump" in animation.animation
	
	# Jump has first priority.
	#
	if Input.is_action_just_pressed("jump") and not jump_animation.is_playing():
		set_collision_mask_value(1, false)
		jump_animation.play("jump")
		$Flaps.play()
	elif jump_animation.is_playing():
		animation_name = animation_name + "jump"
		animation.play(animation_name)
		
	# Walking animation if we're moving or just finishing up.
	#
	elif direction or vert_direction or was_walking:
		
		animation_name = animation_name + "walk"
	
		# AnimatedSprite needs to sync frames and frame progress with honking variant
		# for smooth transitions.
		#
		var seek = "walk" in animation.animation and animation_name != animation.animation
		var frame_progress = animation.frame_progress
		var frame = animation.get_frame()
		
		animation.play(animation_name)
		
		# If we're switching to or from honking, continue animation progress.
		#
		if seek:
			animation.frame = frame
			animation.frame_progress = frame_progress
		
	else:
		animation_name = animation_name + "idle"
		animation.play(animation_name)
		
	if direction:
		animation.flip_h = direction == -1
		flip_cam.scale.x = direction
	
	# Land from the jump
	#
	if was_jumping and not "jump" in animation.animation:
		
		set_collision_layer_value(2, true)
		set_collision_mask_value(1, true)

		# Play landing noise.
		#	
		footstep_audio.play()
	else:
		set_collision_layer_value(2, false)



func _on_animated_sprite_2d_frame_changed():
	if not game_running:
		return
	if "walk" in animation.animation and animation.frame_progress == 0:
		match animation.frame:
			1, 3:
				if not footstep_audio.playing:
					footstep_audio.play()
				else:
					print("Prevented doubles!")


func _on_game_ended():
	game_running = false
	pass # Replace with function body.
