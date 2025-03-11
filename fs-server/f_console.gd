extends Object
class_name FConsole

static var instance:FConsole

var thread:Thread = Thread.new()

static var delta_mutex:Mutex = Mutex.new()
static var delta:float = 1.0

static func start_thread():
	var console:FConsole = FConsole.new()
	console.thread.start(console.start.bind(), Thread.PRIORITY_LOW)
	#console.thread.wait_to_finish()

func start():
	
	
	start_console()
	FLog.server("Something went wrong with console if u can see this...", 3)
	
	pass

func start_console() -> void:
	FLog.cmd("Started console thread", true)
	instance = self
	FSTools.wait_for_readiness()
	
	FLog.cmd("Started console input handler", true)
	while true:
		var input:String = OS.read_string_from_stdin(500).to_lower()
		#var input = "tps server"
		var inputs:PackedStringArray = input.split(" ")
		match inputs[0]:
			"tps":
				if inputs[1] == "server":
					FServer.instance.tps.connect(on_serer_tps, CONNECT_ONE_SHOT)
				elif inputs[1] == "lobby":
					FSLobby.instance.tps.connect(on_lobby_tps, CONNECT_ONE_SHOT)
			_:
				FLog.cmd("Command not found?: " + input)
	pass

func on_lobby_tps(tps_limiter:FTimer):
	var tps = 1_000_000/tps_limiter.time
	if tps_limiter.target_tps != 0:
		tps = clamp(tps, 0, tps_limiter.target_tps)
	if tps == tps_limiter.target_tps:
		FLog.cmd("Lobby TPS is: " + str(tps) + "~")
	else:
		FLog.cmd("Lobby TPS is: " + str(tps))
	pass

func on_serer_tps(tps_limiter:FTimer):
	var tps = 1_000_000/tps_limiter.time
	if tps_limiter.target_tps != 0:
		tps = clamp(tps, 0, tps_limiter.target_tps)
	if tps == tps_limiter.target_tps:
		FLog.cmd("Server TPS is: " + str(tps) + "~")
	else:
		FLog.cmd("Server TPS is: " + str(tps))
	pass
