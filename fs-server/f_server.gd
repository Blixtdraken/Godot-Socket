extends Object
class_name FServer

signal send_function()
signal tps(fps_limiter:FTimer)

static var thread:Thread = Thread.new()
static var instance:FServer

var tcp_sever:TCPServer


var ip_addr:String = "0.0.0.0"
var port:int = 55555

static var target_tps:int = 200
var tps_limiter:FTimer = FTimer.new()

var uuid_to_user:Dictionary[int, FSUser] = {}

static func start_thread():
	thread.start(FServer.new)
	pass

func _init():
	instance = self
	
	
	Engine.max_fps = 1
	Engine.time_scale = 0
	Engine.physics_ticks_per_second = 1
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)
	FLog.server("Disabled godot's physics servers", 1)
	FSTools.wait_for_readiness()
	
	start_tcp_server()
	start_handling_connections()
	pass

## Starts and setups the tcp server
func start_tcp_server():
	FLog.server("Starting server...", 1)
	tcp_sever = TCPServer.new()

	var server_error:Error = tcp_sever.listen(port, ip_addr)
	
	
	if tcp_sever.is_listening():
		FLog.server("Server is listening on " + ip_addr + ":" + str(port), 1)
	else:
		FLog.server("Failed Starting TCP server!", 3)
		FLog.server("Error: " + error_string(server_error), 3)
		Engine.get_main_loop().quit(2)
	pass

## indefinitely wait for new connections and hand them over to the handshake function
func start_handling_connections():
	tps_limiter.target_tps = target_tps
	
	FLog.server("Started handling connections")
	while true:
		if tcp_sever.is_connection_available():
			var tcp_peer:StreamPeerTCP = tcp_sever.take_connection()
			## TODO: Find a way to differenciate between websocket connections and normal tcp
			
			var packet_peer_stream:PacketPeerStream = PacketPeerStream.new()
			packet_peer_stream.stream_peer = tcp_peer
			
			FLog.user(tcp_peer.get_connected_host() + ":" + str(tcp_peer.get_connected_port()) + " connected via TCP")
			initiate_packet_peer(packet_peer_stream)


		signal_tick()
		tps_limiter.tick()

func check_if_websocket(peer: StreamPeerTCP) -> bool:
	# Read a small amount of data (WebSocket handshake starts with "GET")
	var available_bytes = peer.get_available_bytes()
	if available_bytes > 0:
		var handshake_data = peer.get_data(min(available_bytes, 10))  # Read first 10 bytes
		if handshake_data[0] == OK:  
			var received_text = handshake_data[1].get_string_from_utf8()
			if received_text.begins_with("GET"):
				return true  # Likely a WebSocket handshake request
	return false

func signal_tick():
	send_function.emit()
	pass

func initiate_packet_peer(peer:PacketPeer):
	var new_user:FSUser = setup_new_user(peer)
	FLog.user(str(new_user.uuid) + "  was assigned an UUID")
	new_user.hand_over_to_lobby()
	FLog.user(str(new_user.uuid) + "  was handed to lobby")
	pass

func setup_new_user(peer:PacketPeer)->FSUser:
	# Roll random uuid until finding
	var new_uuid:int = randi()
	while uuid_to_user.has(new_uuid):
		new_uuid = randi()
	var new_user:FSUser = FSUser.new(peer, new_uuid)
	uuid_to_user[new_uuid] = new_user
	peer.put_packet(var_to_bytes(new_uuid))
	return new_user
	pass
