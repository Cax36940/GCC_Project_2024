extends CharacterBody2D
@onready var animations = $AnimationPlayer
@onready var attack_sound = $AttackSound
@export var GuardSpear = preload("res://Enemies/Minions/Guard/GuardSpear.tscn")

# Attaque à portée du joueur
# Indique sa future attaque
# Se rapproche du joueur
# A un pattern
# Pas de dégât de contact
# Se prend les projectiles

@export var HP: int = 20
@export var ATTACK_RANGE: int = 50
@export var MOVE_SPEED: int = 100
@export var ATTACK_PAUSE: int = 2000
@export var ATTACK_PREP_TIME: int = 1000
@export var ATTACK_TIME: int = 1000
var begin_action: float
enum state_enum {
	MOVING,
	PREP_ATTACK,
	ATTACK
}
var state: state_enum = state_enum.MOVING

var diff:Vector2
func get_player_pos():
	# TODO
	return Vector2(600, 300)


# Called when the node enters the scene tree for the first time.
func _ready():
	#animations.play("idle")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	diff = get_player_pos()-position
	if state == state_enum.MOVING:
		velocity = diff.normalized() * MOVE_SPEED
		if diff.length_squared()<ATTACK_RANGE: # 2 if clauses to avoid instabilities in position
			if Time.get_ticks_msec()-begin_action>ATTACK_PAUSE:
				state = state_enum.PREP_ATTACK
				begin_action = Time.get_ticks_msec()
		else:
			move_and_slide()
		# Activate prep time
	elif state == state_enum.PREP_ATTACK:
		if Time.get_ticks_msec()-begin_action>ATTACK_PREP_TIME:
			state = state_enum.ATTACK
			begin_action = Time.get_ticks_msec()
			attack_sound.play()
			attack()
 
	else: # ATTACK
		if Time.get_ticks_msec()-begin_action>ATTACK_TIME:
			state = state_enum.ATTACK
			begin_action = Time.get_ticks_msec()
			state = state_enum.MOVING
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if "attack" in collider.name: # Player attack
			
			#await _on_animation_player_animation_finished("die")
			HP -= collider.attack
			if HP<=0:
				queue_free()


func attack():
	var spear = GuardSpear.instantiate()
	add_child(spear) # Replace self for owner if it is a projectile to make it independant from the ennemy's movements.
	spear.transform = $SpearEdge.transform
