extends Object
class_name FSRoomServicePacket


enum RequestType { 
	REQ_HOST,
	REQ_JOIN,
	GOT_TRANSFER
}

var request_type:RequestType

var room_target:String

var room_config:FSRoomConfig = null
