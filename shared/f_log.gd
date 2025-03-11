extends Object
class_name FLog



static var minimum_priority_level:int = 0
## Logging function with differenet severity levels
## 0 - Verbose info
## 1 - Broader Info
## 2 - Warnings
## 3 - Errors
static func server(msg:String, priority_level:int = 0):
	if priority_level >= minimum_priority_level:
		print_rich("[color=Lightskyblue][FServer] " + msg)
	pass

static func user(msg:String, priority_level:int = 0):
	if priority_level >= minimum_priority_level:
		print_rich("[color=Darkorange][FSUser] " + msg)
	pass

static func lobby(msg:String, priority_level:int = 0):
	if priority_level >= minimum_priority_level:
		print_rich("[color=Hotpink][FSLobby] " + msg)
	pass

static func room(msg:String, priority_level:int = 0):
	if priority_level >= minimum_priority_level:
		print_rich("[color=Lawngreen][FSRoom] " + msg)
	pass

static func cmd(msg:String, is_setup:bool = false):
	if !is_setup:
		print_rich("[b][i][color=Yellow][FConsole] " + msg)
	else:
		print_rich("[color=Khaki][FConsole] " + msg)
	pass
