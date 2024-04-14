extends Control

@onready var creature_popup = $CanvasLayer/CreaturePopUp
var current_creature = null
var screen_size


func _ready():
	screen_size = get_viewport_rect().size


func add_message(message):
	if $CanvasLayer/Message.text != "":
		$CanvasLayer/Message.text += "\n"
	$CanvasLayer/Message.text += message


func show_popup(creature):
	creature_popup.visible = true
	creature_popup.global_position = creature.position + Vector2(creature.size.x, 0)
	creature_popup.global_position = creature_popup.global_position.clamp(Vector2.ZERO, screen_size)
	$CanvasLayer/CreaturePopUp/VBoxContainer/CurrentType.text = "[center]" + creature.type
	creature_popup.current_creature = creature
