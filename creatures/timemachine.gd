extends Creature


func _on_area_entered(area):
	if is_active:
		if area != self:
			area.devolve()
		play_animation("time machine")
		play_audio("time machine")

func play_audio(audio):
	if !audio_player.is_playing:
		audio_player.stream = AudioManager.get_audio(audio)
		audio_player.play()
