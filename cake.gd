extends CharacterBody2D

signal blown_out

@onready var cake_flames = $CakeFlames
@onready var woosh_player = $AudioStreamPlayer2D
var _blown_out = false

const HONKS_REQUIRED = 3
const HONK_TIMEOUT = 1
var honks = 0
var honk_timer = 0
var honking = false
# Called when the node enters the scene tree for the first time.
func _ready():
	cake_flames.play("default")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _blown_out or not honking:
		return
		
	honk_timer += delta
	if honk_timer >= HONK_TIMEOUT:
		honk_timer = 0
		honks = 0
		cake_flames.play("default")
	pass

func _blow_out_flames():
	if _blown_out:
		return
	honking = true
	honks += 1
	cake_flames.play("blown_out")
	if honks >= HONKS_REQUIRED:
		woosh_player.play()
		cake_flames.animation_finished.connect(_delete_flames)
		blown_out.emit()
		_blown_out = true

func _delete_flames():
	cake_flames.call_deferred("queue_free")


func _on_area_2d_area_entered(area : Area2D):
	if area.name == "HonkArea":
		var goose: Goose = area.get_parent().get_parent().get_parent()
		
		goose.honked.connect(_blow_out_flames)


func _on_flame_area_area_exited(area):
	if area.name == "HonkArea":
		var goose: Goose = area.get_parent().get_parent().get_parent()
		
		goose.honked.disconnect(_blow_out_flames)
