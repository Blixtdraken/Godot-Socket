extends Node
class_name FTimer


var start_time:int = -1

var time:int = -1

var target_tps:float = 100:
	set(value):
		if value != 0:
			@warning_ignore_start("narrowing_conversion")
			baked_min_tick_time = 1_000_000/(value)
		target_tps = value
		pass

var baked_min_tick_time:int = 2147483647

var sampled_constant_delay:int

func _init():
	sample(100)
	pass

func sample(samples_amount:int):
	var total_samples:int = 0
	for i in range(samples_amount):
		var sample_start_time:int = Time.get_ticks_usec()
		OS.delay_usec(1000)
		total_samples += Time.get_ticks_usec() - sample_start_time - 1000
	sampled_constant_delay = round(float(total_samples)/samples_amount)
	pass

func start():
	start_time = Time.get_ticks_usec()
	pass

func stop():
	if start_time == -1:
		return
	time = Time.get_ticks_usec() - start_time
	pass
	
func delay_from_time():
	if target_tps <= 0:
		return
	
	if baked_min_tick_time > time:
		delay_usec(baked_min_tick_time - time)

	pass

func delay_usec(usec:int):
	
	OS.delay_usec(clamp(usec - sampled_constant_delay, 0, INF))
	pass

func tick():
	stop()
	delay_from_time()
	start()
	pass
