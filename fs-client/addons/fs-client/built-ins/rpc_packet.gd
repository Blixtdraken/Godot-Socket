extends FCCustomPacket
class_name RPCPacket


static var _packet_instance:RPCPacket = RPCPacket.new()




func _before_sending():
	transfer_type = TransferType.BROADCAST
	pass

func _on_arrival():
	
	pass
