extends Object
class_name FSUser

var is_websocket:bool = false

var nickname:String = ""

var uuid:int
var peer:PacketPeer



func _init(set_peer:PacketPeer, set_uuid:int) -> void:
	if set_peer is WebSocketPeer:
		is_websocket = true
	uuid = set_uuid
	peer = set_peer
	pass


func is_still_connected(should_poll:bool = true)->bool:
	if is_websocket:
		if should_poll:
			(peer as WebSocketPeer).poll()
		var status: WebSocketPeer.State = (peer as WebSocketPeer).get_ready_state()
		
		if status in [WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING]:
			return false
	else:
		if should_poll:
			((peer as PacketPeerStream).stream_peer as StreamPeerTCP).poll()
		var status: StreamPeerTCP.Status = ((peer as PacketPeerStream).stream_peer as StreamPeerTCP).get_status()
		if status in [StreamPeerTCP.STATUS_ERROR, StreamPeerTCP.STATUS_NONE]:
			return false
	return true


func hand_over_to_lobby():
	FSLobby.instance.send_function.connect(self._lobby_queue_signal, CONNECT_ONE_SHOT)
	pass
func _lobby_queue_signal():
	FSLobby.instance.lobby_user_list[self.uuid] = self
	
	peer.put_packet(var_to_bytes(
		{
			"packet_type":"lobby_join"
		}
	))

	pass

func hand_over_to_room(room:FSRoom):
	room.send_function.connect(_room_queue_signal, CONNECT_ONE_SHOT)
	pass

func _room_queue_signal(room:FSRoom):
	room.unconfirmed_user_list[self.uuid] = self
	pass

func send_disconnect():
	FServer.instance.send_function.connect(self._disconnect_signal, CONNECT_ONE_SHOT)
	pass

func _disconnect_signal():
	FServer.instance.uuid_to_user.erase(self.uuid)
	FLog.user(str(uuid) + "  disconnected from server")

	pass
