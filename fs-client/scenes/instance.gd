extends Button


func _pressed() -> void:
	InstancePacket.spawn("res://scenes/player.tscn", get_path())
