extends Object
class_name FSRoomPlugin



var room:FSRoomWraper

enum TransferType{
	BROADCAST, ## Send to everyone in the room
	BROADCAST_EXCLUDE_SELF, ## Broadcast to everyone in room *EXCEPT* yourself (the sender)
	HOST, ## Send only to the current host (host is gotten during)
	PERSONAL ## Send to specific user specified by target_uuid
}

## Executed when room starts, before host has entered
func _room_start():
	pass

## Executed once every room tick (room tick-rate is configured in server-config.yaml)
func _room_tick():
	pass
## When a client in the room send a server packet (a specific fucntion on client that sends a dictionary only to the server)
func _on_server_packet(payload:Dictionary, sender_uuid:int):
	pass

## The custom packet as a dictionary, might be confusing to use.					
## Hihgly Reccomend using "print(payload)" to see how custom packets are structured
func _on_custom_packet(payload:Dictionary, sender_uuid:int, transfer_type:TransferType):
	pass

## When a user joins the room, this will only be triggered after player has confirmed the join, meaning also subsequently, the person trying to host will always be 
func _on_user_join(leaving_uuid:int):
	pass
## When a user leaves (or is kicked) this is triggered.
func _on_user_leave(joining_uuid:int):
	pass
