extends Area2D

# words make worlds
# in a world without meaning, humans don't know what to do
# give meaning to things and summon into existance a world
# keep it in balance or plunge it into chaos

@export var type = "human"
const THINGS = ["human", "ghost", "egg", "wolf", "taxi", "time machine"]
# 0 = egg, 1 = human, 2 = ghost
var state = 1

var size = Vector2(0,0)

# logic
var possible_actions = []
var possible_action_types = []
var can_have_action = true
var current_action = null
@onready var action_timer = $Action
@onready var action_cooldown_timer = $ActionCooldown

# movement logic
@export var can_move = true
var screen_size

var speed = 100

var start_pos = Vector2.ZERO
var idle_pos = Vector2.ZERO
@onready var next_pos = $NextPos

var old_pos = Vector2.ZERO
var t = 0.0
var direction = Vector2(1,1)
var goal = null
var specific_goal = false
var has_reached_goal = false


func _ready():
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture("human", 0).get_size() * $AnimatedSprite2D.scale)
	#print(position)
	screen_size = get_viewport_rect().size# - Vector2(313,0)# 93 + size.y)
	#print(screen_size)
	#next_pos.call_deferred("reparent", get_parent())
	#remove_child(next_pos)
	#get_parent().call_deferred("add_child",next_pos)
	#next_pos.global_position = Vector2(500,300)
	find_new_pos()
	if state == 1:
		play_animation("human")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#t += delta * 0.4
	if can_move:
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
			direction_to_target = (move_to.global_transform.origin - global_transform.origin).normalized()
			#print(direction_to_target)
			velocity = direction_to_target
			if global_transform.origin.distance_to(move_to.global_position) < move_to.size.x:
				goal_reached()
			if velocity.length() > 0:
				velocity = velocity.normalized() * speed
				if state == 1:
					play_animation("human_walk")
			else:
				if state == 1:
					play_animation("human")
			position += velocity * delta
		else:
			_on_action_timeout()
			print("move to is null")
				#if !specific_goal:
				#if current_action == "time machine":
					#print(position.distance_to(goal.global_position), "size is ", goal.size.x)
				#position = position.lerp(goal.global_position * direction, delta * 2)
				#if position.distance_to(goal.global_position) < goal.size.x:
					#goal_reached()
				#else:
					#position = position.lerp(goal.specific_goal() * direction, delta * 2)
					#if position.distance_to(goal.specific_goal()) < 10:
						#goal_reached()
		#if goal == null and current_action == null:
			#if $AnimatedSprite2D.animation != "human_walk":
				#if state == 1:
					#play_animation("human_walk")
			##t += delta * 2
			#position = position.lerp(idle_pos, delta * 2)
			#if position.distance_to(idle_pos) < 1:
				#find_new_pos()
				
	position = position.clamp(Vector2(313,64), screen_size)


func _on_vision_area_entered(area):
	if area != self:
		if THINGS.has(area.type) and can_have_action:
			#print("i saw something")
			add_action_to_list(area)
			print(area)
			#perform_action(area)
			#goal = area
			#start_pos = global_position
			#determine_action(area)


func add_action_to_list(action):
	#print(action.type)
	possible_actions.append(action)
	possible_action_types.append(action.type)
	if $ActionDetermineWindow.time_left == 0:
		$ActionDetermineWindow.start()
	#possible_actions.clear()


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
	#print(action)
	can_have_action = false
	current_action = action.type
	#print(current_action)
	match current_action:
		"human":
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				Console.add_message(type + " is greeting human")
		"wolf":
			action_timer.start()
			direction = action.global_position.direction_to(
				self.position)
			goal = action
			#print("direction is ", action.global_position.direction_to(self.position))
			#goal = action.global_position.direction_to(self)
			Console.add_message(type + " is afraid of wolf")
		"taxi":
			#print(current_action)
			if !has_reached_goal:
				#specific_goal = true
				goal = action
			else:
				if goal.has_method("move"):
					goal.move(self)
				action_timer.start()
				Console.add_message(type + " is riding a taxi")
		"time machine":
			#if state == 2:
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				Console.add_message(type + " is time traveling")
				goal.play_animation("timemachine")
				devolve()
			#else:
				#print("i dont need to use the time machine")
				#_on_action_timeout()


func goal_reached():
	if goal != null:
		if current_action == "time machine":
			print("time machine reached")
		if state == 1:
			play_animation("human")
		has_reached_goal = true
		#specific_goal = false
		perform_action(goal)
		goal = null
	else:
		find_new_pos()


func _on_input_event(viewport, event, shape_idx):
	#print(event)
	if event is InputEventMouseButton and event.button_mask == 0:
		print("human clicked")
		can_move = false
		Console.show_popup(self)


func change_type(new_type):
	#print("my new type is ", new_type)
	if monitorable:
		set_deferred("monitorable", false)
	type = new_type
	set_deferred("monitorable", true)


func enable_move():
	if state != 0:
		can_move = true


func find_new_pos():
	#t = 0
	if state == 1:
		play_animation("human")
	var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 2
	idle_pos = position + movement_area
	idle_pos = idle_pos.clamp(Vector2(313,64), screen_size)
	next_pos.global_position = idle_pos
	#print(next_pos.position)
	#start_pos = global_position
	#print(global_position, position)
	#print(idle_pos)


func _on_action_cooldown_timeout():
	$Vision.monitoring = true
	can_have_action = true


func _on_action_timeout():
	#can_have_action = false
	goal = null
	has_reached_goal = false
	current_action = null
	direction = Vector2(1,1)
	$Vision.monitoring = false
	action_cooldown_timer.start()
	find_new_pos()


func die():
	if state == 1:
		change_type("ghost")
		state = 2
		play_animation("human_becomeghost")


func devolve():
	if state == 1:
		change_type("egg")
		state = 0
		play_animation("egg")
		can_move = false
		position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		position = position.clamp(Vector2(313,64), screen_size)
	elif state == 2:
		change_type("human")
		state = 1
		play_animation("human")


func play_animation(animation_name):
	$AnimatedSprite2D.animation = animation_name
	$AnimatedSprite2D.play()


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "human_becomeghost":
		play_animation("ghost")


func _on_mouse_entered():
	print("mouse entered")


func _on_idle_goal_reached_timeout():
	find_new_pos()


func _on_visible_on_screen_notifier_2d_screen_exited():
	find_new_pos()
