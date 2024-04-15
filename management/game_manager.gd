extends Node

# Holds all the info for different missions
# OBS!!! The text strikethrough is not dynamic, but needs to be set manually in each corresponding function

var level = null

# Cannibalism?
var mission_list_0 = ["8 greetings", "Feed a wolf", "Ghost town"]
var mission_list_1 = ["Halloween is over", "Return to EGG"]
var mission_list_2 = ["All modes of transport"]
var mission_list_3 = ["8 dreams had"]
var active_missions = []
# Mission tracking variables
var greeting_threshold = 8
var greeting_index = 0

var wolf_eating_threshold = 1
var wolf_index = 0

var number_of_human_characters = 8
var number_of_ghosts = 0
var ghost_index = 0

# turn into egg
var egg_index = 0
# turn back to human from ghost
var halloween_index = 0

var sleeper_threshold = 8
var sleeper_index = 0

#var transport_threshold = 2
var transport_done = false
var taxi = false
var hole = false
var transport_index = 0

@export var show_all_missions = true
var completed_missions_threshold = 0
var tier_1_threshold = 2
var tier_2_threshold = 4
var tier_3_threshold = 6
var completed_missions = 0
#var mission_index = 0
@export var mission_text_scene : PackedScene


func _ready():
	trigger_mission_list(mission_list_0)
	if show_all_missions:
		trigger_mission_list(mission_list_1)
		trigger_mission_list(mission_list_2)
	completed_missions_threshold = mission_list_0.size() + mission_list_1.size()
	generate_indexes()


func generate_mission_list(list):
	for mission in list:
		add_mission(mission)


func trigger_mission_list(list):
	for mission in list:
		add_mission(mission)


func add_mission(mission):
	var new_mission = mission_text_scene.instantiate()
	new_mission.text = mission
	$"../CanvasLayer/MissionLog/VBoxContainer".add_child(new_mission)
	active_missions.append(new_mission)
	completed_missions_threshold += 1
	new_mission.visible = true


# Mission tracking
# Tier 0
func greeting():
	greeting_threshold -= 1
	if greeting_threshold == 0:
		active_missions[greeting_index].text = "[s]" + active_missions[greeting_index].text
		complete_mission()


func wolf_eats():
	wolf_eating_threshold -= 1
	if wolf_eating_threshold == 0:
		active_missions[wolf_index].text = "[s]" + active_missions[wolf_index].text
		complete_mission()


func ghost(amount):
	number_of_ghosts += amount
	if number_of_ghosts == number_of_human_characters:
		active_missions[ghost_index].text = "[s]" + active_missions[ghost_index].text
		complete_mission()


# Tier 1
func into_egg():
	if tier_1_threshold <= 0:
		active_missions[egg_index].text = "[s]" + active_missions[egg_index].text
		complete_mission()


func back_to_human():
	if tier_1_threshold <= 0:
		active_missions[halloween_index].text = "[s]" + active_missions[halloween_index].text
		complete_mission()


# Tier 2
func transport(type):
	if tier_2_threshold <= 0 and !transport_done:
		if type == "taxi":
			taxi = true
		if type == "hole":
			hole = true
		if taxi and hole:
			transport_done = true
			active_missions[transport_index].text = "[s]" + active_missions[transport_index].text
			complete_mission()


# Tier 3
func sleep(amount):
	if tier_3_threshold <= 0:
		sleeper_threshold -= amount
		if sleeper_threshold == 0:
			active_missions[sleeper_index].text = "[s]" + active_missions[sleeper_index].text
			print("dreams had")
			complete_mission()

func complete_mission():
	completed_missions_threshold -= 1
	tier_1_threshold -= 1
	tier_2_threshold -= 1
	tier_3_threshold -= 1
	if completed_missions_threshold == 0:
		pass
	completed_missions += 1
	print(completed_missions)
	if tier_1_threshold == 0:
		trigger_mission_list(mission_list_1)
		level.trigger_creatures(1)
	if tier_2_threshold == 0:
		trigger_mission_list(mission_list_2)
		level.trigger_creatures(2)
	if tier_3_threshold == 0:
		trigger_mission_list(mission_list_3)
		level.trigger_creatures(3)


func generate_indexes():
	var all_missions = []
	for mission in mission_list_0:
		all_missions.append(mission)
	for mission in mission_list_1:
		all_missions.append(mission)
	for mission in mission_list_2:
		all_missions.append(mission)
	for mission in mission_list_3:
		all_missions.append(mission)
	#print(all_missions)
	greeting_index = all_missions.find("8 greetings")
	wolf_index = all_missions.find("Feed a wolf")
	halloween_index = all_missions.find("Halloween is over")
	egg_index = all_missions.find("Return to EGG")
	ghost_index = all_missions.find("Ghost town")
	transport_index = all_missions.find("All modes of transport")
	sleeper_index = all_missions.find("8 dreams had")
	#print(wolf_index)

#var mission_list_0 = ["8 greetings", "Feed a wolf"]
#var mission_list_1 = ["Halloween is over", "Return to EGG", "Ghost town"]
#var mission_list_2 = ["All modes of transport"]
#var mission_list_3 = ["8 sleepers"]
