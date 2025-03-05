extends Node
class_name FSServer

var tcp_server:TCPServer

var uuid_to_peer:Dictionary[int, PacketPeer]

@onready
var room_service:FSRoomService = $SocketRoomHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var server:TCPServer = TCPServer.new()
	server.listen(5555)
	
	
	
	if !server.is_listening():
		print("Failed Starting server!")
		get_tree().quit(2)
	tcp_server = server
	while true:
		while !server.is_connection_available():
			await get_tree().process_frame
		print("Test")
		
		var peer:PacketPeerStream = PacketPeerStream.new()
		peer.stream_peer = server.take_connection()
		init_connection(peer)
	pass # Replace with function body.



func init_connection(peer:PacketPeer)->void:
	var new_uui:int = randi()
	while uuid_to_peer.has(new_uui):
		new_uui = randi()
	uuid_to_peer[new_uui] = peer 
	await get_tree().create_timer(2).timeout
	
	peer.put_packet(var_to_bytes(new_uui))
	room_service.hand_over_user(new_uui)
	pass
