extends Object
class_name FSRoom

signal send_function(room:FSRoom)

var is_active:bool = true

var thread:Thread

static var target_tps:int = 200
var tps_limiter:FTimer = FTimer.new()

var host_user:FSUser
var unconfirmed_user_list:Dictionary[int, FSUser] = {}
var user_list:Dictionary[int, FSUser] = {}
var room_id:String

var tree:SceneTree = Engine.get_main_loop()

var plugin_wrapper:FSRoomPluginWrapper = FSRoomPluginWrapper.new(self)

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
	plugin_wrapper.trigger_room_start()
	var host_confirmed:bool = wait_for_host()
	if host_confirmed:
		user_list[host_user.uuid] = host_user
		send_user_join_packets(host_user)
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
				FLog.room(str(host_user.uuid) + " hosting room " + room_id)
				
				# TODO: send on join info packet? With host and such
				return true
		if !host_user.is_still_connected():
			return false
		tps_limiter.tick()
	return false
	pass

func start_room_loop():
	FLog.room("Room loop started for room: " + room_id)
	while true:
		handle_join_queue()
		handle_disconnected_users()
		handle_inocoming_packets()
		if user_list.size() == 0:
			is_active = false
			break
		plugin_wrapper.trigger_room_tick()
		tps_limiter.tick()
	pass

func handle_join_queue():
	send_function.emit(self)
	for user:FSUser in unconfirmed_user_list.values():
		if user.peer.get_available_packet_count() != 0:
			var packet:Dictionary = bytes_to_var(user.peer.get_packet())
			if packet["packet_type"] == "room_join_confirm":
				unconfirmed_user_list.erase(user.uuid)
				user_list[user.uuid] = user
				
				send_user_join_packets(user)
				FLog.room(str(user.uuid) + " joined room " + room_id)
	pass

func handle_disconnected_users():
	for user:FSUser in user_list.values():
		if !user.is_still_connected():
			handle_user_leave(user, false)
		pass
	pass
	
func handle_inocoming_packets():
	for user:FSUser in user_list.values():
		if user.peer.get_available_packet_count() != 0:
			var packet:Dictionary = bytes_to_var(user.peer.get_packet())
			match packet["packet_type"]:
				"room_leave":
					handle_user_leave(user)
					pass
				"room_kick":
					var target_uuid:int = packet["target_uuid"]
					var sender_uuid:int = user.uuid
					if sender_uuid == host_user.uuid:
						handle_user_leave(user_list[target_uuid])
						pass
					else:
						FLog.room("[color=red]" + str(sender_uuid) + " tried to kick someone while not being the host")
					pass
				"room_host_transfer":
					var target_uuid:int = packet["target_uuid"]
					var sender_uuid:int = user.uuid
					if sender_uuid == host_user.uuid:
						transfer_host(user_list[target_uuid])
						pass
					pass
				"custom_packet":
					handle_custom_packet(packet, user)
					pass
				"to_server_packet":
					plugin_wrapper.trigger_on_server_packet(packet["payload"], user.uuid)

		pass
	pass
	
func transfer_host(to_user:FSUser):
	host_user = to_user
	broadcast_packet(
			{
				"packet_type":"room_host_change",
				"target_uuid":to_user.uuid
			}
		)
	pass

func broadcast_packet(packet:Dictionary, exclusion:Array[FSUser] = []):
	for user:FSUser in user_list.values():
		if user in exclusion:
			continue
		user.peer.put_packet(var_to_bytes(packet))
		
		pass
	pass

func send_user_join_packets(joined_user:FSUser):
	plugin_wrapper.trigger_on_user_join(joined_user.uuid)
	var user_list_uuid:Array[int] = []
	
	for user:FSUser in user_list.values():
		if user != joined_user:
			user_list_uuid.append(user.uuid)
	joined_user.peer.put_packet(var_to_bytes({
		"packet_type":"room_join_info",
		"host_uuid": host_user.uuid,
		"user_list": user_list_uuid
	}))
	
	broadcast_packet({
		"packet_type":"room_user_joined",
		"user_uuid":joined_user.uuid
	})
	pass

func broadcast_user_leave_packet(leaving_user:FSUser):
	plugin_wrapper.trigger_on_user_leave(leaving_user.uuid)
	broadcast_packet({
		"packet_type":"room_user_left",
		"user_uuid":leaving_user.uuid
	})
	pass

enum TransferType{
	BROADCAST, ## Send to everyone in the room
	BROADCAST_EXCLUDE_SELF, ## Broadcast to everyone in room *EXCEPT* yourself (the sender)
	HOST, ## Send only to the current host (host is gotten during)
	PERSONAL ## Send to specific user specified by target_uuid
}

func handle_custom_packet(packet:Dictionary, sender:FSUser):
	packet["packet_type"] = "room_custom_packet"
	packet["sender_uuid"] = sender.uuid
	var transfer_type:TransferType = packet["transfer_type"]
	
	plugin_wrapper.trigger_on_custom_packet(packet["payload"],sender.uuid, transfer_type)
	
	match transfer_type:
		TransferType.BROADCAST:
			broadcast_packet(packet)
		TransferType.BROADCAST_EXCLUDE_SELF:
			broadcast_packet(packet, [sender])
		TransferType.HOST:
			host_user.peer.put_packet(var_to_bytes(packet))
		TransferType.PERSONAL:
			var target_user:FSUser = user_list[packet["target_uuid"]]
		
	pass

## If not sent to lobby they will be disconnected 
func handle_user_leave(user_to_leave:FSUser, send_to_lobby:bool = true):
	user_list.erase(user_to_leave.uuid)
	if user_to_leave == host_user and user_list.size() >= 1:
		transfer_host(user_list.values()[0])
	
	broadcast_user_leave_packet(user_to_leave)
	if send_to_lobby:
		user_to_leave.hand_over_to_lobby()
	else:
		user_to_leave.send_disconnect()
	
	pass

func _remove_room_signal():
	FSLobby.instance.id_to_room.erase(room_id)
	FLog.room("Removed room with Room ID: " + room_id)
	pass
