class_name MidiFile

# Called when the node enters the scene tree for the first time.
func _init():
	pass

func save_to_file(header):
	var file = FileAccess.open("res://saves/save.mid",FileAccess.WRITE)
	file.set_big_endian(true)
	file.store_32(0x4D546864)		#MThd
	file.store_32(0x00000006)		#ChunkLen
	file.store_16(0x0000)			#Format 0
	file.store_16(0x0001)			#One Track
	file.store_16(0x0060)			#96/Negra
	file.store_32(0x4D54726B)		#MTrk
	file.store_64(0x00FF580404021808)	#4/4, 24/Neg, 8
	print("error",file.get_open_error())
