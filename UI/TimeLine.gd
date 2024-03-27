extends Node2D

const TIME: float = 3
const TOLERANCE: float = 0.05
var init_time

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_time():
	init_time = Time.get_ticks_msec()

func is_on_sub_time(division: int):
	return ((Time.get_ticks_msec()-init_time)/TIME)%division<TOLERANCE

func is_on_time():
	return is_on_sub_time(1)
