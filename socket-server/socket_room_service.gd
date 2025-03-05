extends Node
class_name FSRoomService
var server:FSServer = get_parent()

var lobby_peer_list:Array[PacketPeer] = []


func hand_over_user(user:FSUser):
	lobby_peer_list.append(user.peer)
	pass


func _ready() -> void:
	
	while true:
		for peer in lobby_peer_list:
			if peer.get_available_packet_count() != 0:
				var packet = bytes_to_var(peer.get_packet())
				if packet is RoomServicePacket:
					handle_incoming_room_req(packet)
			await get_tree().process_frame
	pass

func handle_incoming_room_req(packet:RoomServicePacket):
	# TODO: Handle this and add symlinks, and make room service package contain something
	pass
