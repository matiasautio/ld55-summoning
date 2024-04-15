extends Area2D

# words make worlds
# in a world without meaning, humans don't know what to do
# give meaning to things and summon into existance a world
# keep it in balance or plunge it into chaos

@export var type = "human"
var original_type = "human"
var humanity_type = "human"
const THINGS = ["human", "ghost", "egg", "wolf", "taxi", "time machine", "fire", "whale", "donut", "dino"]
# island is being checked by the water detector
# 0 = egg, 1 = human, 2 = ghost
var state = 1
var size = Vector2(0,0)

# logic
@export var is_active = false
var possible_actions = []
var possible_action_types = []
var can_have_action = true
var current_action = null
@onready var action_timer = $Action
@onready var action_cooldown_timer = $ActionCooldown

# movement logic
@export var can_move = true
var screen_size
@export var speed = 100
var initial_speed = 0
@onready var next_pos = $NextPos
var idle_pos = Vector2.ZERO
var direction = 1
var goal = null
var has_reached_goal = false

var clamp_start = Vector2(250, 64)#Vector2.ZERO

# special conditions
@export_enum("normal", "stuck", "wet") var condition: int
@export var movement_boudnaries : ColorRect
var movement_area

# audio
@onready var audio_player = $AudioStreamPlayer2D


func _ready():
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture("human", 0).get_size() * $AnimatedSprite2D.scale)
	screen_size = get_viewport_rect().size
	find_new_pos()
	#if state == 1:
		#play_animation("human")
	initial_speed = speed
	if condition == 1:
		make_stuck()
	type = "???"


func activate_creature():
	is_active = true
	play_animation(original_type)


func _physics_process(delta):
	#t += delta * 0.4
	if can_move and is_active:
		var move_to = null
		if goal != null:
			move_to = goal
		if goal == null and current_action == null:
			move_to = next_pos
			if $IdleGoalReached.time_left == 0:
				$IdleGoalReached.start()
		if move_to != null:
			var velocity = Vector2.ZERO
			var direction_to_target = Vector2.ZERO
			direction_to_target = ((move_to.global_transform.origin - global_transform.origin) * direction).normalized()
			#print(direction_to_target)
			velocity = direction_to_target
			if global_transform.origin.distance_to(move_to.global_position) < move_to.size.x / 2:
				goal_reached()
				velocity = Vector2.ZERO
			if velocity.length() > 0:
				velocity = velocity.normalized() * speed
				if state == 1:
					play_animation("human_walk")
			else:
				if state == 1:
					if current_action == "fire":
						return
					play_animation("human")
			position += velocity * delta
		#else:
			#if current_action == null:
			#_on_action_timeout()
				#print("move to is null")
				#print("current action is ", current_action)
	position = position.clamp(Vector2(313,64), screen_size)
	if condition == 1:
		position = position.clamp(Vector2(movement_area.position.x, movement_area.position.y), Vector2(movement_area.end.x, movement_area.end.y))


func _on_vision_area_entered(area):
	if is_active:
		if area != self:
			# Human is not a ghost
			if state != 2:
				if area.type == "donut" and current_action != "donut":
					perform_action(area)
				if area.type == "wolf" and current_action != "wolf" and current_action != "taxi":
					perform_action(area)
				else:
					if condition == 2 and area.type == "fire" and current_action != "fire":
						perform_action(area)
					else:
						if area.type == "egg" and can_have_action:
							perform_action(area)
						else:
							if THINGS.has(area.type) and can_have_action:
								add_action_to_list(area)
			# Human is a ghost
			else:
				if area.type == "time machine":
					perform_action(area)
				else:
					if area.type != "egg" and area.type != "fire":
						if THINGS.has(area.type) and can_have_action:
							add_action_to_list(area)


func add_action_to_list(action):
	possible_actions.append(action)
	possible_action_types.append(action.type)
	if $ActionDetermineWindow.time_left == 0:
		$ActionDetermineWindow.start()


func _on_action_determine_window_timeout():
	if state == 2:
		if possible_action_types.has("time machine"):
			var action_id = possible_action_types.find("time machine")
			perform_action(possible_actions[action_id])
		else:
			perform_action(possible_actions[0])
	elif state == 1:
		perform_action(possible_actions[0])
	possible_actions.clear()
	possible_action_types.clear()


func perform_action(action):
	if action == null:
		_on_action_timeout()
		return
	can_have_action = false
	current_action = action.type
	match current_action:
		"human":
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				play_animation("human")
				Console.add_message(humanity_type + " is greeting " + action.original_type)
				Console.game_manager.greeting()
		"wolf":
			action_timer.start()
			direction = -1
			speed = 150
			goal = action
			Console.add_message(humanity_type + " is afraid of " + action.original_type)
		"taxi":
			if !has_reached_goal:
				goal = action
			else:
				#if goal.has_method("move"):
				if goal != null:
					goal.move(self)
				play_animation("human")
				action_timer.start()
				Console.add_message(humanity_type + " is riding " + action.original_type)
				goal = null
		"time machine":
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				Console.add_message(humanity_type + " is time traveling")
				play_animation("human")
				goal = null
				#if goal != null:
					#goal.play_animation("time machine")
				#devolve()
		"egg":
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				Console.add_message(humanity_type + " is breaking " + action.original_type)
				if state == 1:
					play_animation("human_hit")
				goal.evolve()
				goal = null
		"fire":
			if !has_reached_goal:
				goal = action
			else:
				Console.add_message(humanity_type + " is feeling sleepy")
				goal = null
				if state == 1:
					play_animation("human_sleep")
					Console.game_manager.sleep(-1)
				action_timer.start()
				#dance()
		"whale":
			Console.add_message(humanity_type + " is looking at " + action.original_type)
			play_animation("human")
			action_timer.start()
		"ghost":
			Console.add_message(humanity_type + " is sad about " + action.original_type)
			action_timer.start()
		"donut":
			if !has_reached_goal:
				goal = action
			else:
				#var victim_type = action
				if action.die():
					Console.add_message(humanity_type + " is eating " + action.original_type)
					#if type == "wolf":
						#Console.game_manager.wolf_eats()
				else:
					Console.add_message(humanity_type + " tries to eat " + action.original_type)
				goal = null
				if state == 1:
					play_animation("human_eat")
				action_timer.start()


func goal_reached():
	if goal != null:
		if state == 1:
			play_animation("human")
		has_reached_goal = true
		perform_action(goal)
		goal = null
	else:
		find_new_pos()


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_mask == 0:
		can_move = false
		Console.show_popup(self)


func change_type(new_type):
	if monitorable:
		set_deferred("monitorable", false)
	humanity_type = new_type
	type = new_type
	set_deferred("monitorable", true)


func enable_move():
	if state != 0:
		can_move = true


func find_new_pos():
	if is_active:
		direction = 1
		if state == 1:
			play_animation("human")
		var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 1
		idle_pos = position + movement_area
		idle_pos = idle_pos.clamp(clamp_start, screen_size)
		next_pos.global_position = idle_pos


func _on_action_cooldown_timeout():
	pass
	#$Vision.monitoring = true
	#can_have_action = true


func _on_action_timeout():
	can_have_action = true
	if state == 1:
		play_animation("human")
	has_reached_goal = false
	current_action = null
	direction = 1
	speed = initial_speed
	#$Vision.monitoring = false
	action_cooldown_timer.start()
	find_new_pos()


func die():
	if state == 1 and current_action != "taxi":
		change_type("ghost")
		state = 2
		play_animation("human_becomeghost")
		Console.game_manager.ghost(1)
		play_audio("die")
		return true


func devolve():
	if state == 1:
		change_type("egg")
		state = 0
		play_animation("egg")
		can_move = false
		position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		position = position.clamp(clamp_start, screen_size)
		Console.game_manager.into_egg()
	elif state == 2:
		change_type("human")
		state = 1
		play_animation("human")
		Console.game_manager.ghost(-1)
		Console.game_manager.back_to_human()


func evolve():
	if state == 0:
		state = 1
		play_animation("egg_break")
		change_type("human")
		play_audio("hatch")
		#enable_move()


func dance():
	play_animation("human_sleep")
	#$Dance.start()


func play_animation(animation_name):
	if animation_name == "human" and state != 1:
		return
	$AnimatedSprite2D.animation = animation_name
	$AnimatedSprite2D.play()


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "human_becomeghost":
		play_animation("ghost")
	if $AnimatedSprite2D.animation == "egg_break":
		enable_move()
		_on_action_timeout()


func _on_idle_goal_reached_timeout():
	find_new_pos()


func _on_visible_on_screen_notifier_2d_screen_exited():
	#pass
	direction = -1
	find_new_pos()


func make_stuck():
	movement_area = movement_boudnaries.get_rect()


func _on_water_detector_area_entered(area):
	if area.type == "water":
		if condition == 0 or condition == 2:
			goal = null
			current_action = null
			condition = 2
			direction = -1
			find_new_pos()
			Console.add_message(type + " is getting wet")
			play_audio("wet")
	if area.type == "hole":
		direction = -1
		Console.add_message(type + " is avoiding " + area.original_type)


func _on_dance_timeout():
	pass # Replace with function body.


func play_audio(audio):
	if !audio_player.playing:
		audio_player.stream = AudioManager.get_audio(audio)
		audio_player.play()


func reset():
	is_active = false
	type = "???"
