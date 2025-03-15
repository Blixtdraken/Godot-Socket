extends Object
class_name FCRoomSignals

signal custom_packet_received(packet:FCCustomPacket)

signal join_info_received()

signal host_change(new_host_uuid:int)

signal user_joined(user_uuid:int)
signal user_left(user_uuid:int)
