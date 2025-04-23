extends Object
class_name FCRoom

static var instance:FCRoom
static var signals:FCRoomSignals

var room_id:String = ""

var host_uuid:int = -1

static var user_list:Array[int] = []

static func confirm_join():
	
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"room_join_confirm"
		}
	))
	pass

static func leave_room():
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"room_leave"
		}
	))
	pass

static func transfer_host(new_host_uuid:int):
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"room_host_transfer",
			"target_uuid":new_host_uuid
		}
	))

	pass

static func kick_user(user_uuid:int):
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"room_kick",
			"target_uuid":user_uuid
		}
	))
	pass

static func send_packet(packet:FCCustomPacket):
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"custom_packet",
			"transfer_type":packet.transfer_type,
			"payload": FSerializer.object_to_dictionary(packet)
		}
	))
	pass

static func send_server_packet(payload:Dictionary):
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"to_server_packet",
			"payload":payload
		}
	))

func _init() -> void:
	FClient.signals._packet_received.connect(_on_packet_received)

func _on_packet_received(packet:Dictionary):
	
	if room_id.is_empty():
		return
	match packet["packet_type"]:
		"room_join_info":
			host_uuid = packet["host_uuid"]
			user_list = packet["user_list"] ## Excluding urself, ur own client is added when room user packet is received
			signals.join_info_received.emit()
		"room_user_joined":
			var user_uuid:int = packet["user_uuid"]
			signals.user_joined.emit(user_uuid)
		"room_user_left":
			var user_uuid:int = packet["user_uuid"]
			signals.user_left.emit(user_uuid)
		"room_host_change":
			host_uuid = packet["target_uuid"]
			signals.host_change.emit(host_uuid)
		"room_custom_packet":
			handle_custom_packet(
				FSerializer.dictionary_to_object(
					packet["payload"]
				),
				packet["sender_uuid"]
			)
		"from_server_packet":
			signals.server_packet_received.emit(packet["payload"])
	pass

func handle_custom_packet(packet:FCCustomPacket, sender_uuid:int):
	packet.sender_uuid = sender_uuid
	packet._on_arrival()
	signals.custom_packet_received.emit(packet)
	pass
