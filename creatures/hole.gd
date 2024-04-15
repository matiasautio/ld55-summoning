extends Creature

@export var hole_buddy : Area2D
var can_teleport = true

func _on_teleport_area_area_entered(area):
	if area != self and can_teleport and is_active:
		area.global_position = hole_buddy.global_position
		start_cooldown()
		hole_buddy.start_cooldown()


func start_cooldown():
	can_teleport = false
	$TeleportCooldown.start()


func _on_teleport_cooldown_timeout():
	can_teleport = true
