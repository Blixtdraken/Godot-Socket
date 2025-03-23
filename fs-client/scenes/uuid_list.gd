extends VBoxContainer
class_name UserList


signal user_pressed(user_uuid:int)


var selected_user:int = -1

var current_colored_host:int = -1:
	set(value):
		if uuid_to_entry.has(current_colored_host):
			uuid_to_entry[current_colored_host].modulate = Color(1, 1, 1)
		current_colored_host = value
		uuid_to_entry[current_colored_host].modulate = Color(0, 1, 0)

func button_pressed(user_uuid:int):
	selected_user = user_uuid
	Debug.values_list["selected_uuid"] = str(selected_user)
	pass

var uuid_to_entry:Dictionary[int,Button] = {}
func add_entry(uuid:int):
	uuid_to_entry[uuid] = preload("res://scenes/uuid_entry.tscn").instantiate()
	uuid_to_entry[uuid].text = str(uuid)
	add_child(uuid_to_entry[uuid])
	pass

func remove_entry(uuid:int):
	uuid_to_entry[uuid].queue_free()
	uuid_to_entry.erase(uuid)
	pass
