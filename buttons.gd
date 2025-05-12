class_name Buttons
extends Main

const beatButtons = [65, 83, 68, 70, 71, 72, 74, 75,
					 90, 88, 67, 86, 66, 78, 77, 44]
const blueStyle = preload("res://themes/BlueBtn.tres")
const greyStyle = preload("res://themes/GreyBtn.tres")
const purpleStyle = preload("res://themes/PurpleBtn.tres")
const redStyle = preload("res://themes/RedBtn.tres")
const orangeStyle = preload("res://themes/OrangeBtn.tres")
var listbtn = Array()
var lastNote = 0
var removedHold = 0
var toggledMode = 0
var holdTemporary = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	listbtn = [$B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $B10, $B11, $B12, $B13, $B14, $B15, $B16]
	messages.resize(320)
	offMessages.resize(320)
	beatsPerTone.resize(1536)
	channels.resize(16)
	
	channels.fill(0)
	beatsPerTone.fill(0)
	messages.fill([0,0,0])
	offMessages.fill([0,0,0])
	var n = 0
	for btn in listbtn:
		btn.pressed.connect(_buttonPress.bind(n))
		var sh = Shortcut.new()
		sh.events = Array([], TYPE_OBJECT, "Object", InputEvent)
		var inp = InputEventKey.new()
		inp.keycode = beatButtons[n]
		sh.events.append(inp)
		btn.shortcut = sh
		btn.text = OS.get_keycode_string(inp.keycode)
		n += 1
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateColors():
	var bptIndex = (note + (octave * 12)) * 16 + channel
	var beatMask = 0
	# Pintar Botones
	for i in len(listbtn):
		var num = i
		if mode32 && half:
			num += 16
		beatMask = 0x80000000 >> num	
		if beatsPerTone[bptIndex] & beatMask != 0:
			listbtn[i].add_theme_stylebox_override("normal",blueStyle)
		elif (listbtn[i].get_theme_stylebox("normal") != redStyle and listbtn[i].get_theme_stylebox("normal") != orangeStyle) or removedHold or toggledMode:
			listbtn[i].add_theme_stylebox_override("normal",greyStyle)
		if holded.has([num,channel,note+octave*12+24]):
			# Si esta en modo 16, si hay un valor mayor de 15, continuar, no pintar nada
			# Si esta en modo 32, num < 16 y half, si el end >= 16 pintar solo el final
			var endBeat = holded.get([num,channel,note+octave*12+24])
			var n = num >= 16
			var e = endBeat >= 16
			
			if ((not mode32) and (n or e)) or (n and not half) or ((not n) and (not e) and mode32 and half):
				continue
				
			if e and half:
				endBeat -= 16
			elif n and not e:
				endBeat = 15
			elif e and not half:
				endBeat = 16
			
			if (not half) or (not mode32) or (n and e):
				listbtn[i].add_theme_stylebox_override("normal",redStyle)
				
			if (not n) and e and half:
				for j in range(0,endBeat):
					listbtn[j].add_theme_stylebox_override("normal",orangeStyle)
			else:
				for j in range(i+1,endBeat):
					#print("orange",j)
					listbtn[j].add_theme_stylebox_override("normal",orangeStyle)
				
			if half or (not e):
				listbtn[endBeat].add_theme_stylebox_override("normal",redStyle)
			#print("red:",holded.get([num,channel,note+octave*12+24]))
			lastNote = note+octave*12+24
		if holded.has([i,channel,note+octave*12+24]) and mode32 and half:
			if holded.get([i,channel,note+octave*12+24]) > 15:
				for j in range(0,holded.get([i,channel,note+octave*12+24]) - 16):
						listbtn[j].add_theme_stylebox_override("normal",orangeStyle)
				listbtn[holded.get([i,channel,note+octave*12+24]) - 16].add_theme_stylebox_override("normal",redStyle)
			
		if (note+octave*12+24 != lastNote and lastNote != 0): #Agregar cuando se pasa de 16 a 32
			listbtn[i].add_theme_stylebox_override("normal",greyStyle)
		if beat == num:
			listbtn[i].add_theme_stylebox_override("normal",purpleStyle)	
	removedHold = 0
	toggledMode = 0

# Función que se llama cuando se aprieta un botón, recibe el número del botón apretado
func _buttonPress(num):
	print(holded)
	# Almacenar en messages y beatsPerTone
	# messages = [10][32], checkear dupes
	# beatsPerTone = [96][16], uint 32, ocupa 6K
	# Checkear si esta en 16 o 32
	var noteIndex = note + (octave * 12)
	var midiNote = noteIndex + 24
	var beatMask = 0
	if mode32 && half:
		num += 16
	beatMask = 0x80000000 >> num	
	var origNum = num
	var i = 0
	var bptIndex = (noteIndex * 16) + channel
	
	# Si ya esta activo
	if beatsPerTone[bptIndex] & beatMask != 0:
		channels[channel] -= 1
		while(i < 10):
			var index = (i*32) + num
			if messages[index][0] & 0xF == channel && messages[index][1] == midiNote:
				messages[index][0] = 0
				if holded.has([num,channel,midiNote]):
					num = holded.get([num,channel,midiNote])
					holded.erase([origNum,channel,midiNote])
					removedHold = 1
				if mode32:
					if num == 31:
						num = 0
					else:
						num += 1
				else:
					if num == 15:
						num = 0
					else:
						num += 1
				offMessages[(i*32) + num][0] = 0
				beatsPerTone[bptIndex] &= ~beatMask
				updateColors()
				break
			else:
				i += 1
		i = 0
		while i < 10:
			if messages[(i*32) + origNum][0] == 0:
				return
			elif offMessages[(i*32) + num][0] == 0:
				return
			else:
				i += 1
		control &= ~beatMask
	# Si no esta activo
	else:
		var checkIfNotHolded = 0
		var checkIfNotAfterHold = 0
		for j in 32:
			if holded.has([j,channel,midiNote]):
				checkIfNotHolded = num >= j and num <= holded.get([j,channel,midiNote])
				checkIfNotAfterHold = holdTemporary < j and num > holded.get([j,channel,midiNote]) 
		if not checkIfNotHolded:
			channels[channel] += 1
			while i < 10:
				var index = (i*32) + num
				if messages[index][0] == 0:
					if control & beatMask == 0:
						control |= beatMask
						#print(control)
					if hold != 2:
						messages[index] = [0x90 | channel,midiNote,velocity]
						beatsPerTone[bptIndex] |= beatMask
					if hold == 1:
						holdTemporary = num
						#print(holdTemporary)
					if mode32:
						if num == 31:
							num = 0
						else:
							num += 1
					else:
						if num == 15:
							num = 0
						else:
							num += 1
					if hold == 0:
						offMessages[(i*32) + num] = [0x90 | channel,midiNote,0]
					elif hold == 2:
						if not checkIfNotAfterHold:
							if num > holdTemporary:
								offMessages[(i*32) + num] = [0x90 | channel,midiNote,0]
								holded.merge({[holdTemporary,channel,midiNote]:num-1})
								#print(holded)
							elif num == 0:
								offMessages[(i*32) + num] = [0x90 | channel,midiNote,0]
								if mode32:
									holded.merge({[holdTemporary,channel,midiNote]:31})
								else:
									holded.merge({[holdTemporary,channel,midiNote]:15})
								#print(holded)
						hold = 0
					elif hold == 1:
						hold = 2
					beatMask = 0x80000000 >> num
					if control & beatMask == 0:
						control |= beatMask
					#print(index,messages[index])
					break
				else:
					i += 1
	updateColors()

# Función que se llama cuando se importa un nuevo archivo, actualizando la estructura beatsPerTone
func updateBPT():
	beatsPerTone.fill(0)
	var bptIndex = 0
	var beatMask = 0x80000000
	for j in 32:
		for i in 10:
			var index = (i * 32) + j
			if messages[index][0] != 0 && messages[index][2] != 0:
				bptIndex = ((messages[index][1] - 24)*16) + (messages[index][0] & 0xF)
				beatsPerTone[bptIndex] |= (beatMask >> j)
				if control & (beatMask >> j) == 0:
					control |= (beatMask >> j)

# Función que se llama cuando se importa un nuevo archivo, actualizando la estructura holded
func updateHolded():
	# Si el mensaje siguiente en messages no tiene el mismo numero pero velocidad 0, se considera un holded
	# Se busca el indice del mensaje de off, y se guardan los datos del canal, notamidi mas ambos beats
	holded.clear()
	var found = 0
	var found32 = 0
	for j in range(16,32):
		for i in 10:
			if messages[i*32 + j][0] != 0:
				found32 = 1
				break
	for i in 10:
		for j in 32:
			var index = (i * 32) + j
			if messages[index][0] != 0:
				if (j == 31 and found32) or (j == 15 and not found32):
					if offMessages[i*32][1] == messages[index][1]:
						continue
				elif offMessages[index + 1][1] == messages[index][1]:
					continue
				else:
					for k in range(j,32):
						if offMessages[(i*32) + k][1] == messages[index][1]:
							holded.merge({[j,messages[index][0]&0xF,messages[index][1]]:k})
							found = 1
							break
					if not found:
						if offMessages[(i*32)][1] == messages[index][1] and found32:
							holded.merge({[j,messages[index][0]&0xF,messages[index][1]]:31})
						elif offMessages[(i*32)][1] == messages[index][1] and not found32:
							holded.merge({[j,messages[index][0]&0xF,messages[index][1]]:15})
					found = 0
	mode32 = found32
