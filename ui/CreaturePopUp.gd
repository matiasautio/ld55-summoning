extends MarginContainer


var creature_types = ["human", "ghost", "egg", "wolf", "taxi", "time machine", "fire", "whale", "island", "donut"]
var current_creature = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var value = 0
	for type in creature_types:
		print(value)
		var new_button = $VBoxContainer/Type.duplicate()
		new_button.text = type
		$VBoxContainer.add_child(new_button)
		#new_button.position += Vector2(0, 50 * value)
		new_button.pressed.connect(button_pressed.bind(new_button))
		#if value == 0:
			#new_button.pressed.connect(on_human_pressed)
		#elif value == 1:
			#new_button.pressed.connect(on_wolf_pressed)
		#elif value == 2:
			#new_button.pressed.connect(on_taxi_pressed)
		value += 1
	$VBoxContainer/Type.queue_free()


func _process(delta):
	pass


func button_pressed(button):
	current_creature.change_type(button.text)
	apply_changes_to_creature()


func on_human_pressed():
	current_creature.change_type("human")
	apply_changes_to_creature()


func on_wolf_pressed():
	current_creature.change_type("wolf")
	apply_changes_to_creature()


func on_taxi_pressed():
	current_creature.change_type("taxi")
	apply_changes_to_creature()


func apply_changes_to_creature():
	current_creature.enable_move()
	$VBoxContainer/CurrentType.text = "[center]" + current_creature.type
	$ClosePopUpDelay.start()
	current_creature = null


func _on_close_pop_up_delay_timeout():
	visible = false
