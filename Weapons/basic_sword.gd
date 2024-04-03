extends Node2D
#extends Weapons(subclass with set_degat and stuff)



@onready var damage : int = 0
@onready var tempo : Array[bool] = []
@onready var animation_player = $AnimationPlayer

signal attack_finished

enum STATES {
	IDLE ,
	ATTACK
}

var current_state = STATES.IDLE

func _ready() -> void:
	#Tempo set (dEMI_TEMPS, [1,1])
	set_degat(10)
	set_tempo([1,1])
	return

func set_degat(damage : int) -> void:
	self.damage = damage
	return

func set_tempo(tempo : Array[bool]) -> void:
	self.tempo = tempo
	return

func _process(delta) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		pass
	pass

