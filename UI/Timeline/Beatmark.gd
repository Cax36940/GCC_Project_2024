extends Node2D


var speed: float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.x -= speed * delta
	if global_position.x < -100:
		queue_free()


func set_speed(s):
	speed = s
