extends Node


@onready var audio_player = $AudioStreamPlayer
@export var wet_sfx : AudioStream
@export var death_sfx : AudioStream
@export var egg_sfx : AudioStream
@export var time_machine_sfx : AudioStream


#func _ready():
	#play_audio("wet")

func get_audio(wanted_audio):
	var audio
	if wanted_audio == "wet":
		audio = wet_sfx
	elif wanted_audio == "die":
		audio = death_sfx
	elif wanted_audio == "hatch":
		audio = egg_sfx
	elif wanted_audio == "time machine":
		audio = time_machine_sfx
	return audio


func play_audio(audio):
	if !audio_player.is_playing:
		if audio == "wet":
			audio_player.stream = wet_sfx
			audio_player.play()
		if audio == "die":
			audio_player.stream = death_sfx
			audio_player.play()
		if audio == "hatch":
			audio_player.stream = egg_sfx
			audio_player.play()
		if audio == "time machine":
			audio_player.stream = time_machine_sfx
			audio_player.play()
