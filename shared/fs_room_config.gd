extends Resource
class_name FSRoomConfig

@export_subgroup("Room Settings")
@export var max_users:int = 16

@export var has_host:bool = true

@export var only_host_personal_packets:bool = true

@export_subgroup("Room Variables")

@export var global_variables:Dictionary[String, Variant] = {}

@export var hosts_global_variables:Dictionary[String, Variant] = {}

@export var host_only_variables:Dictionary[String, Variant] = {}
