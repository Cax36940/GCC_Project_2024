extends CharacterBody2D

var init_time: int
@export var pre_attack_time:int = 1000
@export var attack_time:int = 1000

enum state_enum {
	PREP_ATTACK,
	ATTACK
}

var state: state_enum = state_enum.PREP_ATTACK

func _ready():
	$attack.visible = false
	$preattack.visible = true
	$CollisionShape2D.disabled = true
	init_time = Time.get_ticks_msec()

func _physics_process(_delta):
	if state == state_enum.PREP_ATTACK:
		if Time.get_ticks_msec()-init_time>pre_attack_time:
			state = state_enum.ATTACK
			$attack.visible = true
			$preattack.visible = false
			$CollisionShape2D.disabled = false
			init_time = Time.get_ticks_msec()
	else:
		if Time.get_ticks_msec()-init_time>attack_time:
			queue_free()
	

