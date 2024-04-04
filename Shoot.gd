extends Node2D

const SPEED : float = 500.
var speed_vector_rotation : float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += delta * SPEED * Vector2.UP.rotated(speed_vector_rotation)
	#$Sprite.rotation += delta
	pass

func direction(rot : float):
	speed_vector_rotation = rot
	$Sprite.rotation += rot

func _on_hitbox_body_entered(body):
	queue_free()
	pass # Replace with function body.
