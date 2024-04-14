extends Creature


@export var movement_boudnaries : ColorRect
var movement_area

var idle_pos = Vector2.ZERO


func _ready():
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0).get_size() * $AnimatedSprite2D.scale)
	movement_area = movement_boudnaries.get_rect()#global_position - $MovementArea.size
	print(movement_area)
	find_new_pos()


func _physics_process(delta):
	if can_move:
		position = position.lerp(idle_pos, delta * 2)
		if position.distance_to(idle_pos) < 1:
			find_new_pos()


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_mask == 0:
		can_move = false
		Console.show_popup(self)


func _on_area_entered(area):
	if area.type != "ghost":
		Console.add_message(type + " is eating " + area.type)
		area.die()
	#area.queue_free()


func find_new_pos():
	#t = 0
	#var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 2
	idle_pos = Vector2(randf_range(movement_area.position.x, movement_area.end.x), randf_range(movement_area.position.y, movement_area.end.y))#global_position + movement_area
	#idle_pos = idle_pos.clamp(Vector2.ZERO, movement_area)
	#start_pos = global_position
	#print(idle_pos)
