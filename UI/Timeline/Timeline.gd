extends Node2D
class_name Timeline

const MAX_SUBDIV: int = 8 # Eighth of a beat
const OFFBEAT: float = INF


var total_time: float
var bpm: float = 120.0
var subdiv: int = 0 # updated each frame

var pattern = [0]
var received_pattern = [] # 1 when received correct input, 0 when wrong/no input
var max_error: float = 1.0 # 1.0 = 100% = 16th of a beat

const BEAT_REF_POS = 250
const NUM_BEAT_MARKS = 10
const WIDTH = 1152
const PADX = 50
const PADY = 60
const DIST_BEAT_MARKS = (WIDTH - 2*PADX) / NUM_BEAT_MARKS
var beatmark = load("res://UI/Timeline/Beatmark.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_time()
	var b = beatmark.instantiate()
	b.set_speed(0)
	b.global_position = Vector2(BEAT_REF_POS, PADY)
	b.rotation = PI
	add_child(b)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	total_time += delta
	var prev_subdiv = subdiv
	subdiv = get_subdiv_at_time()
	if prev_subdiv / MAX_SUBDIV != subdiv / MAX_SUBDIV:
		make_new_beatmark()
	elif prev_subdiv * 2 / MAX_SUBDIV != subdiv * 2 / MAX_SUBDIV and subdiv > MAX_SUBDIV:
		make_new_beatmark(1)
	check_input_missed()


func reset_time(t=0.0):
	total_time = t


func set_pattern(p):
	pattern = p


func set_max_error(e):
	max_error = e


func get_input_error(input_received=1):
	var error = get_subdiv_error()
	var input_on_subdiv = get_pattern_at_subdiv()
	if input_on_subdiv != input_received:
		return OFFBEAT
	else:
		received_pattern[subdiv % len(pattern)] = input_received
		return error


### PRIVATE ###

func get_subdiv_at_time(time=total_time):
	return bpm * time * MAX_SUBDIV / 60

# Get subdiv index, and error (100% is half an eighth too late)
func get_subdiv_index():
	var beat = get_subdiv_at_time()
	var ind = round(beat)

func get_subdiv_error(subdiv_ind=subdiv):
	var dbeat = (get_subdiv_at_time() - subdiv_ind) * MAX_SUBDIV * 2
	# half eighth delta :
	# 100% for half eighth too late
	# 1600% for one beat too late
	# negative when too early
	return dbeat

func get_pattern_at_subdiv(subdiv_ind=subdiv):
	return pattern[subdiv_ind % len(pattern)]

func check_input_missed():
	for i in range(subdiv % len(pattern)):
		if pattern[i] != 0 and received_pattern[i] != pattern[i]:
			# subdiv missed, checking if error is still in the bounds for now
			if get_subdiv_error() > max_error:
				# TODO : send signal "input missed" to weapon
				return
	return

func make_new_beatmark(half=0):
	var b = beatmark.instantiate()
	b.set_speed(DIST_BEAT_MARKS * bpm / 60)
	b.global_position = Vector2(BEAT_REF_POS + NUM_BEAT_MARKS * DIST_BEAT_MARKS, PADY)
	add_child(b)
	if half:
		b.scale = 0.5 * Vector2(1, 1)
	return
