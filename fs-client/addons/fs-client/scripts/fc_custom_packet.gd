extends Object
class_name FCCustomPacket

enum TransferType{
	BROADCAST, ## Send to everyone in the room
	BROADCAST_EXCLUDE_SELF, ## Broadcast to everyone in room *EXCEPT* yourself (the sender)
	HOST, ## Send only to the current host (host is gotten during)
	PERSONAL ## Send to specific user specified by target_uuid
}

var transfer_type:TransferType = TransferType.BROADCAST ## How the packet should be sent on the server

var sender_uuid:int = -1 ## Only availbale on client it is sent to, is -1 on local client

var target_uuid:int = -1

## Happens on LOCAL client before it is sent
func _before_sending():
	pass

## Happens on client it is sent to before it is handed over in a room signal
func _on_arrival():
	pass
