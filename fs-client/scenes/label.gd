extends Label


func _ready() -> void:
	text = str(FClient.uuid)
	pass

func _process(delta: float) -> void:
	if FClient.uuid == FCRoom.instance.host_uuid:
		modulate = Color(1, 0, 0)
	else:
		modulate = Color(1, 1, 1)
	pass
