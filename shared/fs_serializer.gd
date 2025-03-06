class_name FSSerializer


static func packet_to_dictionary(packet:Object) -> Dictionary:
	var dict:Dictionary[String, Variant] = {}
	
	dict["class_name"] = packet.get_script().get_global_name()
	print(dict["class_name"])
	var propert_dict:Dictionary[String, Variant] = {}
	
	for property in packet.get_property_list():
		print(property["name"] + ": " + str(packet.get(property["name"])))
	return dict
