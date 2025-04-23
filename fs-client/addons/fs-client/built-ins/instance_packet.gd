extends FCCustomPacket
class_name InstancePacket

static var net_instances:Dictionary[int, Dictionary] = {}
static var my_instances_uuid:Dictionary[Node, int] = {}


static var _packet_instance: InstancePacket = InstancePacket.new()

var scene_path: String

var spawn_path: NodePath

enum ActionType{
	SPAWN,
	DESPAWM,
}
var action:ActionType

static func spawn(scene_path:String, spawn_path:NodePath = ""):
	_packet_instance.action = ActionType.SPAWN
	FCRoom.send_packet(_packet_instance)
	pass

func _before_sending():
	transfer_type = TransferType.BROADCAST
	pass

func _on_arrival():
	
	pass

static func _get_instance(owner_uuid:int, instance_uuid:int)->Node:
	return net_instances[owner_uuid][instance_uuid]
	pass

static func _remove_instance(owner_uuid:int, instance_uuid:int):
	var instance_node:Node = net_instances[owner_uuid][instance_uuid]
	my_instances_uuid.erase(instance_node)
	net_instances[owner_uuid].erase(instance_uuid)
	instance_node.queue_free()
	
	pass
