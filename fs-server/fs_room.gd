extends Object
class_name FSRoom

signal join_queue(user:FSUser)
signal tps(user:FSUser)

var thread:Thread = Thread.new()

static var target_tps:int = 200
