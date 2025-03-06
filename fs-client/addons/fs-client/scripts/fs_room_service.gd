extends Node
class_name FSRoomService

var client_peer:PacketPeer =null

enum RequestResults{
	JOIN_ERR_ROOM_NOT_FOUND,
	HOST_ERR_ROOM_EXISTS,
	JOIN_ERR_ROOM_FULL,
	SUCCES,
}
enum {
	JOIN_ERR_ROOM_NOT_FOUND,
	HOST_ERR_ROOM_EXISTS,
	JOIN_ERR_ROOM_FULL,
	SUCCES,
}

signal room_request_result(status:RequestResults, target_rom_id:String)

func _ready() -> void:
	FSClient.server_connected.connect(_on_server_connected)
	pass

func _on_server_connected():
	client_peer = FSClient.client_peer
	pass

func request_to_join_room(room_id:String):
	print("Requesting to join room of id " + room_id)
	
	var room_service_packet:FSRoomServicePacket = FSRoomServicePacket.new()
	room_service_packet.request_type = FSRoomServicePacket.RequestType.REQ_JOIN
	room_service_packet.room_target = room_id
	
	client_peer.put_packet(FSSerializer.object_to_bytes(room_service_packet))
	pass

func request_to_host_room(room_id:String, room_config:FSRoomConfig):
	print("Requesting to host room of id " + room_id)
	pass
