extends Object
class_name FSUser

var server:FSServer

var is_websocket:bool = false

var uuid:int
var peer:PacketPeer

signal peer_disconnected(uuid:int)

func _init(set_peer:PacketPeer, set_uuid:int, set_server:FSServer) -> void:
	server = set_server
	if set_peer is WebSocketPeer:
		is_websocket = true
	uuid = set_uuid
	peer = set_peer
	pass



func tick() -> void:
	if is_websocket:
		peer = peer as WebSocketPeer
		peer.poll()
	
	if !is_still_connected():
		peer_disconnected.emit(uuid)
	pass

func is_still_connected(should_poll:bool = true)->bool:
	if is_websocket:
		if should_poll:
			(peer as WebSocketPeer).poll()
		var status: WebSocketPeer.State = (peer as WebSocketPeer).get_ready_state()
		
		if status in [WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING]:
			return false
	else:
		((peer as PacketPeerStream).stream_peer as StreamPeerTCP).poll()
		var status: StreamPeerTCP.Status = ((peer as PacketPeerStream).stream_peer as StreamPeerTCP).get_status()
		if status in [StreamPeerTCP.STATUS_ERROR, StreamPeerTCP.STATUS_NONE]:
			return false
	return true
