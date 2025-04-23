
extends FSRoomPlugin

## Executed when room starts, before host has entered
func _room_start():
	pass

## Executed once every room tick (room tick-rate is configured in server-config.yaml)
func _room_tick():
	pass
## When a client in the room send a server packet (a specific fucntion on client that sends a dictionary only to the server)
func _on_server_packet(payload:Dictionary, sender_uuid:int):
	pass

## When a user joins the room, this will only be triggered after player has confirmed the join, meaning also subsequently, the person trying to host will always be 
func _on_user_join(leaving_uuid:int):
	pass
## When a user leaves (or is kicked) this is triggered.
func _on_user_leave(joining_uuid:int):
	pass
