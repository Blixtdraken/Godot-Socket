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
	pass
