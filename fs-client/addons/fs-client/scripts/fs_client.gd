extends Node


var client_peer:PacketPeer
var uuid:int = -2
#var is_connected:bool = false

var server_connect_scene:PackedScene = null

@onready var room_service:FSRoomService = $RoomService

signal server_connected
signal server_connection_failed
signal server_disconnected

signal _packet_received(packet:Object)

func _ready() -> void:
	server_disconnected.connect(_on_server_disconnect)
	pass



func _process(delta: float) -> void:
	if client_peer:
		if client_peer is WebSocketPeer:
			client_peer.poll()
		if !_is_still_connected(false):
			server_disconnected.emit()
		elif _packet_received.has_connections():
			if client_peer.get_available_packet_count() != 0:
				var packet:Object = FSSerializer.bytes_to_object(client_peer.get_packet())
				_packet_received.emit(packet)
		elif client_peer.get_available_packet_count() != 0:
			print("Queueing packages")
	pass

func _on_server_disconnect():
	client_peer = null
	uuid = -1
	print("Discconected from server!")
	if server_connect_scene:
		get_tree().call_deferred("change_scene_to_packed", server_connect_scene)
	pass

func _is_still_connected(should_poll_web:bool = true)->bool:
	if client_peer is WebSocketPeer:
		
		if should_poll_web:
			(client_peer as WebSocketPeer).poll()
		var status: WebSocketPeer.State = (client_peer as WebSocketPeer).get_ready_state()
		
		if status in [WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING]:
			return false
	else:
		((client_peer as PacketPeerStream).stream_peer as StreamPeerTCP).poll()
		var status: StreamPeerTCP.Status = ((client_peer as PacketPeerStream).stream_peer as StreamPeerTCP).get_status()
		if status in [StreamPeerTCP.STATUS_ERROR, StreamPeerTCP.STATUS_NONE]:
			return false
	return true



## Connect to the FSServer via TCP
func connect_to_server(ip_addr:String, port:int):
	#Make a TCP client and connect it
	var peer_stream:StreamPeerTCP = StreamPeerTCP.new()
	var connection_error:Error = peer_stream.connect_to_host(ip_addr, port)
	
	#Wrap as a PacketPeer so it's generlised.
	var packet_peer:PacketPeerStream = PacketPeerStream.new()
	packet_peer.stream_peer = peer_stream
	
	client_peer = packet_peer
	
	# Wait to get result from server connection
	print("Connecting...")
	while peer_stream.get_status() == peer_stream.STATUS_CONNECTING:
		peer_stream.poll()
		await get_tree().process_frame
	if peer_stream.get_status() == peer_stream.STATUS_CONNECTED:
		print("Server connected!")
		_uuid_handshake()
	elif peer_stream.get_status() == peer_stream.STATUS_ERROR:
		print("Server error!")
		print("Error: " + error_string(connection_error))
		
		server_connection_failed.emit()
		client_peer = null
	elif peer_stream.get_status() == peer_stream.STATUS_NONE:
		print("Server not connected... Something went wrong...")
		print("INFO: " + error_string(connection_error))
		client_peer = null

## Connect to the FSServer via WebSocket(ws/wss)
func connect_to_web_server(ip_addr:String, port:int, tls_client_options:TLSOptions = null):
	var packet_web_peer:WebSocketPeer = WebSocketPeer.new()
	var connection_error:Error = ERR_BUG
	if !tls_client_options:
		connection_error = packet_web_peer.connect_to_url("ws://" + ip_addr + ":" + str(port))
	else:
		connection_error = packet_web_peer.connect_to_url("wss://" + ip_addr + ":" + str(port),tls_client_options)
	client_peer = packet_web_peer
	
	print("Connecting...")
	while packet_web_peer.get_ready_state() == packet_web_peer.STATE_CONNECTING:
		await get_tree().process_frame
	if packet_web_peer.get_ready_state() == packet_web_peer.STATE_OPEN:
		print("Server connected!")
		_uuid_handshake()
	elif packet_web_peer.get_ready_state() == packet_web_peer.STATE_CLOSED or packet_web_peer.STATE_CLOSING:
		print("Server error!")
		print(error_string(connection_error))
		server_connection_failed.emit()
		client_peer = null
	pass

## INTERNAL: called after server connection formed, waits to be given a uuid
func _uuid_handshake():
	print("Waiting to be assigned uuid...")
	
	while client_peer.get_available_packet_count() == 0:
		await get_tree().process_frame
		if !_is_still_connected(): server_connection_failed.emit()
	var new_uuid:int = bytes_to_var(client_peer.get_packet())
	uuid = new_uuid
	print("Assigned uuid of " + str(new_uuid))
	server_connected.emit()
	pass
