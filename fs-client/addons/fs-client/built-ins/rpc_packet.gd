extends FCCustomPacket
class_name RPCPacket


static var _packet_instance:RPCPacket = RPCPacket.new()


var method:String
var args:Array[Variant]
var instance_uuid:int
static func rpc(method:Callable, args:Array[Variant] = []):
	var instance:Node = method.get_object()
	_packet_instance.method = method.get_method()
	_packet_instance.args = args
	_packet_instance.instance_uuid = InstancePacket.my_instances_uuid[instance]
	if instance.owner_uuid == FClient.uuid:
		FCRoom.send_packet(_packet_instance)
	pass

func _before_sending():
	transfer_type = TransferType.BROADCAST
	pass

func _on_arrival():
	var instances:Dictionary = InstancePacket.net_instances.get_or_add(sender_uuid, {})
	if instances.has([instance_uuid]):
		var instance = instances[instance_uuid]
		var callable:Callable = Callable(instance, method)
	
		callable.callv(args)
	pass
