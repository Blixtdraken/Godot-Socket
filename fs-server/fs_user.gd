extends Object
class_name FSUser

var is_websocket:bool = false

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



func _lobby_queue_signal():
	FSLobby.instance.lobby_user_list[self.uuid] = self
	pass
	
func _room_queue_signal():
	pass
	
func _disconnect_signal():
	pass
