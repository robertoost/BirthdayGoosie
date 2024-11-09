extends Node2D

@onready var gift_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D
signal opened

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_open_trigger_area_body_entered(body: Node2D):
	print(body.name)
	if body.name == "Goose":
		if not gift_sprite.animation == "opened":
			gift_sprite.play("opened")
			opened.emit()
		audio_player.play()
	pass # Replace with function body.
