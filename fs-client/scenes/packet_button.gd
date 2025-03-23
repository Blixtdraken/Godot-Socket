extends Button

@onready var line:LineEdit = $Payload

var packet:TestPacket = TestPacket.new()
func _pressed() -> void:
	
	packet.payload_text = line.text
	FCRoom.send_packet(packet)
	
	pass
