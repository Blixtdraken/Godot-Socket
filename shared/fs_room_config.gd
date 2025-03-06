extends Resource
class_name FSRoomConfig

@export_subgroup("Room Settings")
@export var max_users:int = 16

@export var has_host:bool = true

@export var only_host_personal_packets:bool = true

@export_subgroup("Room Variables")

@export var host_variables:Dictionary[String, Variant] = {}



func get_room_config_as_dictionary() -> Dictionary[String, Variant]: 
	var dict:Dictionary[String, Variant] = {}
	dict["max_users"] = max_users
	dict["has_host"] = has_host
	dict["only_host_personal_packets"] = only_host_personal_packets
	
	dict["host_variables"] = host_variables
	
	return dict
