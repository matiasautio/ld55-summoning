extends Area2D

@export var type = "taxi"
var size = Vector2(0,0)

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
	#Console.add_message(type + " is getting chewed")


func _physics_process(delta):
	if should_move:
		position = position.lerp(new_pos, delta * 2)
		if position.distance_to(new_pos) < size.x / 2:
			#print("reached taxi goal")
			passenger.reparent(get_parent())
			passenger.can_move = true
			should_move = false
	position = position.clamp(Vector2(313,64), screen_size)


func move(_passenger):
	if !should_move:
		passenger = _passenger
		passenger.can_move = false
		passenger.reparent(self)
		passenger.position = Vector2.ZERO#$RidingPos.position
		print(passenger.position, $RidingPos.position, position)
		movement = movement * -1
		new_pos = global_position + Vector2(movement, 0)
		new_pos = new_pos.clamp(Vector2(313,64), screen_size)
		#print(new_pos)
		should_move = true


func _on_passenger_seat_area_exited(area):
	pass
	#move(area)


func specific_goal():
	return $RidingPos.global_position
