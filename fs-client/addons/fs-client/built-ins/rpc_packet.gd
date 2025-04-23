extends FCCustomPacket
class_name RPCPacket


static var _packet_instance:RPCPacket = RPCPacket.new()


var method:Callable
var args:Array[Variant]

static func rpc(method:Callable, args:Array[Variant]):
	var instance:Node = method.get_object()
	_packet_instance.method = method
	_packet_instance.args = args
	if instance.get_multiplayer_authority() == FClient.uuid:
		FCRoom.send_packet(_packet_instance)
	pass

func _before_sending():
	transfer_type = TransferType.BROADCAST
	pass

func _on_arrival():
	method.callv(args)
	pass
