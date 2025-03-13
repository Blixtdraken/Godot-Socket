extends Node2D



func _ready() -> void:
	FCLobby.signals.room_req_response.connect(_on_room_req)
	pass

func _on_room_req(room_id:String, approved:bool, disapproval_msg:String):
	if approved:
		Debug.values_list["room_id"] = room_id
		get_tree().change_scene_to_packed(preload("res://room.tscn"))
	else:
		print(disapproval_msg)
	pass

var written_code:String = ""

func _on_join_button_pressed() -> void:
	FCLobby.req_to_join_room(written_code)
	pass # Replace with function body.


func _on_host_button_pressed() -> void:
	var room_config: FRoomConfig = preload("res://addons/fs-client/built-ins/built_in_room_config.tres")
	FCLobby.req_to_host_room(written_code)
	pass # Replace with function body.


func _on_line_edit_text_changed(new_text: String) -> void:
	written_code = new_text
	pass # Replace with function body.
