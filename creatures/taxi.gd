extends Creature

var new_pos = Vector2.ZERO
var movement = 1000
var should_move = false
var passenger = null
var screen_size


func _ready():
	screen_size = get_viewport_rect().size
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0).get_size() * $AnimatedSprite2D.scale)


func die():
	pass


func _physics_process(delta):
	if should_move and can_move:
		passenger.position = $RidingPos.global_position
		position = position.lerp(new_pos, delta * 2)
		if position.distance_to(new_pos) < size.x / 2:
			should_move = false
			passenger.can_move = true
			passenger.current_action = null
			passenger.find_new_pos()
			passenger = null
	position = position.clamp(Vector2(313,64), screen_size)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_mask == 0:
		can_move = false
		Console.show_popup(self)


func move(_passenger):
	if !should_move:
		passenger = _passenger
		passenger.can_move = false
		passenger.position = $RidingPos.global_position
		movement = movement * -1
		new_pos = global_position + Vector2(movement, 0)
		new_pos = new_pos.clamp(Vector2(313,64), screen_size)
		should_move = true


func _on_passenger_seat_area_exited(area):
	pass
	#move(area)


func specific_goal():
	return $RidingPos.global_position

