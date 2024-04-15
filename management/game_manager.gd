extends Node

# Holds all the info for different missions

var mission_list = ["10 greetings", "Feed the wolf"]
@export var mission_text_scene : PackedScene


func _ready():
	for mission in mission_list:
		add_mission(mission)


func add_mission(mission):
	var new_mission = mission_text_scene.instantiate()
	new_mission.text = mission
	$"../CanvasLayer/MissionLog/VBoxContainer".add_child(new_mission)
