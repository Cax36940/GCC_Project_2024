extends Node2D


const SHOOT_SCENE : Resource = preload("../Shoot.tscn")
const SPRAY_ANGLE : float = 0.5
const RELOAD_TIME : float = 0.2
#alled when the node enters the scene tree for the first time.
func _ready():
	shoot()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func shoot():
	await get_tree().create_timer(RELOAD_TIME).timeout
	var shoot = SHOOT_SCENE.instantiate()
	add_child(shoot)
	
	shoot = SHOOT_SCENE.instantiate()
	shoot.direction(-SPRAY_ANGLE)
	add_child(shoot)
	
	shoot = SHOOT_SCENE.instantiate()
	shoot.direction(SPRAY_ANGLE)
	add_child(shoot)
	shoot()
	
	
