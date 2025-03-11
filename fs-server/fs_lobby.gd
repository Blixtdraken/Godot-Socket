extends Object
class_name FSLobby

signal lobby_queue()
signal tps(fps_limiter:FTimer)


static var thread:Thread = Thread.new()
static var instance:FSLobby

var lobby_user_list:Dictionary[int,FSUser] = {}
var room_id_to_room:Dictionary[String, FSRoom] = {}

static var target_tps:int = 200

var tps_limiter:FTimer = FTimer.new()

static func start_thread() -> void:
	thread.start(FSLobby.new)
	pass

func _init():
	FLog.lobby("Started Lobby Thread", 1)
	instance = self
	FSTools.wait_for_readiness()
	
	start_main_loop()
	pass

func start_main_loop():
	tps_limiter.target_tps = target_tps
	FLog.lobby("Started Lobby Loop", 1)
	while true:
		print(lobby_user_list)
		#OS.delay_msec() ## IGNORE THIS DEVIN (IMAGINE THIS IS ALOT OF CODE THAT TAKES TIME)
		signal_tick()
		tps_limiter.tick()
		pass
	pass

func signal_tick():
	tps.emit(tps_limiter)
	lobby_queue.emit()
