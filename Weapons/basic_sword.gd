extends Node2D
#extends Weapons(subclass with set_degat and stuff)

@onready var damage : int = 0
@onready var tempo : Array[bool] = []
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var node_sprite = $Sprite 

signal attack_finished

enum STATES {
	IDLE = 0,
	ATTACK = 1
}

var current_state : int = STATES.IDLE

func _ready() -> void:
	set_degat(10)
	set_tempo([1,1])
	animation_tree.active = true
	rotation = 0
	return

func set_degat(damage : int) -> void:
	self.damage = damage
	#Signal doing attack ???
	return

func set_tempo(tempo : Array[bool]) -> void:
	self.tempo = tempo
	return

func _input(event):
	if (event is InputEventKey):
		if (event.is_action_pressed("ui_accept")):
			var angle = node_sprite.rotation
			if (angle < 2.3) and (angle > 2.1):
				state_machine.travel("swing_left")
			if (angle > -2.3) and (angle < -2.1):
				state_machine.travel("swing_right")

func _process(delta : float) -> void:
	#Player or weapon receives signal for attack
	return
