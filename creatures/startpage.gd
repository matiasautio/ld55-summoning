extends CanvasLayer


func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://levels/level.tscn")


func _on_credits_pressed():
	$Credits.visible = true
