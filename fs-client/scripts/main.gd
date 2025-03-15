extends Node2D

@onready var connect_button:Button = $CanvasLayer/Button
@onready var error_label:Label = $CanvasLayer/ErrorLabel
@onready var connecting_label:Label = $CanvasLayer/ConnectingLabel

func _ready() -> void:
	Debug.values_list.erase("uuid")
	FClient.server_connect_scene = preload("res://scenes/main.tscn")
	FClient.signals.server_connected.connect(_on_server_connect)
	FClient.signals.server_connection_failed.connect(_on_server_connection_failed)
	FCLobby.signals.lobby_joined.connect(_on_lobby_join)
	


func _process(delta: float) -> void:
	
	pass

func _on_connect_pressed() -> void:
	connect_button.hide()
	connecting_label.show()
	error_label.text = ""
	var ip:String = "127.0.0.1"
	if OS.has_feature("web"):
		FClient.connect_to_web_server(ip, 55555)
	else:
		FClient.connect_to_server(ip, 55555)
	pass




func _on_server_connect():
	Debug.values_list["uuid"] = FClient.uuid
	pass
	
func _on_lobby_join():
	get_tree().change_scene_to_packed(preload("res://scenes/room_ui.tscn"))
	pass
func _on_server_connection_failed():
	error_label.text = "Connection failed???"
	connecting_label.hide()
	connect_button.show()
	pass
