extends FCCustomPacket
class_name TestPacket

var payload_text:String = "wowie"


func _before_sending():
	transfer_type = TransferType.BROADCAST
	pass

func _on_arrival():
	print(payload_text)
	pass
