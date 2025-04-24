extends Node2D

#Temp fix before I solve it properly
var owner_uuid:int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(FClient.uuid)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if owner_uuid == FClient.uuid:
		global_position = get_global_mouse_position()
		RPCPacket.rpc(net_update_pos, [global_position])
	pass

func net_update_pos(new_pos:Vector2):
	if owner_uuid != FClient.uuid:
		global_position = new_pos
	pass
