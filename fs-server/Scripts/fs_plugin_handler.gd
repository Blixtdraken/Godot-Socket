extends Object
class_name FSPluginHandler

static var room_plugins_script:Array[GDScript] = []

static func load_plugins():
	var plugin_dir:DirAccess = DirAccess.open("./plugins")
	for file_name:String in plugin_dir.get_files():
		if file_name.split(".")[-1] == "gd":
			room_plugins_script.append(load(plugin_dir.get_current_dir() + "/" + file_name))
	pass

static func get_room_plugin_array() -> Array[FSRoomPlugin]:
	var room_array:Array[FSRoomPlugin] = []
	
	for script in room_plugins_script:
		room_array.append(script.new())
	
	return room_array
	
