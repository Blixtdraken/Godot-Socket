extends Node2D

@onready var connect_button:Button = $CanvasLayer/Button
@onready var error_label:Label = $CanvasLayer/ErrorLabel
@onready var connecting_label:Label = $CanvasLayer/ConnectingLabel

func _ready() -> void:
	
	FSClient.server_connect_scene = preload("res://scenes/main.tscn")
	FSClient.server_connected.connect(_on_server_connect)
	FSClient.server_connection_failed.connect(_on_server_connection_failed)
	pass

func _process(delta: float) -> void:
	
	pass

func _on_connect_pressed() -> void:
	connect_button.hide()
	connecting_label.show()
	error_label.text = ""
	if OS.has_feature("web"):
		FSClient.connect_to_web_server("127.0.0.1", 5555)
	else:
		FSClient.connect_to_server("127.0.0.1", 5555)
	pass # Replace with function body.




func _on_server_connect():
	Debug.values_list["uuid"] = FSClient.uuid
	get_tree().change_scene_to_packed(preload("res://scenes/room_ui.tscn"))
	pass

func _on_server_connection_failed():
	error_label.text = "Connection failed???"
	connecting_label.hide()
	connect_button.show()
	pass
