extends Object
class_name FSLobby

signal send_function()
signal tps(fps_limiter:FTimer)


static var thread:Thread = Thread.new()
static var instance:FSLobby

var lobby_user_list:Dictionary[int,FSUser] = {}
var id_to_room:Dictionary[String, FSRoom] = {}

static var target_tps:int = 200

var tps_limiter:FTimer = FTimer.new()

static func start_thread() -> void:
	thread.start(FSLobby.new)
	pass

func _init():
	FLog.lobby("Started Lobby Thread", 1)
	instance = self
	FSTools.wait_for_readiness()
	
	start_lobby_loop()
	pass

func start_lobby_loop():
	tps_limiter.target_tps = target_tps
	FLog.lobby("Started Lobby Loop", 1)
	while true:
		handle_disconnected_users()
		
		handle_incoming_packets()
		
		signal_tick()
		tps_limiter.tick()
		pass
	pass

func handle_disconnected_users():
	for user:FSUser in lobby_user_list.values():
		if !user.is_still_connected():
			lobby_user_list.erase(user.uuid)
			user.send_disconnect()
	pass

func handle_incoming_packets():
	for user:FSUser in lobby_user_list.values():
		var peer:PacketPeer = user.peer
		if peer.get_available_packet_count() != 0:
			var packet:Dictionary = bytes_to_var(peer.get_packet())
			
			match packet["packet_type"]:
				"room_host_req":
					handle_host_packet(packet, user)
				"room_join_req":
					handle_join_packet(packet, user)
					pass
	pass

func handle_host_packet(join_packet:Dictionary, user:FSUser):
	var room_id:String = join_packet["room_id"]
	var packet:Dictionary = {
			"packet_type":"room_req_result",
			"room_id":room_id,
			"approval":false,
			"error_msg":""
		}
	if id_to_room.has(room_id):
		packet["error_msg"] = "Can't host, room exists already..."
	else:
		packet["approval"] = true
		var new_room:FSRoom = FSRoom.host_new_room(room_id, user)
		id_to_room[room_id] = new_room
		lobby_user_list.erase(user.uuid)
		pass
	user.peer.put_packet(var_to_bytes(packet))
	pass
func handle_join_packet(host_packet:Dictionary, user:FSUser):
	var room_id:String = host_packet["room_id"]
	pass

func signal_tick():
	send_function.emit()
