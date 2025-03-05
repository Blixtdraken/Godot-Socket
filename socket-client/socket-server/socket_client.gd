extends Node

var client_peer:PacketPeer
var uuid:int = -1

signal server_connected
signal server_connection_failed
signal server_disconnected

func _process(delta: float) -> void:
	if client_peer is WebSocketPeer:
		client_peer.poll()
	pass

func _ready() -> void:
	connect_to_server("localhost", 5555)
	pass

## Connect to the socket server
func connect_to_server(ip_addr:String, port:int):
	#Make a TCP client
	var peer_stream:StreamPeerTCP = StreamPeerTCP.new()
	var packet_peer:PacketPeerStream = PacketPeerStream.new()
	packet_peer.stream_peer = peer_stream
	peer_stream.connect_to_host(ip_addr, port)
	client_peer = packet_peer
	
	print("Connecting...")
	while peer_stream.get_status() == peer_stream.STATUS_CONNECTING:
		peer_stream.poll()
		await get_tree().process_frame
	if peer_stream.get_status() == peer_stream.STATUS_CONNECTED:
		print("Server connected!")
		server_connected.emit()
		init_connection()
	elif peer_stream.get_status() == peer_stream.STATUS_ERROR:
		print("Server error!")
		server_connection_failed.emit()
		client_peer = null

func connect_to_web_server(ip_addr:String, port:int, tls_client_options:TLSOptions = null):
	var packet_web_peer:WebSocketPeer = WebSocketPeer.new()
	if !tls_client_options:
		packet_web_peer.connect_to_url("http://" + ip_addr + ":" + str(port))
	else:
		packet_web_peer.connect_to_url("https://" + ip_addr + ":" + str(port),tls_client_options)
	client_peer = packet_web_peer
	
	print("Connecting...")
	while packet_web_peer.get_ready_state() == packet_web_peer.STATE_CONNECTING:
		await get_tree().process_frame
	if packet_web_peer.get_ready_state() == packet_web_peer.STATE_STATUS_CONNECTED:
		print("Server connected!")
		server_connected.emit()
		init_connection()
	elif packet_web_peer.get_ready_state() == packet_web_peer.STATE_CLOSED or packet_web_peer.STATE_CLOSING:
		print("Server error!")
		server_connection_failed.emit()
		client_peer = null
	pass

func init_connection():
	while client_peer.get_available_packet_count() == 0:
		await get_tree().process_frame
	var new_uuid:int = bytes_to_var(client_peer.get_packet())
	uuid = new_uuid
	print("Assigned uuid of " + str(new_uuid))
	pass
