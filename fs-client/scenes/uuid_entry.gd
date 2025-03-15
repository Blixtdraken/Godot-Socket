extends Button
var parent:UserList


func _ready() -> void:
	parent = get_parent()
	pass

func _pressed() -> void:
	parent.button_pressed(int(text))
	pass
