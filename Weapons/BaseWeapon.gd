extends Node
class_name BaseWeapon

enum beats {
	FULL = 1,
	HALF = 2,
	QUARTER = 4,
	EIGTH = 8,
	MAX_VALUE = 8
}

var timeline : Timeline
@export var pattern : Array[int]
@export var minimal_beat = beats.HALF

@export var error_margin = 3.5 # 350%

# Called when the node enters the scene tree for the first time.
func _ready():
	timeline = $"../Timeline"
	compute_real_pattern()
	setup()
	

func setup():
	timeline.set_max_error(error_margin)
	timeline.set_pattern(pattern)
	timeline.await_pattern()
	timeline.input_missed.connect(_get_miss_input)

func compute_real_pattern():
	var current_beat = minimal_beat
	while current_beat != beats.MAX_VALUE:
		for i in range(pattern.size(), 0, -1):
			pattern.insert(i, 0)
		current_beat = (current_beat * 2) as beats
	while pattern.size() % beats.MAX_VALUE != 0:
		pattern.append(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var error = 0.0
	if Input.is_action_just_pressed("attack"):
		error = timeline.get_input_error()
		_on_input(error)


func _on_input(_error):
	pass


func _get_miss_input():
	_restart_pattern()


func _restart_pattern():
	timeline.await_pattern()
