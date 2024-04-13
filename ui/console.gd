extends Control


func add_message(message):
	if $CanvasLayer/Message.text != "":
		$CanvasLayer/Message.text += "\n"
	$CanvasLayer/Message.text += message
	
