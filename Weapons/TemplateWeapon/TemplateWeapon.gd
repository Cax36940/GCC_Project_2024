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
	error_margin = 200 # 100 means that error margins perfectly match or eigths of beats, 
	# so 200 here means that you can't offbeat (200 is a eigth of beat)
	
	super() # very important to call super() here (and after setting pattern)
	# as some setup has to be done by the base class

func _process(delta):
	super(delta) # super() is also mandatory here since it processes inputs
	# but if you don't do anything in process, you can also just get rid of the method


func _on_input(error):
	super(error) # does not do anything particular (can be removed)
	if error == Timeline.OFFBEAT:
		_restart_pattern()
		return
	
	var error_ratio = abs(error) / error_margin
	if current_beat < 2:
		if error_ratio > .7:
			do_attack(base_attack_power[current_beat] * error_multiplier)
		elif error_ratio < .15:
			do_attack(base_attack_power[current_beat] * perfect_multiplier)
		else:
			do_attack(base_attack_power[current_beat])
	elif current_beat < 5:
		valid_charges += 1
	else:
		if error_ratio > .8:
			do_attack((base_attack_power[2] + charge_bonus_power * valid_charges) * error_multiplier)
		elif error_ratio < .1:
			do_attack((base_attack_power[2] + charge_bonus_power * valid_charges) * perfect_multiplier)
		else:
			do_attack(base_attack_power[2] + charge_bonus_power * valid_charges)
	current_beat += 1


func _get_miss_input():
	# super() if you want to simply reset the pattern at the first miss
	if current_beat < 2 || current_beat == 5:
		print("missed crucial input: restart")
		_restart_pattern()
	else:
		print("missed charge")
		current_beat += 1


func _restart_pattern():
	super() # needed to communicate restart to timeline
	current_beat = 0
	valid_charges = 0


func do_attack(damage):
	print("done %s dmg!" % [damage])
	do_animation(current_beat)


func do_animation(state):
	print("super mega giga cool attack animation state %s" % [state])
