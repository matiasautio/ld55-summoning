extends Creature

var new_pos = Vector2.ZERO
var movement = -1000
var should_move = false
var passenger = null


func _physics_process(delta):
	if should_move and can_move and is_active:
		passenger.position = $RidingPos.global_position
		position = position.lerp(new_pos, delta * 2)
		if position.distance_to(new_pos) < size.x / 2:
			print("taxi trip over")
			should_move = false
			passenger.can_move = true
			passenger.current_action = null
			passenger.find_new_pos()
			passenger = null
	position = position.clamp(clamp_start, screen_size)#Vector2(313,64), screen_size)
	#print(position)



func move(_passenger):
	if !should_move and is_active:
		passenger = _passenger
		passenger.can_move = false
		passenger.position = $RidingPos.global_position
		movement = movement * -1
		if movement > 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		new_pos = global_position + Vector2(movement, 0)
		new_pos = new_pos.clamp(clamp_start, screen_size)
		#print(new_pos)
		should_move = true
		Console.game_manager.transport("taxi")


func _on_passenger_seat_area_exited(area):
	pass
	#move(area)


func specific_goal():
	return $RidingPos.global_position

