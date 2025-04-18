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
		elif listbtn[i].get_theme_stylebox("normal") != redStyle and listbtn[i].get_theme_stylebox("normal") != orangeStyle :
			listbtn[i].add_theme_stylebox_override("normal",greyStyle)
		if holded.has([num,channel,note+octave*12+24]):
			#print("red:",i)
			listbtn[i].add_theme_stylebox_override("normal",redStyle)
			for j in range(i+1,holded.get([num,channel,note+octave*12+24])):
				#print("orange",j)
				listbtn[j].add_theme_stylebox_override("normal",orangeStyle)
			listbtn[holded.get([num,channel,note+octave*12+24])].add_theme_stylebox_override("normal",redStyle)
			#print("red:",holded.get([num,channel,note+octave*12+24]))
		if beat == num:
			listbtn[i].add_theme_stylebox_override("normal",purpleStyle)	

# Función que se llama cuando se aprieta un botón, recibe el número del botón apretado
func _buttonPress(num):
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
	var i = 0
	var bptIndex = (noteIndex * 16) + channel
	
	# Si ya esta activo
	# Agregar que pasa si esta holdeado, debe borrar el mismo, la entrada en holded y el ultimo off
	if beatsPerTone[bptIndex] & beatMask != 0:
		channels[channel] -= 1
		while(i < 10):
			var index = (i*32) + num
			if messages[index][0] & 0xF == channel && messages[index][1] == midiNote:
				messages[index][0] = 0
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
			if messages[(i*32) + num][0] == 0:
				return
			elif offMessages[(i*32) + num][0] == 0:
				return
			else:
				i += 1
		control &= ~beatMask
	# Si no esta activo
	else:
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
					print(holdTemporary)
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
