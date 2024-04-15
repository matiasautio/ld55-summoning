extends Node

# Holds all the info for different missions
# OBS!!! The text strikethrough is not dynamic, but needs to be set manually in each corresponding function

# Cannibalism?
var mission_list_0 = ["8 greetings", "Feed a wolf", "Ghost town"]
var mission_list_1 = ["Return to EGG", "Halloween is over"]
var mission_list_2 = ["8 sleepers", "All modes of transport"]
var active_missions = []
# Mission tracking variables
var greeting_threshold = 8
var wolf_eating_threshold = 1
var number_of_human_characters = 8
var number_of_ghosts = 0
# turn into egg
# turn back to human from ghost
var sleeper_threshold = 8
#var transport_threshold = 2
var taxi = false
var hole = false

@export var show_all_missions = true
var completed_missions_threshold = 0
var completed_missions = 0
#var mission_index = 0
@export var mission_text_scene : PackedScene


func _ready():
	trigger_mission_list(mission_list_0)
	if show_all_missions:
		trigger_mission_list(mission_list_1)
		trigger_mission_list(mission_list_2)
	completed_missions_threshold = mission_list_0.size() + mission_list_1.size()


func trigger_mission_list(list):
	for mission in list:
		add_mission(mission)


func add_mission(mission):
	var new_mission = mission_text_scene.instantiate()
	new_mission.text = mission
	$"../CanvasLayer/MissionLog/VBoxContainer".add_child(new_mission)
	active_missions.append(new_mission)
	completed_missions_threshold += 1


# Mission tracking

func greeting():
	greeting_threshold -= 1
	if greeting_threshold == 0:
		active_missions[0].text = "[s]" + active_missions[0].text
		complete_mission()


func wolf_eats():
	wolf_eating_threshold -= 1
	if wolf_eating_threshold == 0:
		active_missions[1].text = "[s]" + active_missions[1].text
		complete_mission()


func ghost(amount):
	number_of_ghosts += amount
	if number_of_ghosts == number_of_human_characters:
		active_missions[2].text = "[s]" + active_missions[2].text
		complete_mission()


func into_egg():
	active_missions[3].text = "[s]" + active_missions[3].text
	complete_mission()


func back_to_human():
	active_missions[4].text = "[s]" + active_missions[4].text
	complete_mission()


func sleep(amount):
	sleeper_threshold += amount
	if sleeper_threshold == 0:
		active_missions[5].text = "[s]" + active_missions[5].text
		complete_mission()


func transport(type):
	if type == "taxi":
		taxi = true
	if type == "hole":
		hole = true
	if taxi and hole:
		active_missions[6].text = "[s]" + active_missions[6].text
		complete_mission()


func complete_mission():
	completed_missions_threshold -= 1
	if completed_missions_threshold == 0:
		pass
	completed_missions += 1
	if completed_missions == 2:
		trigger_mission_list(mission_list_1)
	if completed_missions == 5:
		trigger_mission_list(mission_list_2)
