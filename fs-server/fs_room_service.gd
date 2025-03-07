extends Node
class_name FSRoomService
var server:FSServer = get_parent()

var users_in_loby:Dictionary[int,FSUser] = []

var uuid_to_room_id:Dictionary[int, String] = {}

var room_id_to_

func hand_over_user(user:FSUser):
	print("Added " + str(user.uuid) + " to lobby.")
	users_in_loby.append(user)
	
	pass


func _ready() -> void:
	
	while true:
		await get_tree().process_frame
		for user in users_in_loby.values():
			if user.peer.get_available_packet_count() != 0:
				var packet = FSSerializer.bytes_to_object(user.peer.get_packet())
				print(packet)
				if packet is FSRoomServicePacket:
					handle_incoming_room_req(packet)
			await get_tree().process_frame
	pass

func handle_incoming_room_req(packet:FSRoomServicePacket):
	print(FSSerializer.object_to_dictionary(packet))
	
	# TODO: Handle this and add symlinks, and make room service package contain something
	pass
