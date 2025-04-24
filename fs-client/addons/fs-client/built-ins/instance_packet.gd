extends FCCustomPacket
class_name InstancePacket

static var net_instances:Dictionary[int, Dictionary] = {}
static var my_instances_uuid:Dictionary[Node, int] = {}


static var _packet_instance: InstancePacket = InstancePacket.new()

var scene_path: String

var spawn_path: NodePath

var instance_uuid: int
enum ActionType{
	SPAWN,
	DESPAWM,
}
var action:ActionType

static func spawn(scene_path:String, spawn_path:NodePath = ""):
	_packet_instance.action = ActionType.SPAWN
	_packet_instance.scene_path = scene_path
	_packet_instance.spawn_path = spawn_path
	FCRoom.send_packet(_packet_instance)
	pass

func _before_sending():
	transfer_type = TransferType.BROADCAST
	var new_uuid:int = randi()
	var my_instances:Dictionary = net_instances.get_or_add(FClient.uuid, {})
	while my_instances.has(new_uuid): new_uuid = randi()
	instance_uuid = new_uuid
	print(instance_uuid)
	pass

static var scene_cache:Dictionary[String, PackedScene] = {}
func _on_arrival():
	if action == ActionType.SPAWN:
		if !scene_cache.has(scene_path):
			scene_cache[scene_path] = load(scene_path)
		var new_instance:Node = scene_cache[scene_path].instantiate()
		
		var my_instances:Dictionary = net_instances.get_or_add(FClient.uuid, {})
		
		
		my_instances_uuid[new_instance] = instance_uuid
		
		net_instances.get_or_add(sender_uuid, {})[instance_uuid] = new_instance
		new_instance.name = str(sender_uuid)
		
		new_instance.owner_uuid = sender_uuid

		#new_instance.set_multiplayer_authority(sender_uuid)
		
		
		Engine.get_main_loop().root.get_node(spawn_path).add_child(new_instance)
		print("Sender: ", sender_uuid)
		print("Instance UUID: ", instance_uuid)
		print("Owner UUID: ", new_instance.owner_uuid)
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
