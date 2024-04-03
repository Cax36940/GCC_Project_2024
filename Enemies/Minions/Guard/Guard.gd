extends CharacterBody2D
@onready var animations = $AnimationPlayer
@onready var attack_sound = $AttackSound
@export var GuardSpear = preload("res://Enemies/Minions/Guard/GuardSpear.tscn").instantiate()

# Attaque à portée du joueur
# Indique sa future attaque
# Se rapproche du joueur
# A un pattern
# Pas de dégât de contact
# Se prend les projectiles

@export var HP: int = 20
@export var ATTACK_RANGE: int = 50
@export var MOVE_SPEED: int = 100
@export var ATTACK_PREP_TIME: float = 1.

enum state_enum {
	MOVING,
	PREP_ATTACK,
	ATTACK
}
@export var state: state_enum = state_enum.MOVING

var diff:Vector2
func get_player_pos():
	# TODO
	return Vector2(0, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	#animations.play("idle")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	diff = get_player_pos()-position
	if state == state_enum.MOVING:
		velocity = diff.normalized() * MOVE_SPEED
		if diff.length_squared()<ATTACK_RANGE:
			state = state_enum.PREP_ATTACK
		move_and_slide()
		# Activate prep time
	elif state == state_enum.PREP_ATTACK:
		state = state_enum.ATTACK
		pass
	else: # ATTACK
		attack_sound.play()
		attack()
		state = state_enum.MOVING
		pass
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if "attack" in collider.name:
			
			#await _on_animation_player_animation_finished("die")
			HP -= collider.attack
			if HP<=0:
				queue_free()


func attack():
	owner.add_child(GuardSpear)
	GuardSpear.transform = $SpearEdge.global_transform
