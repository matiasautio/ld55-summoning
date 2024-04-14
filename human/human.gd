extends Area2D

# words make worlds
# in a world without meaning, humans don't know what to do
# give meaning to things and summon into existance a world
# keep it in balance or plunge it into chaos

@export var type = "human"
const THINGS = ["human", "ghost", "egg", "wolf", "taxi", "time machine", "island", "fire", "whale"]
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
@export var speed = 100
var initial_speed = 0
@onready var next_pos = $NextPos
var idle_pos = Vector2.ZERO
var direction = 1
var goal = null
var has_reached_goal = false

# special conditions
@export_enum("normal", "stuck", "wet") var condition: int
@export var movement_boudnaries : ColorRect
var movement_area

func _ready():
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture("human", 0).get_size() * $AnimatedSprite2D.scale)
	screen_size = get_viewport_rect().size
	find_new_pos()
	if state == 1:
		play_animation("human")
	initial_speed = speed
	if condition == 1:
		make_stuck()


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
			direction_to_target = ((move_to.global_transform.origin - global_transform.origin) * direction).normalized()
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
	position = position.clamp(Vector2(313,64), screen_size)
	if condition == 1:
		position = position.clamp(Vector2(movement_area.position.x, movement_area.position.y), Vector2(movement_area.end.x, movement_area.end.y))


func _on_vision_area_entered(area):
	if area != self:
		if area.type == "wolf":
			perform_action(area)
		else:
			if THINGS.has(area.type) and can_have_action:
				add_action_to_list(area)
				print(area)


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
	can_have_action = false
	current_action = action.type
	match current_action:
		"human":
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				Console.add_message(type + " is greeting human")
		"wolf":
			action_timer.start()
			direction = -1
			speed = 150
			goal = action
			Console.add_message(type + " is afraid of wolf")
		"taxi":
			if !has_reached_goal:
				goal = action
			else:
				if goal.has_method("move"):
					goal.move(self)
				action_timer.start()
				Console.add_message(type + " is riding a taxi")
		"time machine":
			if !has_reached_goal:
				goal = action
			else:
				action_timer.start()
				Console.add_message(type + " is time traveling")
				goal.play_animation("timemachine")
				devolve()


func goal_reached():
	if goal != null:
		if current_action == "time machine":
			print("time machine reached")
		if state == 1:
			play_animation("human")
		has_reached_goal = true
		perform_action(goal)
		goal = null
	else:
		find_new_pos()


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_mask == 0:
		print("human clicked")
		can_move = false
		Console.show_popup(self)


func change_type(new_type):
	if monitorable:
		set_deferred("monitorable", false)
	type = new_type
	set_deferred("monitorable", true)


func enable_move():
	if state != 0:
		can_move = true


func find_new_pos():
	direction = 1
	if state == 1:
		play_animation("human")
	var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 1
	idle_pos = position + movement_area
	idle_pos = idle_pos.clamp(Vector2(313,64), screen_size)
	next_pos.global_position = idle_pos


func _on_action_cooldown_timeout():
	#$Vision.monitoring = true
	can_have_action = true


func _on_action_timeout():
	goal = null
	has_reached_goal = false
	current_action = null
	direction = 1
	speed = initial_speed
	#$Vision.monitoring = false
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
	#pass
	direction = -1
	find_new_pos()

# water checker
func _on_area_entered(area):
	print("aaa water")
	if area.type == "island":
		#can_move = false
		direction = -1


func make_stuck():
	movement_area = movement_boudnaries.get_rect()
