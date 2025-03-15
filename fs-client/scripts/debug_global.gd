extends Node

var values_list:Dictionary[String, Variant] = {}

@onready var debug_label:RichTextLabel = $CanvasLayer/DebugLabel

func _process(delta: float) -> void:
	values_list["fps"] = roundi(1.0/delta)

	
	
	debug_label.text = "[outline_size=8][color=green][i]"
	for key in values_list.keys():
		debug_label.text += key + ": " + str(values_list[key]) + "\n"
	pass
	
