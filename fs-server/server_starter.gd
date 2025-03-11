extends Node



func _ready() -> void:
	# Clears console, it looks ugly but don't tell it that or it gets sad
	var escape := PackedByteArray([0x1b]).get_string_from_ascii()
	print(escape + "[2J" + escape + "[;H" + "[FMultiplayer Server Project]\n")
	
	FServer.start_thread()
	FSLobby.start_thread()
	FConsole.start_thread()
	pass
