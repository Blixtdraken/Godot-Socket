extends Object
class_name FSTools


static func wait_for_readiness():
	while !FSLobby.instance or !FServer.instance or !FConsole.instance: #OS.delay_usec(10)
		pass
