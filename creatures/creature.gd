extends Area2D

class_name Creature

@export var type = "taxi"
var size = Vector2(0,0)
var can_move = true
var screen_size


func _ready():
	screen_size = get_viewport_rect().size
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0).get_size() * $AnimatedSprite2D.scale)


func change_type(new_type):
	#print("my new type is ", new_type)
	if monitorable:
		monitorable = false
	type = new_type
	monitorable = true


func enable_move():
	can_move = true


func die():
	pass


func play_animation(animation_name):
	$AnimatedSprite2D.animation = animation_name
	$AnimatedSprite2D.play()
