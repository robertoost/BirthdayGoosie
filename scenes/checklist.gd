extends CanvasLayer

const TOTAL_GIFTS = 3
const HONK_RESET = 3
const HONKS_REQUIRED = 15
const TOTAL_CHECKS = 3

@onready var candle_mark: AnimatedSprite2D = $ChecklistSprite/CandleMarkSprite
var candle_checked = false
@onready var gift_mark: AnimatedSprite2D = $ChecklistSprite/GiftMarkSprite
var gift_checked = false
@onready var song_mark: AnimatedSprite2D = $ChecklistSprite/SongMarkSprite
var song_checked = false

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var gift_count = 0

var honked = false
var honk_count = 0
var honk_cooldown = 0

var list_shown = false
var checks_done = 0

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	_show_checklist()
	
	pass # Replace with function body.

func _check(check_mark: AnimatedSprite2D):
	checks_done += 1
	var just_finished = checks_done == TOTAL_CHECKS
	await get_tree().create_timer(1.0).timeout

	var was_hidden = false
	
	if not list_shown:
		_show_checklist()
		was_hidden = true
	
	await get_tree().create_timer(1.0).timeout
	check_mark.play("checked")
	audio_player.play()
	
	if was_hidden and list_shown:
		await get_tree().create_timer(2.0).timeout

		_hide_checklist()

	await get_tree().create_timer(1.0).timeout
	
	# End the game if we're done.
	#
	if just_finished:
		finished.emit()
	

func _show_checklist():
	animation_player.play("show_checklist")
	list_shown = true

func _hide_checklist():
	animation_player.play("hide_checklist")
	list_shown = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if honked:
		honk_cooldown += delta
		if honk_cooldown > HONK_RESET:
			honk_count = 0
			honk_cooldown = 0
			honked = false
	
	if Input.is_action_just_pressed("checklist"):
		if list_shown:
			_hide_checklist()
		else:
			_show_checklist()
	
	pass
	
func _on_goose_honked():
	honked = true
	honk_cooldown = 0
	honk_count += 1
	if honk_count == HONKS_REQUIRED and not song_checked:
		song_checked = true
		_check(song_mark)
	
func _on_gift_opened():
	gift_count += 1
	if gift_count == TOTAL_GIFTS and not gift_checked: 
		gift_checked = true
		_check(gift_mark)
		

func _on_cake_blown_out():
	if not candle_checked:
		candle_checked = true
		_check(candle_mark)
	pass # Replace with function body.
