extends CanvasLayer

var game_running = false
var game_over = false
signal game_started
signal game_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartMusic.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not game_running and Input.is_action_just_pressed("honk"):
		$AudioStreamPlayer.play()
		$StartText.visible = false
		$ControlHelpText.visible = false
		$EndInstructions.visible = false
		$Credits.visible = false

		_open_curtain()
		game_started.emit()
		game_running = true
		await get_tree().create_timer(0.5).timeout
		$OpenCurtainMusic.play()
		
	elif game_over: 
		if Input.is_action_just_pressed("honk"):
			$AudioStreamPlayer.play()
			$CloseUpGoose.play("honk")
			$CloseUpGoose.connect("animation_finished", _close_goose_mouth)
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit() 
	elif Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	pass

func _close_goose_mouth():
	$CloseUpGoose.disconnect("animation_finished", _close_goose_mouth)
	$CloseUpGoose.play("default")

func _open_curtain():
	$OpenCurtainNoise.play()
	$AnimationPlayer.play("curtain_rise")

func _close_curtain():
	$OpenCurtainNoise.play()
	$AnimationPlayer.play("curtain_fall")

func _on_checklist_finished():
	$CloseCurtainMusic.play()
	_close_curtain()
	await get_tree().create_timer(1.0).timeout
	game_ended.emit()
	game_over = true
	$EndText.visible = true
	$EndInstructions.visible = true
	$Credits.visible = true
	$CloseUpGoose.play("default")
	$AnimationPlayer.play("goose_show")
	pass # Replace with function body.


func _on_background_sounds_finished():
	$BackgroundSounds.play()
	pass # Replace with function body.
