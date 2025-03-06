extends Node

var values_list:Dictionary[String, Variant] = {}

@onready var debug_label:Label = $CanvasLayer/DebugLabel

func _process(delta: float) -> void:
	
	debug_label.text = ""
	for key in values_list.keys():
		debug_label.text += key + ": " + str(values_list[key])
	pass
	
