extends CanvasLayer


func _on_return_pressed():
	$Egg.play()


func _on_egg_animation_finished():
	$Egg.frame = 0
	visible = false
