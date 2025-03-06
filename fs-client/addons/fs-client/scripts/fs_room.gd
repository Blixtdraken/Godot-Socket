extends Object
class_name FSRoom

var client_peer:PacketPeer

var is_host:bool = false

func start(client_peer:PacketPeer):
	self.client_peer = client_peer
	client_peer.put_packet(FSSerializer.object_to_bytes(FSRoomJoinConfirmPacket.new()))
	pass

func _on_packet_received(packet:Object):
	pass
