extends Object
class_name FSRoom

signal send_function(room:FSRoom)

var thread:Thread

static var target_tps:int = 200
var tps_limiter:FTimer = FTimer.new()

var host_user:FSUser
var user_list:Dictionary[int, FSUser] = {}
var room_id:String
static func host_new_room(room_id:String,host:FSUser) -> FSRoom:
	FLog.room("Making new room by Room ID: " + room_id + "       With " + str(host.uuid) + " as host")
	var thread:Thread = Thread.new()
	var new_room:FSRoom = FSRoom.new(thread, room_id, host)
	thread.start(new_room.start_room)
	return new_room


func _init(set_thread:Thread,room_id:String, host:FSUser) -> void:
	thread = set_thread
	tps_limiter.target_tps = target_tps
	self.room_id = room_id
	host_user = host
	pass

func start_room():
	FLog.room("Made new thread for Room ID: " + room_id)
	var host_confirmed:bool = wait_for_host()
	if host_confirmed:
		user_list[host_user.uuid] = host_user
		start_room_loop()
	else:
		FLog.room("Host never confirmed on join on room: " + room_id)
		host_user.send_disconnect()
	FSLobby.instance.send_function.connect(_remove_room_signal, CONNECT_ONE_SHOT)
	pass

# returns if received host (if host left during making room it returns false)
func wait_for_host() -> bool:
	while true:
		if host_user.peer.get_available_packet_count() != 0:
			var packet:Dictionary = bytes_to_var(host_user.peer.get_packet())
			if packet["packet_type"] == "room_join_confirm":
				# TODO: send on join package? With host and such
				return true
		if !host_user.is_still_connected():
			return false
		tps_limiter.tick()
	return false
	pass

func start_room_loop():
	FLog.room("Room loop started for room: " + room_id)
	while true:
	
		handle_disconnected_users()
		
		if user_list.size() == 0:
			break
		tps_limiter.tick()
	pass

func handle_disconnected_users():
	for user:FSUser in user_list.values():
		if !user.is_still_connected():
			user_list.erase(user.uuid)
			user.send_disconnect()
		pass
	pass
	

func _remove_room_signal():
	FSLobby.instance.id_to_room.erase(room_id)
	FLog.room("Removed room with Room ID: " + room_id)
	pass
