extends Node2D

@export var user_list:UserList



func _ready() -> void:
	var lobby_signals:FCLobbySignals = FCLobby.signals
	var room_signals:FCRoomSignals = FCRoom.signals
	lobby_signals.lobby_joined.connect(_on_lobby_joined)
	room_signals.user_joined.connect(_on_user_join)
	room_signals.user_left.connect(_on_user_leave)
	room_signals.join_info_received.connect(_on_join_info_received)
	room_signals.host_change.connect(_on_host_change)
	room_signals.custom_packet_received.connect(_on_custom_packet_received)
	if FClient.instance.client_peer:
		FCRoom.confirm_join()
	
	pass

func _on_lobby_joined():
	get_tree().change_scene_to_packed(load("res://scenes/room_ui.tscn"))
	pass


func _on_leave_pressed() -> void:
	FCRoom.leave_room()
	pass # Replace with function body.

func _on_join_info_received():
	for uuid in FCRoom.instance.user_list:
		user_list.add_entry(uuid)
	Debug.values_list["am_host"] = (FClient.uuid == FCRoom.instance.host_uuid)

	pass

var uuid_to_user_list_idx:Dictionary[int, int]
func _on_user_join(user_uuid:int):
	print("User " + str(user_uuid) + " joined")
	user_list.add_entry(user_uuid)
	user_list.current_colored_host = FCRoom.instance.host_uuid
	pass
func _on_user_leave(user_uuid:int):
	user_list.remove_entry(user_uuid)
	print("User " + str(user_uuid) + " left")
	pass

func get_selected_user()->int:
		return user_list.get_selected_items()[0]

func _on_item_list_item_selected(index: int) -> void:
	pass # Replace with function body.


func _on_kick_pressed() -> void:
	FCRoom.kick_user(user_list.selected_user)
	pass # Replace with function body.


func _on_transfer_host_pressed() -> void:
	FCRoom.transfer_host(user_list.selected_user)
	pass # Replace with function body.

func _on_host_change(new_host_uuid:int):
	Debug.values_list["am_host"] = (FClient.uuid == new_host_uuid)
	user_list.current_colored_host = new_host_uuid
	pass

func _on_custom_packet_received(packet:FCCustomPacket):
	if packet is TestPacket:
		packet = packet as TestPacket
		%Response.text = packet.payload_text
	pass
