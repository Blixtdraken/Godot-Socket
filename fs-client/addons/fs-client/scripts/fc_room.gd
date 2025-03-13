extends Object
class_name FCRoom

static var instance:FCRoom
static var signals:FCRoomSignals

var room_id:String = ""

var host:bool = false


static func confirm_join():
	FClient.instance.client_peer.put_packet(var_to_bytes(
		{
			"packet_type":"room_join_confirm"
		}
	))
	pass

func _init() -> void:
	FClient.signals._packet_received.connect(_on_packet_received)

func _on_packet_received(packet:Dictionary):
	if room_id.is_empty():
		return
	print(packet)
	pass
