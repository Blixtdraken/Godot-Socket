extends Node
class_name FSRoomService

var client_peer:PacketPeer =null

var current_room:FSRoom

signal room_request_result(status:FSRoomServicePacket.RequestResult, target_rom_id:String)

func _ready() -> void:
	FSClient.server_connected.connect(_on_server_connected)
	pass

func _on_packet_received(packet:Object):
	_handle_room_service_package(packet)
	pass

func _on_server_connected():
	client_peer = FSClient.client_peer
	FSClient._packet_received.connect(_on_packet_received)
	pass

func _handle_room_service_package(packet:FSRoomServicePacket):
	if packet is FSRoomServicePacket:
		if packet.request_type in [
			FSRoomServicePacket.RequestType.REQ_HOST,
			FSRoomServicePacket.RequestType.REQ_JOIN
		] and !current_room:
			if 
			current_room = FSRoom.new()
			FSClient._packet_received.connect(_on_packet_received)
			current_room.start(client_peer)
	pass

func request_to_join_room(room_id:String):
	print("Requesting to join room of id \"" + room_id + "\"")
	
	var room_service_packet:FSRoomServicePacket = FSRoomServicePacket.new()
	room_service_packet.request_type = FSRoomServicePacket.RequestType.REQ_JOIN
	room_service_packet.room_target = room_id
	
	client_peer.put_packet(FSSerializer.object_to_bytes(room_service_packet))
	pass

func request_to_host_room(room_id:String, room_config:FSRoomConfig):
	print("Requesting to host room of id " + room_id)
	pass
