class_name FSSerializer



static func object_to_bytes(object:Object) -> PackedByteArray:
	return var_to_bytes(object_to_dictionary(object))

static func bytes_to_object(bytes:PackedByteArray) -> Object:
	return dictionary_to_object(bytes_to_var(bytes))

static var class_script_cache:Dictionary[StringName, Script]

static func dictionary_to_object(dict:Dictionary) -> Object:
	var class_string:StringName = dict["class_name"]
	var class_script:Script
	
	if class_script_cache.has(class_string):
		class_script = class_script_cache[class_string]
		
	else:
		for i_class in ProjectSettings.get_global_class_list():
			if i_class["class"] == class_string:
				class_script_cache[class_string] = load(i_class["path"])
				print(i_class["path"])
				class_script = class_script_cache[class_string]
				break
	
	print(class_script)
	
	var built_object:Object = class_script.new()
	for key in dict["variables"].keys():
		built_object.set(key, dict["variables"][key])
	return built_object
	
static func object_to_dictionary(object:Object) -> Dictionary:
	var dict:Dictionary[String, Variant] = {}
	
	dict["class_name"] = (object.get_script().get_global_name() as String)
	var variables_dict:Dictionary[String, Variant] = {}
	
	for property in object.get_property_list():
		if property["type"] and property["type"] not in [TYPE_OBJECT, TYPE_NIL]:
			var property_name:String = property["name"]
			variables_dict[property_name] = object.get(property_name)
			
			
	dict["variables"] = variables_dict
	return dict
 
static func add_chache_(object:Object):
	class_script_cache[(object.get_script().get_global_name() as String)] = object.get_script()
	pass




static func get_class_name_from_dictionary(dict:Dictionary)-> StringName:
	return dict["class_name"]
	pass
