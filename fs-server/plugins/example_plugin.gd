extends FSRoomPlugin


## UUID to objects that person owns
var net_instances:Dictionary[int, Dictionary] = {}

## When a client in the room send a server packet (a specific fucntion on client that sends a dictionary only to the server)
func _on_server_packet(payload:Dictionary, sender_uuid:int):
	if payload["packet_type"] == "spawn_instance":
		pass
	pass

## The custom packet as a dictionary, might be confusing to use,
## Hihgly Reccomend using *print(payload)* to see how custom packets are structured
var active_instances:Dictionary[int,Dictionary] = {}
func _on_custom_packet(payload:Dictionary, sender_uuid:int, transfer_type:TransferType):
	if transfer_type == TransferType.BROADCAST and payload["class_name"] == "InstancePacket":
		pass

	pass

## When a user joins the room, this will only be triggered after player has confirmed the join, meaning also subsequently, the person trying to host will always be 
func _on_user_join(joining_uuid:int):
	print("Use joined : " + str(joining_uuid))
	pass
## When a user leaves (or is kicked) this is triggered.
func _on_user_leave(leaving_uuid:int):
	print("Use left : " + str(leaving_uuid))
	pass
