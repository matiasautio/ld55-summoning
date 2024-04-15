extends Control

@onready var creature_popup = $CanvasLayer/CreaturePopUp
var current_creature = null
var screen_size


func _ready():
	screen_size = get_viewport_rect().size
	if OS.get_name() == "macOS":
		DisplayServer.window_set_size(Vector2(1920*1.25, 1080*1.25))
		DisplayServer.window_set_position(Vector2(1920/5.5, 1080/3))


func add_message(message):
	if $CanvasLayer/Message.text != "":
		$CanvasLayer/Message.text += "\n"
	$CanvasLayer/Message.text += message


func show_popup(creature):
	creature_popup.visible = true
	creature_popup.global_position = creature.global_position + Vector2(creature.size.x / 2, 0)
	creature_popup.global_position = creature_popup.global_position.clamp(Vector2.ZERO, screen_size - Vector2(128, 355))
	$CanvasLayer/CreaturePopUp/VBoxContainer/CurrentType.text = "[center]" + creature.type
	creature_popup.current_creature = creature


func _input(event):
	if event.is_action_pressed("hide_popup"):
		creature_popup.visible = false
		if creature_popup.current_creature != null:
			creature_popup.current_creature.enable_move()
