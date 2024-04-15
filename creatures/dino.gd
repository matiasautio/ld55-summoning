extends Creature


@export var movement_boudnaries : ColorRect
var movement_area
var idle_pos = Vector2.ZERO
var speed = 50
var direction = 1


func other_init():
	movement_area = movement_boudnaries.get_rect()
	find_new_pos()


func _physics_process(delta):
	if can_move and is_active:
		var velocity = Vector2.ZERO
		var direction_to_target = Vector2.ZERO
		direction_to_target = ((idle_pos - global_position) * direction).normalized()
		velocity = direction_to_target
		if global_transform.origin.distance_to(idle_pos) < 10:
			find_new_pos()
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			if velocity < Vector2.ZERO:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		position += velocity * delta
		position = position.clamp(Vector2(313,64), screen_size)

func find_new_pos():
	#t = 0
	#var movement_area = Vector2(randf_range(-size.x, size.x), randf_range(-size.y, size.y)) * 2
	idle_pos = Vector2(randf_range(movement_area.position.x, movement_area.end.x), randf_range(movement_area.position.y, movement_area.end.y))
	idle_pos = idle_pos.clamp(Vector2(313,64), screen_size)
	print(idle_pos)
	#idle_pos = Vector2(randf_range(313, screen_size.x), randf_range(54, screen_size.y))


func _on_vision_area_area_entered(area):
	if area.type == "egg":
		idle_pos = area.global_position
	elif area.type == "fire":
		direction = -1
		$Scared.start()
		Console.add_message(type + " is afraid of " + area.original_type)


func _on_scared_timeout():
	direction = 1
