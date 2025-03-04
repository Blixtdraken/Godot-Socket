extends Node

var client_connection:StreamPeerTCP
var uuid:int = -1

signal server_connected
signal server_connection_failed
signal server_disconnected

func _process(delta: float) -> void:
	if client_connection:
		client_connection.poll()
	pass

func _ready() -> void:
	connect_to_server("localhost", 5555)
	pass

## Connect to the socket server
func connect_to_server(ip_addr:String, port:int):
	var client:StreamPeerTCP = StreamPeerTCP.new()
	client.connect_to_host(ip_addr, port)
	client_connection = client
	print("Connecting...")
	while client.get_status() == client.STATUS_CONNECTING:
		await get_tree().process_frame
	
	if client.get_status() == client.STATUS_CONNECTED:
		print("Server connected!")
		server_connected.emit()
		init_connection()
	elif client.get_status() == client.STATUS_ERROR:
		print("Server error!")
		server_connection_failed.emit()
		client_connection = null
	
	pass

func init_connection():
	while client_connection.get_available_bytes() == 0:
		await get_tree().process_frame
	var new_uuid:int = client_connection.get_64()
	uuid = new_uuid
	print("Assigned uuid of " + str(new_uuid))
	pass
