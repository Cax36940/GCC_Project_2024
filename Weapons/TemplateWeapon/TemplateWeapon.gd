extends BaseWeapon

@export var base_attack_power = [40, 40, 80]
@export var charge_bonus_power = 20
@export var perfect_multiplier = 1.5
@export var error_multiplier = 0.75
var current_beat = 0
var valid_charges = 0


func _ready():
	minimal_beat = beats.QUARTER
	pattern = [1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1]
	super() # very important to call super() here as some setup has to be done by the base class

func _process(delta):
	super(delta) # super() is also mandatory here since it processes inputs


func _on_input(error):
	super(error) # does not do anything particular (can be removed)
	if error == Timeline.OFFBEAT:
		_restart_pattern()
		return
	
	if current_beat < 2:
		# TODO: add damage modulation based on error
		do_attack(base_attack_power[current_beat])
	elif current_beat < 5:
		valid_charges += 1
	else:
		# TODO: add damage modulation based on error
		do_attack(base_attack_power[2] + charge_bonus_power * valid_charges)
	current_beat += 1


func _get_miss_input():
	# super() if you want to simply reset the pattern at the first miss
	if current_beat < 2 || current_beat == 5:
		_restart_pattern()
	else:
		current_beat += 1


func _restart_pattern():
	super() # needed to communicate restart to timeline
	current_beat = 0


func do_attack(damage):
	print("done " + damage + " dmg!")
	do_animation(current_beat)


func do_animation(state):
	print("super mega giga cool attack animation")
