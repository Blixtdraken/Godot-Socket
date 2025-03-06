extends Object
class_name FSRoomServicePacket


enum RequestResult{
	JOIN_ERR_ROOM_NOT_FOUND,
	HOST_ERR_ROOM_EXISTS,
	JOIN_ERR_ROOM_FULL,
	SUCCES,
	KICKED
}

enum RequestType { 
	REQ_HOST,
	REQ_JOIN,
	GOT_TRANSFER
}

var request_result:RequestResult

var request_type:RequestType

var room_target:String

var room_config:Dictionary[String, Variant] = {}
