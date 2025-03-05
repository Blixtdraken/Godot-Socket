extends Object
class_name FSUser

var uuid:int

var peer:PacketPeer


func _init(set_peer:PacketPeer, set_uuid:int) -> void:
	uuid = set_uuid
	peer = set_peer
	pass
