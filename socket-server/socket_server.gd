extends Node

var tcp_server:TCPServer

var uuid_to_connection:Dictionary[int, StreamPeerTCP]

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
		init_connection(server.take_connection())
	pass # Replace with function body.

func __connection_thread(connection:StreamPeerTCP):
	pass

func init_connection(connection:StreamPeerTCP)->void:
	var new_uui:int = randi()
	while uuid_to_connection.has(new_uui):
		new_uui = randi()
	uuid_to_connection[new_uui] = connection
	await get_tree().create_timer(2).timeout
	
	connection.put_64(new_uui)
	pass
