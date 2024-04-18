extends Node2D
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
var next_pattern_subdiv_input = 0
var next_global_subdiv_input = 0

const SPRITE_POS_ON_TIME = 0 # TODO Sync with beat
const SPRITE_DIST_EACH_TIME = 100 # Depends on the png image
const TOTAL_PATTERNS_VISIBLE = 20  # Num patterns to draw in advance

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
	set_sprite_pos()
	check_input_missed()


func reset_time(t=0.0):
	total_time = t
	set_sprite_pos()


func await_pattern():
	print("Timeline: WAITING FOR INPUT")
	awaiting = true
	next_pattern_subdiv_input = get_next_non_zero_pattern(0)
	make_pattern_sprites()


func start_pattern(new_offset=subdiv):
	print("Timeline: PATTERN STARTED")
	awaiting = false
	offset = new_offset
	next_pattern_subdiv_input = get_next_non_zero_pattern(1)
	next_global_subdiv_input = offset + next_pattern_subdiv_input
	make_all_pattern_sprites()


func set_pattern(p):
	pattern = []
	received_pattern = []
	# Copy
	for i in p:
		pattern.append(i)
		received_pattern.append(i)
	make_pattern_sprites()


func set_max_error(e):
	max_error = e


func get_input_error(input_received=1):
	# 1600% = 1 beat
	var error_on_beat = closest_to_zero(get_subdiv_error(subdiv - subdiv%MAX_SUBDIV), get_subdiv_error(subdiv - subdiv%MAX_SUBDIV + MAX_SUBDIV))
	
	var error = get_subdiv_error(next_global_subdiv_input)
	print("(error on beat :"+str(error_on_beat)+"/"+str(max_error)+")")
	print("(error on next subdiv :"+str(get_subdiv_error(next_global_subdiv_input))+"/"+str(max_error)+")")
	if awaiting and abs(error_on_beat) < max_error:
		print("Timeline: CORRECT FIRST INPUT (error on beat :"+str(error_on_beat)+"/"+str(max_error)+")")
		start_pattern(closest_div())
		get_pattern_sprite_on_subdiv_id(closest_div()).modulate = Color(0.0, 0.8, 0.0)
		print("Next subdiv awaited : "+str(next_pattern_subdiv_input))
		return error_on_beat
	elif abs(error) < max_error:
		print("Timeline: CORRECT INPUT")
		received_pattern[next_pattern_subdiv_input] = input_received
		go_to_next_pattern_subdiv_input()
		get_pattern_sprite_on_subdiv_id(closest_div()).modulate = Color(0.0, 0.8, 0.0)
		print("Next subdiv awaited : "+str(next_pattern_subdiv_input))
		return error
	else:
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
	"""old:
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
	"""
	for r in range(TOTAL_PATTERNS_VISIBLE):
		draw_pattern_sprites(r)


func draw_pattern_sprites(r):
	var c
	for i in range(len(pattern)):
		if pattern[i]:
			c = Sprite2D.new()
			# Global subdiv represented by this sprite
			var equivalent_subdiv = r * len(pattern) + i + offset
			c.set_name("Subdiv-"+str(i)+"-"+str(equivalent_subdiv))
			if equivalent_subdiv % MAX_SUBDIV == 0:
				c.texture = TEXTURE_PATTERN_BEAT
			elif equivalent_subdiv % MAX_SUBDIV == MAX_SUBDIV / 2:
				c.texture = TEXTURE_PATTERN_HALF_BEAT
			else:
				c.texture = TEXTURE_PATTERN_QUARTER_BEAT
			c.position.x = equivalent_subdiv * SPRITE_DIST_EACH_TIME / MAX_SUBDIV
			$Pattern_sprites.add_child(c)
	c.set_name(c.name+"-") # Last (when deleted, generate new sprites for 1 more pattern)


func set_sprite_pos(t=total_time):
	var beat = bpm * t / 60.0
	var p = fmod(beat, 1)
	$Sprite2D.position.x = SPRITE_POS_ON_TIME - SPRITE_DIST_EACH_TIME * p
	if awaiting:
		# White, redish on beat
		var gb = 1 - (2*p - 1) ** 4
		$Pattern_sprites.modulate = Color(1, gb, gb)
		$Pattern_sprites.position.x = SPRITE_POS_ON_TIME + SPRITE_DIST_EACH_TIME * 2
	else:
		"""old (just white) :
		$Pattern_sprites.modulate = Color(1, 1, 1)
		$Pattern_sprites.position.x = SPRITE_POS_ON_TIME + SPRITE_DIST_EACH_TIME * (2 - fmod(beat, len(pattern) / MAX_SUBDIV))
		"""
		$Pattern_sprites.modulate = Color(1, 1, 1) # No influence on children
		# Light blue if "not yet done", else white
		for sp in $Pattern_sprites.get_children():
			var equivalent_subdiv = int(sp.name.split("-")[2]) # Name : Subdiv-1-1, Subdiv-3-42, Subdiv-0-864512
			
			if equivalent_subdiv >= next_global_subdiv_input: # Future
				sp.modulate = Color(0.3, 0.3, 1.0)
			
			if sp.global_position.x < -10: # Out of screen -> deletion (optimisation)
				if sp.name.ends_with("-"): # Last sprite of pattern -> redraw one more pattern
					draw_pattern_sprites(TOTAL_PATTERNS_VISIBLE)
				sp.queue_free()
		
		$Pattern_sprites.position.x = SPRITE_POS_ON_TIME + SPRITE_DIST_EACH_TIME * (2 - beat)


func get_subdiv_at_time(time=total_time):
	return bpm * time * MAX_SUBDIV / 60


# Get subdiv index, and error (100% is half an eighth too late)
func get_subdiv_index():
	var beat = get_subdiv_at_time()
	var ind = round(beat)
	return ind


func go_to_next_pattern_subdiv_input():
	next_pattern_subdiv_input = get_next_non_zero_pattern(next_pattern_subdiv_input + 1)
	next_global_subdiv_input = offset + next_pattern_subdiv_input
	while next_global_subdiv_input < subdiv:
		# Look for subdiv in next pattern, not current one
		next_global_subdiv_input += len(pattern)


func get_subdiv_error(subdiv_ind=subdiv):
	# half eighth delta :
	# 100% for half eighth too late
	# 1600% for one beat too late
	# negative when too early
	return total_time - subdiv_ind * 60 / (bpm * MAX_SUBDIV)


func get_pattern_at_subdiv(subdiv_ind=subdiv):
	return pattern[subdiv_ind % len(pattern)]


func check_input_missed():
	if get_subdiv_error(next_global_subdiv_input) > max_error:
		print("missed (from Timeline.gd)")
		get_pattern_sprite_on_subdiv_id(next_global_subdiv_input).modulate = Color(1, 0, 0)
		go_to_next_pattern_subdiv_input()
		print("now awaiting : "+str(next_pattern_subdiv_input)+" (global : "+str(next_global_subdiv_input))
		input_missed.emit()
		return
	return


func get_pattern_sprite_on_subdiv_id(subdiv):
	var id
	for sp in $Pattern_sprites.get_children():
		id = int(sp.name.split("-")[2])
		if id == subdiv:
			return sp


func get_next_non_zero_pattern(ind):
	for i in range(ind, len(pattern)):
		if pattern[i] != 0:
			return i
	for i in range(len(pattern)):
		if pattern[i] != 0:
			return i
	print("PATTERN EQUAL TO ZERO !!")


func closest_to_zero(a, b):
	if abs(a) <= abs(b): return a
	else: return b


func closest_div(subdiv=subdiv):
	var in_time_offset = subdiv%MAX_SUBDIV
	if in_time_offset < MAX_SUBDIV / 2:
		return subdiv - in_time_offset
	else:
		return subdiv - in_time_offset + MAX_SUBDIV
