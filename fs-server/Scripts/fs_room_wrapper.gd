extends Object
class_name FSRoomWraper

var base_room:FSRoom


func _init(base_room:FSRoom) -> void:
	self.base_room = base_room


func send_server_packet_to_uuid(payload:Dictionary, uuid:int):
	if base_room.user_list.has(uuid):
		var user:FSUser = base_room.user_list[uuid]
		user.peer.put_packet(var_to_bytes(
			{
				"packet_type":"from_server_packet",
				"payload":payload
			}
		))
	pass

func broadcast_server_packet(payload:Dictionary, uuid:int):
	for user:FSUser in base_room.user_list.values():
		user.peer.put_packet(var_to_bytes(
			{
				"packet_type":"from_server_packet",
				"payload":payload
			}
		))
		pass
	pass


func get_user_uuid_list() -> Array[int]:
	return base_room.user_list.keys()
	pass
	
func get_host_uuid():
	return base_room.host_user.uuid
	pass
