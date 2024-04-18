"""extends Node2D
class_name Timeline

const MAX_SUBDIV: int = 8 # Eighth of a beat
const OFFBEAT: float = INF

func rounduptobeat(n):
	return n + MAX_SUBDIV - n%MAX_SUBDIV


var total_time: float
var bpm: float = 10.0
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

signal input_missed

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_time()
	set_pattern([1, 0, 1, 0, 0, 0, 1, 1])
	await_pattern()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	total_time += delta
	
	# tmp
	#if not awaiting and (int(total_time/5) % 2 == 0):
	#	await_pattern()
	#if awaiting and (int(total_time/5) % 2 == 1):
	#	start_pattern()
	
	subdiv = get_subdiv_at_time()
	set_sprite_pos(total_time)
	check_input_missed()


func reset_time(t=0.0):
	total_time = t
	set_sprite_pos(t)


func await_pattern():
	print("Timeline: WAITING FOR INPUT")
	awaiting = true
	make_pattern_sprites()


func start_pattern(new_offset=subdiv):
	print("Timeline: PATTERN STARTED")
	awaiting = false
	offset = new_offset
	make_all_pattern_sprites()


func set_pattern(p):
	pattern = p
	received_pattern = p
	make_pattern_sprites()


func set_max_error(e):
	max_error = e


func get_input_error(input_received=1):
	# 1600% = 1 beat
	var error = get_subdiv_error()
	
	# 100% = 1 beat
	var error_on_time = closest_to_zero(get_subdiv_error(subdiv - subdiv%MAX_SUBDIV), get_subdiv_error(subdiv - subdiv%MAX_SUBDIV + MAX_SUBDIV))
	
	var pattern_subdiv_index = (subdiv - offset) % len(pattern)
	if awaiting and abs(error_on_time) < max_error:
		print("Timeline: CORRECT FIRST INPUT (error on time :"+str(error_on_time)+"/"+str(max_error * 2 * MAX_SUBDIV)+")")
		start_pattern(closest_div())
		return error
	elif get_pattern_at_subdiv(pattern_subdiv_index) == input_received and abs(error) < max_error:
		print("Timeline: CORRECT INPUT")
		received_pattern[pattern_subdiv_index] = input_received
		return error
	else:
		print(pattern_subdiv_index, " ", get_pattern_at_subdiv(pattern_subdiv_index), " ", input_received, " error: ", error, "/", max_error)
		print("Timeline: OFFBEAT")
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


func make_all_pattern_sprites():
	for c in $Pattern_sprites.get_children():
		c.free()
	for r in range(-3, 12):
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
				c.position.x = (r * len(pattern) + i + offset) * SPRITE_DIST_EACH_TIME / MAX_SUBDIV
				$Pattern_sprites.add_child(c)


func set_sprite_pos(t):
	var beat = bpm * t / 60.0
	var p = fmod(beat, 1)
	$Sprite2D.position.x = SPRITE_POS_ON_TIME - SPRITE_DIST_EACH_TIME * p
	if awaiting:
		# Redish on beat
		var gb = 1 - (2*p - 1) ** 4
		$Pattern_sprites.modulate = Color(1, gb, gb)
		$Pattern_sprites.position.x = SPRITE_POS_ON_TIME + SPRITE_DIST_EACH_TIME * 2
	else:
		$Pattern_sprites.modulate = Color(1, 1, 1)
		$Pattern_sprites.position.x = SPRITE_POS_ON_TIME + SPRITE_DIST_EACH_TIME * (2 - fmod(beat, len(pattern) / MAX_SUBDIV))


func get_subdiv_at_time(time=total_time):
	return bpm * time * MAX_SUBDIV / 60


# Get subdiv index, and error (100% is half an eighth too late)
func get_subdiv_index():
	var beat = get_subdiv_at_time()
	var ind = round(beat)
	return ind


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
				print("missed (from Timeline.gd)")
				input_missed.emit()
				return
	return


func closest_to_zero(a, b):
	if abs(a) <= abs(b): return a
	else: return b


func closest_div(subdiv=subdiv):
	var in_time_offset = subdiv%MAX_SUBDIV
	if in_time_offset < MAX_SUBDIV / 2:
		return subdiv - in_time_offset
	else:
		return subdiv - in_time_offset + MAX_SUBDIV
"""
