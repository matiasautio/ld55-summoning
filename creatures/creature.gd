extends Area2D

class_name Creature

@export var type = "taxi"
var original_type = ""
var size = Vector2(0,0)
@export var is_active = false
@export var can_move = true
var screen_size
var clamp_start = Vector2(250, 64)#Vector2.ZERO

# audio
@export var audio_player : AudioStreamPlayer2D

func _ready():
	original_type = type
	screen_size = get_viewport_rect().size
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture(type, 0).get_size() * $AnimatedSprite2D.scale)
	type = "???"
	other_init()


func other_init():
	pass


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_mask == 0:
		can_move = false
		Console.show_popup(self)


func change_type(new_type):
	#print("my new type is ", new_type)
	if monitorable:
		monitorable = false
	type = new_type
	monitorable = true


func enable_move():
	can_move = true
	

func activate_creature():
	is_active = true
	play_animation(original_type)
	
	
func die():
	return false
func devolve():
	pass
func evolve():
	pass
func move(_passenger):
	pass


func play_animation(animation_name):
	var animations = $AnimatedSprite2D.sprite_frames.get_animation_names()
	if animations.has(animation_name):
		$AnimatedSprite2D.animation = animation_name
		$AnimatedSprite2D.play()


func reset():
	is_active = false
	type = "???"
