extends CanvasLayer

const TOTAL_GIFTS = 3
const HONK_RESET = 3
const HONKS_REQUIRED = 15

@onready var candle_mark: AnimatedSprite2D = $ChecklistSprite/CandleMarkSprite
@onready var gift_mark: AnimatedSprite2D = $ChecklistSprite/GiftMarkSprite
@onready var song_mark: AnimatedSprite2D = $ChecklistSprite/SongMarkSprite
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var gift_count = 0

var honked = false
var honk_count = 0
var honk_cooldown = 0

var list_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_show_checklist()
	
	pass # Replace with function body.

func _check(check_mark: AnimatedSprite2D):

	await get_tree().create_timer(1.0).timeout

	var was_hidden = false
	
	if not list_shown:
		_show_checklist()
		was_hidden = true
	
	await get_tree().create_timer(1.0).timeout
	check_mark.play("checked")
	audio_player.play()
	
	await get_tree().create_timer(3.0).timeout
	if was_hidden and list_shown:
		_hide_checklist()

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
	if honk_count == HONKS_REQUIRED and not song_mark.animation == "checked":
		_check(song_mark)
	
func _on_gift_opened():
	gift_count += 1
	if gift_count == TOTAL_GIFTS and not gift_mark.animation == "checked": 
		_check(gift_mark)
		

func _on_cake_blown_out():
	if not candle_mark.animation == "checked":
		_check(candle_mark)
	pass # Replace with function body.
