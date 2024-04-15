extends Creature


func _on_area_entered(area):
	if area != self:
		area.devolve()
	play_animation("time machine")
