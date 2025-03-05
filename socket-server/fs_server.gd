extends Node
class_name FSServer

var tcp_server:TCPServer
var web_server:WebSocketPeer


var uuid_to_user:Dictionary[int, FSUser]

@onready
var room_service:FSRoomService = $SocketRoomHandler


func _ready() -> void:
	print("Starting server(s)...")
	start_server("0.0.0.0", 5555)
	start_accepting_clients()
	pass # Replace with function body.

func _process(delta: float) -> void:
	for user in uuid_to_user.values():
		user = user as FSUser
		user.tick()
	pass


func _on_peer_discconnect(uuid:int):
	print("User " + str(uuid) + " disconnected from server")
	var user:FSUser = uuid_to_user[uuid]
	user.call_deferred("free")
	uuid_to_user.erase(uuid)
	pass


## Starts and setups the tcp server
func start_server(ip_addr:String, port:int):
	print("Sarting TCP server...")
	var server:TCPServer = TCPServer.new()
	tcp_server = server
	var server_error:Error = server.listen(port, ip_addr)
	
	
	if server.is_listening():
		print("TCP Server is listening on " + ip_addr + ":" + str(port))
	else:
		print("Failed Starting TCP server!")
		print("Error: " + error_string(server_error))
		get_tree().quit(2)
	pass


## indefinitely wait for new connections and hand them over to the handshake function
func start_accepting_clients():
	while true:
		while !tcp_server.is_connection_available():
			await get_tree().process_frame
		var peer:PacketPeerStream = PacketPeerStream.new()
		peer.stream_peer = tcp_server.take_connection()
		var web_peer:WebSocketPeer = WebSocketPeer.new()
		web_peer.accept_stream(peer.stream_peer)
		web_peer.poll()
		if web_peer.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
			print("User connected via TCP, assigning uuid")
			uuid_handshake(peer)
		else:
			print("User connected via WebSocket, assigning uuid")
			uuid_handshake(web_peer)
			


## Called after accepting a client to give it a uuid and then hand it over to room service
func uuid_handshake(peer:PacketPeer)->void:
	var new_uui:int = randi()
	while uuid_to_user.has(new_uui):
		new_uui = randi()
	var new_user:FSUser = FSUser.new(peer, new_uui, self)
	new_user.peer_disconnected.connect(_on_peer_discconnect)
	uuid_to_user[new_uui] = new_user
	await get_tree().create_timer(2).timeout
	peer.put_packet(var_to_bytes(new_uui))
	print("Assigned and sent uuid of " + str(new_uui))
	room_service.hand_over_user(new_user)
	pass
