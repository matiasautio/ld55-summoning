extends Area2D

class_name Creature

@export var type = "taxi"
var size = Vector2(0,0)
var can_move = true

func change_type(new_type):
	#print("my new type is ", new_type)
	if monitorable:
		monitorable = false
	type = new_type
	monitorable = true


func enable_move():
	can_move = true
