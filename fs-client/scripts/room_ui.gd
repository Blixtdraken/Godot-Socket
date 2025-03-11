extends Node2D



func _ready() -> void:
	pass

var written_code:String = ""

func _on_join_button_pressed() -> void:

	pass # Replace with function body.


func _on_host_button_pressed() -> void:
	var room_config: FSRoomConfig = preload("res://addons/fs-client/built-ins/built_in_room_config.tres")

	pass # Replace with function body.


func _on_line_edit_text_changed(new_text: String) -> void:
	written_code = new_text
	pass # Replace with function body.
