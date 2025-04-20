class_name MidiFile

var offMsg
var mthd = PackedByteArray()
var mtrk = PackedByteArray()

# Called when the node enters the scene tree for the first time.
func _init():
	var saves = DirAccess.open("res://saves/")
	for i in range(1,9):
		if not saves.dir_exists(str(i) + "/"):
			saves.make_dir(str(i) + "/")

# Función para Escribir un Archivo, recibe los mensajes de prendido y apagado de la secuencia actual,
# el bpm, nombre del archivo y banco al cual pertenece
func save_to_file(messages, offMessages, bpm, filename, bank):
	var file = FileAccess.open("res://saves/" + str(bank) + "/" + filename.strip_edges() + ".mid",FileAccess.WRITE)
	const delta = 24
	var tempo = int((float(1)/(bpm/60))*1000000)
	const tone = 0 #C
	const mode = 0 #Major
	print(tempo," ",file.get_open_error())
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
	
# Función para calcular el valor del campo delta cuando es mayor que 0x7F
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
		if buffer & 0x80:
			buffer >>= 8
		else:
			break

# Función para leer un archivo, recibe los punteros a los mensajes de encencido y apagado,
# y de que archivo y banco debe leer
func read_from_file(messages, offMessages, filename, bank):
	var file = FileAccess.open("res://saves/" + str(bank) + "/" + filename.strip_edges() + ".mid",FileAccess.READ)
	var delta = 0
	var tempo = 0
	var tone = 0 
	var mode = 0 
	messages.fill([0,0,0])
	offMessages.fill([0,0,0])
	print("error",file.get_open_error())
	file.set_big_endian(true)
	var buffer = file.get_32()
	var chunklen = 0
	
	# Leer MThd
	if buffer == 0x4D546864:
		chunklen = file.get_32()
		if chunklen != 6:
			OS.alert("Error on MIDI File MThd","Error")
			return
		buffer = file.get_16()
		if buffer != 0:
			OS.alert("MIDI File not Type 0","Error")
			return
		buffer = file.get_16()
		if buffer != 1:
			OS.alert("MIDI Tracks should be 1","Error")
			return
		buffer = file.get_16()
		if buffer >= 0x7000:
			OS.alert("Negative Delta not Supported","Error")
			return
		delta = buffer
	else:
		OS.alert("Error on MIDI File MThd","Error")
		return
	
	# Leer MTrk
	buffer = file.get_32()
	if buffer == 0x4D54726B:
		print("MTrk")
		chunklen = file.get_32()
		var curOff = 0
		var curBeat = 0
		var curMsg = 0
		var curOffMsg = 0
		var index = 0
		var indexOff = 0
		while chunklen > 0:
			var result = readDelta(file)
			curOff = result[0]
			chunklen -= result[1]
			buffer = file.get_8()
			#print(buffer)
			chunklen -= 1
			# Si es System Message
			if buffer == 0xFF:
				buffer = file.get_8()
				match buffer:
					0x2F:
						buffer = file.get_8()
						chunklen -= 2
						#print("End")
					0x51:
						buffer = file.get_32()
						tempo = buffer & 0xFFFFFF
						chunklen -= 5
						#print("Tempo")
					0x58:
						buffer = file.get_8()
						buffer = file.get_32()
						if buffer & 0xFFFF0000 != 0x04020000:
							OS.alert("Only 4/4 is supported","Error")
							return
						chunklen -= 6
						#print("TimeSig ", chunklen)
					0x59:
						buffer = file.get_8()
						buffer = file.get_8()
						tone = buffer # Esta respecto al Circulo de Quintas, cambiar
						buffer = file.get_8()
						mode = buffer
						chunklen -= 4
						#print("Scale")
			# Si es Track Message
			else:
				var msg = []
				if curOff != 0:
					curBeat += curOff/delta
					curMsg = 0
					curOffMsg = 0
				index = (curMsg * 32) + curBeat
				indexOff = (curOffMsg * 32) + curBeat
				msg.append(buffer)
				buffer = file.get_8()
				msg.append(buffer)
				buffer = file.get_8()
				msg.append(buffer)
				if msg[2] != 0:
					messages[index] = msg
					curMsg += 1
				else:
					offMessages[indexOff] = msg
					curOffMsg += 1
				chunklen -= 2
				
			

# Funcion para leer los campos de delta de un archivo MIDI
func readDelta(file) -> Array:
	var bytecount = 1
	var value = file.get_8()
	if value & 0x80:
		value &= 0x7F
		var c = file.get_8()
		bytecount += 1
		value = (value << 7) + (c & 0x7F)
		while c & 0x80:
			c = file.get_8()
			bytecount += 1
			value = (value << 7) + (c & 0x7F)
	return [value, bytecount]

# Función que devuelve los archivos que se encuentran en un banco
func getFiles(bank) -> PackedStringArray:
	var files = DirAccess.open("res://saves/" + str(bank) + "/").get_files()
	files.resize(12)
	return files

# Función para borrar un archivo
func deleteFile(filename,bank):
	print(filename)
	if filename != "":
		DirAccess.open("res://saves/" + str(bank) + "/").remove(filename + ".mid")

# Función para renombrar un archivo
func renameFile(origFilename, filename, bank):
	if filename != "" and origFilename != "":
		DirAccess.open("res://saves/" + str(bank) + "/").rename(origFilename + ".mid",filename.strip_edges() + ".mid")
