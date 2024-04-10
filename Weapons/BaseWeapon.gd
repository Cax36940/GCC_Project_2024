extends Node
class_name BaseWeapon

enum beats {
	FULL = 1,
	HALF = 2,
	QUARTER = 4,
	HEIGTH = 8,
	MAX_VALUE = 8
}

var timeline : Timeline
@export var pattern : Array[int]
@export var minimal_beat = beats.HALF

# Called when the node enters the scene tree for the first time.
func _ready():
	timeline = $"../Timeline"
	_compute_real_pattern()
	setup()
	

func setup():
	timeline.set_pattern(pattern)
	timeline.await_pattern()


func _compute_real_pattern():
	var current_beat = minimal_beat
	while current_beat != beats.MAX_VALUE:
		for i in range(pattern.size(), 0, -1):
			pattern.insert(i, 0)
		current_beat *= 2
	while pattern.size() % beats.MAX_VALUE != 0:
		pattern.append(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var error = 0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		error = timeline.get_input_error()


func get_miss_input():
	restart_pattern()


func restart_pattern():
	timeline.await_pattern()
