extends Object
class_name FClient

var client_peer:PacketPeer
static var uuid:int = -2
#var is_connected:bool = false

static var instance:FClient

static var server_connect_scene:PackedScene = null
static var signals:FClientSignals



static var tree:SceneTree = Engine.get_main_loop()



# initialize everyhting
static func _static_init() -> void:
	signals = FClientSignals.new()
	FCLobby.signals = FCLobbySignals.new()
	FCRoom.signals = FCRoomSignals.new()
	instance = FClient.new()
	FCLobby.instance = FCLobby.new()
	FCRoom.instance = FCRoom.new()
	
	
	pass

func _init():
	signals.server_disconnected.connect(on_server_disconnect)

func on_server_disconnect():
	client_peer = null
	uuid = -1
	print("Discconected from server!")
	if server_connect_scene:
		tree.call_deferred("change_scene_to_packed", server_connect_scene)
	pass

func is_still_connected(should_poll:bool = true)->bool:
	if client_peer is WebSocketPeer:
		if should_poll:
			(client_peer as WebSocketPeer).poll()
		var status: WebSocketPeer.State = (client_peer as WebSocketPeer).get_ready_state()
		
		if status in [WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING]:
			return false
	else:
		if should_poll:
			((client_peer as PacketPeerStream).stream_peer as StreamPeerTCP).poll()
		var status: StreamPeerTCP.Status = ((client_peer as PacketPeerStream).stream_peer as StreamPeerTCP).get_status()
		if status in [StreamPeerTCP.STATUS_ERROR, StreamPeerTCP.STATUS_NONE]:
			return false
	return true

## Connect to the FSServer via TCP
static func connect_to_server(ip_addr:String, port:int):
	if instance.client_peer:
		return
	#Make a TCP client and connect it
	var peer_stream:StreamPeerTCP = StreamPeerTCP.new()
	var connection_error:Error = peer_stream.connect_to_host(ip_addr, port)
	
	#Wrap as a PacketPeer so it's generlised.
	var packet_peer:PacketPeerStream = PacketPeerStream.new()
	packet_peer.stream_peer = peer_stream
	
	instance.client_peer = packet_peer
	
	# Wait to get result from server connection
	print("Connecting...")
	while peer_stream.get_status() == peer_stream.STATUS_CONNECTING:
		peer_stream.poll()
		await tree.process_frame
	if peer_stream.get_status() == peer_stream.STATUS_CONNECTED:
		print("Server connected!")
		instance.handle_server_connection()
	elif peer_stream.get_status() == peer_stream.STATUS_ERROR:
		print("Server error!")
		print("Error: " + error_string(connection_error))
		
		signals.server_connection_failed.emit()
		instance.client_peer = null
	elif peer_stream.get_status() == peer_stream.STATUS_NONE:
		print("Server not connected... Something went wrong...")
		print("INFO: " + error_string(connection_error))
		instance.client_peer = null

## Connect to the FSServer via WebSocket(ws/wss)
static func connect_to_web_server(ip_addr:String, port:int, tls_client_options:TLSOptions = null):
	if instance.client_peer:
		return
	var packet_web_peer:WebSocketPeer = WebSocketPeer.new()
	var connection_error:Error = ERR_BUG
	if !tls_client_options:
		connection_error = packet_web_peer.connect_to_url("ws://" + ip_addr + ":" + str(port))
	else:
		connection_error = packet_web_peer.connect_to_url("wss://" + ip_addr + ":" + str(port),tls_client_options)
	instance.client_peer = packet_web_peer
	
	print("Connecting...")
	while packet_web_peer.get_ready_state() == packet_web_peer.STATE_CONNECTING:
		print(packet_web_peer.get_ready_state() )
		await Engine.get_main_loop().process_frame
	if packet_web_peer.get_ready_state() == packet_web_peer.STATE_OPEN:
		print("Server connected!")
		instance.handle_server_connection()
	elif packet_web_peer.get_ready_state() == packet_web_peer.STATE_CLOSED or packet_web_peer.STATE_CLOSING:
		print("Server error!")
		print(error_string(connection_error))
		signals.server_connection_failed.emit()
		instance.client_peer = null
	pass

func handle_server_connection():
	await perform_uuid_handshake()
	client_loop()
	signals.server_connected.emit()
	pass

## INTERNAL: called after server connection formed, waits to be given a uuid
func perform_uuid_handshake():
	print("Waiting to be assigned uuid...")
	
	while client_peer.get_available_packet_count() == 0:
		await tree.process_frame
		if !is_still_connected(): signals.server_connection_failed.emit()
	var new_uuid:int = bytes_to_var(client_peer.get_packet())
	uuid = new_uuid
	print("Assigned uuid of " + str(new_uuid))
	pass



func client_loop():
	while true:
		await tree.process_frame
		if client_peer.get_available_packet_count() >= 1:
			signals._packet_received.emit(bytes_to_var(client_peer.get_packet()) as Dictionary)
			pass
		if !is_still_connected():
			signals.server_disconnected.emit()
			break
			pass
	pass
