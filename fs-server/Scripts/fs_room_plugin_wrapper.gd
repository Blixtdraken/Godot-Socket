extends Object
class_name FSRoomPluginWrapper



var plugins:Array[FSRoomPlugin]


func _init(room:FSRoom) -> void:
	plugins = FSPluginHandler.get_room_plugin_array()
	
	for plugin in plugins:
		plugin.room = FSRoomWraper.new(room)
	pass

# Executed when room starts, before host has entered
func trigger_room_start():
	for plugin in plugins:
		plugin._room_start()
	pass

## Executed once every room tick (room tick-rate is configured in server-config.yaml)
func trigger_room_tick():
	for plugin in plugins:
		plugin._room_tick()
	pass
## When a client in the room send a server packet (a specific fucntion on client that sends a dictionary only to the server)
func trigger_on_server_packet(payload:Dictionary, sender_uuid:int):
	for plugin in plugins:
		plugin._on_server_packet(payload, sender_uuid)
	pass


## The custom packet as a dictionary, might be confusing to use,
func trigger_on_custom_packet(payload:Dictionary, sender_uuid:int, transfer_type:int):
	for plugin in plugins:
		plugin._on_custom_packet(payload, sender_uuid, transfer_type)
	pass

## When a user joins the room, this will only be triggered after player has confirmed the join, meaning also subsequently, the person trying to host will always be 
func trigger_on_user_join(joining_uuid:int):
	for plugin in plugins:
		plugin._on_user_join(joining_uuid)
	pass
## When a user leaves (or is kicked) this is triggered.
func trigger_on_user_leave(leaving_uuid:int):
	for plugin in plugins:
		plugin._on_user_leave(leaving_uuid)
	pass
