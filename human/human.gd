extends Area2D

# words make worlds
# in a world without meaning, humans don't know what to do
# give meaning to things and summon into existance a world
# keep it in balance or plunge it into chaos

@export var type = "human"
const THINGS = ["human", "cat", "car"]

var size = Vector2(0,0)

# logic
var current_action = null

# movement logic
@export var can_move = true
var old_pos = Vector2(0,0)
var t = 0.0
var goal = null

func _ready():
	size = Vector2($Sprite2D.texture.get_width(), $Sprite2D.texture.get_height()) * $Sprite2D.scale
	print(position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	t += delta * 0.04
	if goal != null and can_move:
		#var new_pos = 
		position = position.lerp(goal.global_position, t)
		if position.distance_to(goal.global_position) < goal.size.x:
			goal_reached()


func _on_vision_area_entered(area):
	if area != self:
		if THINGS.has(area.type):
			goal = area
			#determine_action(area)


func determine_action(action):
	current_action = action
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
