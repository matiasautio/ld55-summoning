extends Area2D

# words make worlds
# in a world without meaning, humans don't know what to do
# give meaning to things and summon into existance a world
# keep it in balance or plunge it into chaos

@export var type = "human"
const THINGS = ["human", "wolf", "taxi"]
# 0 = egg, 1 = human, 2 = ghost
var state = 1

var size = Vector2(0,0)

# logic
var can_have_action = true
var current_action = null
@onready var action_timer = $Action
@onready var action_cooldown_timer = $ActionCooldown

# movement logic
@export var can_move = true
var screen_size

var start_pos = Vector2.ZERO
var idle_pos = Vector2.ZERO

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
	print(screen_size)
	find_new_pos()
	play_animation("human")
	#print(idle_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#t += delta * 0.4
	if can_move:
		if goal != null:
				if !specific_goal:
					position = position.lerp(goal.global_position * direction, delta * 2)
					if position.distance_to(goal.global_position) < goal.size.x:
						goal_reached()
				else:
					position = position.lerp(goal.specific_goal() * direction, delta * 2)
					if position.distance_to(goal.specific_goal()) < 10:
						goal_reached()
		if goal == null and current_action == null:
			if $AnimatedSprite2D.animation != "human_walk":
				play_animation("human_walk")
			#t += delta * 2
			position = position.lerp(idle_pos, delta * 2)
			if position.distance_to(idle_pos) < 1:
				find_new_pos()
				
	position = position.clamp(Vector2(313,64), screen_size)


func _on_vision_area_entered(area):
	if area != self:
		if THINGS.has(area.type) and can_have_action:
			#print("i saw something")
			determine_action(area)
			#goal = area
			#start_pos = global_position
			#determine_action(area)


func determine_action(action):
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
				specific_goal = true
				goal = action
			else:
				goal.move(self)
				action_timer.start()
				Console.add_message(type + " is riding a taxi")


func goal_reached():
	play_animation("human")
	has_reached_goal = true
	specific_goal = false
	determine_action(goal)
	goal = null


func _on_input_event(viewport, event, shape_idx):
	pass
	#print(event)
	#if event is InputEventMouseButton and event.button_mask == 0:
		#get_tree().call_group("human", "change_type", "human")
		#change_type("human")


func change_type(new_type):
	#print("my new type is ", new_type)
	if monitorable:
		monitorable = false
	type = new_type
	monitorable = true


func find_new_pos():
	#t = 0
	play_animation("human")
	var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 2
	idle_pos = global_position + movement_area
	idle_pos = idle_pos.clamp(Vector2(313,64), screen_size)
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
	change_type("ghost")
	state = 2
	play_animation("human_becomeghost")


func play_animation(animation_name):
	$AnimatedSprite2D.animation = animation_name
	$AnimatedSprite2D.play()


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "human_becomeghost":
		play_animation("ghost")
