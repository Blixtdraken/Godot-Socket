extends Node
class_name FCCustomPacket

enum TransferType{
	TRANSFER_TYPE_BROADCAST,
	TRANSFER_TYPE_BROADCAST_EXCLUDE_SELF, # Broadcast to everyone in room
	TRANSFER_TYPE_HOST, # Send only to the current host (host is gotten during)
	TRANSFER_TYPE_PERSONAL
}

var transfer_type:TransferType = TransferType.TRANSFER_TYPE_BROADCAST

var sender_id:int = -1


## Happens on client it is sent to
func _on_arrival():
	pass
