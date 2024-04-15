extends Creature


@export var movement_boudnaries : ColorRect
var movement_area

var idle_pos = Vector2.ZERO
var speed = 150


func _ready():
	original_type = "wolf"
	size = Vector2($AnimatedSprite2D.sprite_frames.get_frame_texture(type, 0).get_size() * $AnimatedSprite2D.scale)
	movement_area = movement_boudnaries.get_rect()#global_position - $MovementArea.size
	print(movement_area)
	find_new_pos()


func _physics_process(delta):
	if can_move:
		var velocity = Vector2.ZERO
		var direction_to_target = Vector2.ZERO
		direction_to_target = (idle_pos - global_position).normalized()
		#print(direction_to_target)
		velocity = direction_to_target
		if global_transform.origin.distance_to(idle_pos) < 2:
			find_new_pos()
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			if velocity > Vector2.ZERO:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
			#if state == 1:
				#play_animation("human_walk")
		#else:
			#if state == 1:
				#play_animation("human")
		position += velocity * delta
		#position = position.lerp(idle_pos, delta * 2)
		#if position.distance_to(idle_pos) < 1:
			#find_new_pos()


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
