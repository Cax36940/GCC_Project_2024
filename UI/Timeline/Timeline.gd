extends Node2D
class_name Timeline

const MAX_SUBDIV: int = 8 # Eighth of a beat
const OFFBEAT: float = INF


var total_time: float
var bpm: float = 60.0
var subdiv: int = 0 # updated each frame

var pattern = [0]
var received_pattern = [0] # 1 when received correct input, 0 when wrong/no input
var max_error: float = 1.0 # 1.0 = 100% = 16th of a beat
var offset = 0

const SPRITE_POS_ON_TIME = 0 # TODO Sync with beat
const SPRITE_DIST_EACH_TIME = 100 # Depends on the png image

const TEXTURE_PATTERN_BEAT = preload("res://UI/Timeline/pattern_beat.png")
const TEXTURE_PATTERN_HALF_BEAT = preload("res://UI/Timeline/pattern_half_beat.png")
const TEXTURE_PATTERN_QUARTER_BEAT = preload("res://UI/Timeline/pattern_quarter_beat.png")


var awaiting = true


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_time()
	set_pattern([1, 0, 1, 0, 1, 0, 1, 1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	total_time += delta
	var prev_subdiv = subdiv
	subdiv = get_subdiv_at_time()
	set_sprite_pos(total_time)
	check_input_missed()


func reset_time(t=0.0):
	total_time = t
	set_sprite_pos(t)


func await_pattern():
	awaiting = true


func set_pattern(p):
	pattern = p
	received_pattern = p
	make_pattern_sprites()


func set_max_error(e):
	max_error = e


func get_input_error(input_received=1):
	var error = get_subdiv_error()
	if awaiting:
		awaiting = false
		offset = subdiv
		return error
	elif get_pattern_at_subdiv() == input_received:
		received_pattern[subdiv % len(pattern)] = input_received
		return error
	else:
		return OFFBEAT


### PRIVATE ###

func make_pattern_sprites():
	for c in $Pattern_sprites.get_children():
		c.free()
	for i in range(len(pattern)):
		if pattern[i]:
			var c = Sprite2D.new()
			c.set_name("Sprite"+str(i))
			if i % MAX_SUBDIV == 0:
				c.texture = TEXTURE_PATTERN_BEAT
			elif i % MAX_SUBDIV == MAX_SUBDIV / 2:
				c.texture = TEXTURE_PATTERN_HALF_BEAT
			else:
				c.texture = TEXTURE_PATTERN_QUARTER_BEAT
			c.position.x = i * SPRITE_DIST_EACH_TIME / MAX_SUBDIV
			$Pattern_sprites.add_child(c)

func set_sprite_pos(t):
	var beat = bpm * t / 60.0
	var p = fmod(beat, 1)
	$Sprite2D.position.x = SPRITE_POS_ON_TIME - SPRITE_DIST_EACH_TIME * p
	if awaiting:
		# Redish on beat
		var gb = 1 - (2*p - 1) ** 4
		$Pattern_sprites.modulate = Color(1, gb, gb)
	else:
		$Pattern_sprites.position.x = SPRITE_POS_ON_TIME - SPRITE_DIST_EACH_TIME * fmod(beat, len(pattern))

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

