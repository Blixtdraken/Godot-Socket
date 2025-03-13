extends Object
class_name FCLobby

static var instance:FCLobby
static var signals:FCLobbySignals

static func req_to_host_room(room_id:String):
	var peer:PacketPeer = FClient.instance.client_peer
	var packet:Dictionary = {
			"packet_type":"room_host_req",
			"room_id":room_id,
		}
	peer.put_packet(var_to_bytes(packet))
	pass

static func req_to_join_room(room_id:String):
	var peer:PacketPeer = FClient.instance.client_peer
	var packet:Dictionary = {
			"packet_type":"room_join_req",
			"room_id":room_id,
		}
	peer.put_packet(var_to_bytes(packet))
	pass


func _init() -> void:
	FClient.instance.signals._packet_received.connect(_on_packet_received)
	pass


func _on_packet_received(dict:Dictionary):
	match dict["packet_type"]:
		"lobby_join":
			print("Joined Lobby")
			signals.lobby_joined.emit()
		"room_req_result":
			if dict["approval"]:
				FCRoom.instance.room_id = dict["room_id"]
			signals.room_req_response.emit(dict["room_id"], dict["approval"], dict["error_msg"])
	pass
