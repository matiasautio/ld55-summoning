extends Area2D

# words make worlds
# in a world without meaning, humans don't know what to do
# give meaning to things and summon into existance a world
# keep it in balance or plunge it into chaos

@export var type = "human"
const THINGS = ["human", "cat", "car"]

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
var goal = null


func _ready():
	size = Vector2($Sprite2D.texture.get_width(), $Sprite2D.texture.get_height()) * $Sprite2D.scale
	#print(position)
	screen_size = get_viewport_rect().size - Vector2(0, 93 + size.y)
	find_new_pos()
	#print(idle_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	t += delta * 0.4
	if can_move:
		if goal != null:
		#var new_pos = 
			position = position.lerp(goal.global_position, delta * 2)
			if position.distance_to(goal.global_position) < goal.size.x:
				goal_reached()
		if goal == null and current_action == null:
			#t += delta * 2
			position = position.lerp(idle_pos, delta * 2)
			if position.distance_to(idle_pos) < 1:
				find_new_pos()
				
	#position = position.clamp(Vector2.ZERO, screen_size)


func _on_vision_area_entered(area):
	if area != self:
		if THINGS.has(area.type) and can_have_action:
			print("i saw something")
			goal = area
			start_pos = global_position
			#determine_action(area)


func determine_action(action):
	current_action = action
	action_timer.start()
	match current_action:
		"human":
			#old_pos = position
			#goal = action
			#var message = 
			Console.add_message(type + " is greeting human")
			print("greeting human")
		"cat":
			print("petting car")
		"car":
			print("drivng car")


func goal_reached():
	determine_action(goal.type)
	goal = null


func _on_input_event(viewport, event, shape_idx):
	#print(event)
	if event is InputEventMouseButton and event.button_mask == 0:
		get_tree().call_group("human", "change_type", "human")
		#change_type("human")


func change_type(new_type):
	print("my new type is ", new_type)
	if monitorable:
		monitorable = false
	type = new_type
	monitorable = true


func find_new_pos():
	#t = 0
	var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 2
	idle_pos = global_position + movement_area
	idle_pos = idle_pos.clamp(Vector2.ZERO, screen_size)
	start_pos = global_position
	#print(global_position, position)
	#print(idle_pos)


func _on_action_cooldown_timeout():
	can_have_action = true


func _on_action_timeout():
	can_have_action = false
	goal = null
	current_action = null
	action_cooldown_timer.start()
