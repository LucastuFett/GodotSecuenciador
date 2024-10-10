class_name MidiFile

var offMsg
var len = 19
var mthd = PackedByteArray()
var mtrk = PackedByteArray()
# Called when the node enters the scene tree for the first time.
func _init():
	pass
	
func save_to_file(messages, offMessages):
	var file = FileAccess.open("res://saves/save.mid",FileAccess.WRITE)
	const delta = 24
	const tempo = 500000
	const tone = 0 #C
	const mode = 0 #Major
	print("error",file.get_open_error())
	file.set_big_endian(true)
	mthd = [0x4D,0x54,0x68,0x64,0x00,0x00,0x00,0x06,0x00,0x00,0x00,0x01,0x00,delta]
	file.store_buffer(mthd)
	file.store_32(0x4D54726B)		#MTrk
	mtrk = [0x00,0xFF,0x58,0x04,0x04,0x02,0x18,0x08,0x00,0xFF,0x51,0x03,(tempo & 0xFF0000) >> 16,(tempo & 0xFF00) >> 8,(tempo & 0xFF),0x00,0xFF,0x59,0x02, tone, mode]
	var curOff = 0
	for j in 32:
		var flag = false
		for i in 10:
			var index = (i * 32) + j
			#print(messages[index][0])
			if offMessages[index][0] != 0:
				flag = true
				print(curOff,offMessages[index])
				if curOff > 0x7F:
					calcDelta(curOff, mtrk)
				else:
					mtrk.append(curOff)
				mtrk.append(offMessages[index][0])
				mtrk.append(offMessages[index][1])
				mtrk.append(offMessages[index][2])
				curOff = 0
			if messages[index][0] != 0:
				flag = true
				print(curOff,messages[index])
				if curOff > 0x7F:
					calcDelta(curOff, mtrk)
				else:
					mtrk.append(curOff)
				mtrk.append(messages[index][0])
				mtrk.append(messages[index][1])
				mtrk.append(messages[index][2])
				curOff = 0
			
		if not flag:
			curOff += delta
		else:
			curOff = delta
	mtrk.append_array([0x00,0xFF,0x2F,0x00])		#End
	file.store_32(len(mtrk))		#ChunkLen, calcular, base 19
	file.store_buffer(mtrk)
	

func calcDelta(value, mtrk):
	var buffer = value & 0x7F
	while (value >> 7) > 0:
		value >>= 7
		buffer <<= 8
		buffer |= 0x80
		buffer += (value & 0x7F)
	while true:
		print(buffer & 0xFF)
		mtrk.append(buffer & 0xFF)
		len += 1
		if buffer & 0x80:
			buffer >>= 8
		else:
			break

func shiftOff(messages, mode32):
	# Mover los mensajes de on 1T y poner velocidad en 0
	pass
