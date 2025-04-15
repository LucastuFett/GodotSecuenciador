class_name Screen
extends Main

static var curOctave = 2

const letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

const shLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

const special = ['0','1','2','3','4','5','6','7','8','9',"'",'.',',','/',':',';','-','_','?','!','"']

var typing = Array()
var typePointer = 0
var letterPointer = 0
var specialPointer = 0
var edit = 0			# 0 = carga de variable, 1 = moviendo entre letras, 2 = en una letra
var curPointer = 0 		# 0 = letras, 1 = especiales
var upper = 0			# 0 = minuscula, 1 = MAYUSCULA

var files = Array()
var selectedFile = 0

const currentLabel = preload("res://themes/CurrentLabel.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Actualizar Labels de Menu
	$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
	for i in $Memory/Typing.get_children():
		typing.append(i)
	for i in $Memory/Load.get_children():
		files.append(i)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_select_pressed():
	pass

func _on_left_pressed():
	match mainState:
		PROG:
			velocity -= 1
			if velocity < 0:
				velocity = 0
			# Cambiar Velocity
		SCALE:
			# Cambiar Tono
			tone -= 1
			if tone < 0:
				tone = 11
		NOTE:
			# Cambiar Nota
			note -= 1
			if note < 0:
				octave -= 1
				note = 11
			if octave < 0:
				octave = 0
		TEMPO:
			tempo[1] -= 1
			if tempo[0] == 0:
				if tempo[1] < 50:
					tempo[1] = 240
			else:
				if tempo[1] < 0:
					tempo[1] = 2
		CHANNEL:
			channel -= 1
			if channel < 0:
				channel = 15
		MEMORY:
			if edit == 1:
				typePointer -= 1
				if typePointer < 0:
					typePointer = 0
			elif edit == 2:
				if curPointer == 0:
					letterPointer -= 1
					if letterPointer < 0:
						letterPointer = 25
				elif curPointer == 1:
					specialPointer -= 1
					if specialPointer < 0:
						specialPointer = 20
	updateScreen()

func _on_right_pressed():
	match mainState:
		PROG:
			velocity += 1
			if velocity > 127:
				velocity = 127
			# Cambiar Velocity
		SCALE:
			# Cambiar Tono
			tone += 1
			if tone > 11:
				tone = 0
		NOTE:
			# Cambiar Nota
			note += 1
			if note > 11:
				octave += 1
				note = 0
			if octave > 7:
				octave = 7
		TEMPO:
			tempo[1] += 1
			if tempo[0] == 0:
				if tempo[1] > 240:
					tempo[1] = 50
			else:
				if tempo[1] > 2:
					tempo[1] = 0
		CHANNEL:
			channel += 1
			if channel > 15:
				channel = 0
		MEMORY:
			if edit == 1:
				typePointer += 1
				if typePointer > 17:
					typePointer = 17
			elif edit == 2:
				if curPointer == 0:
					letterPointer += 1
					if letterPointer > 25:
						letterPointer = 0
				elif curPointer == 1:
					specialPointer += 1
					if specialPointer > 20:
						specialPointer = 0
	updateScreen()

func updateScreen():
	match mainState:
		PROG:
			# Actualizar Label de Nota
			# Actualizar Ubicacion y Color de Selected
			$PianoGrid.getPossible()
			$PianoGrid.paint()
			$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
			$Menus/Tempo/TempoValue.text = str(tempo[1]) + "BPM"
			$Menus/Channel/ChnValue.text = str(channel + 1)
			$Menus/Rotary/Value.text = str(velocity)
		SCALE:
			# Conseguir Notas de Escala
			$PianoGrid.getPossible()
			# Pintar Escala y Notas en Grid
			# Actualizar Color de Selected
			$PianoGrid.paint()
			# Actualizar Nombre de Escala
			$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
		NOTE:
			# Actualizar Nota y Octava Actual
			# Actualizar Selected
			$PianoGrid.paint()
		TEMPO:
			$Menus/Tempo/TempoValue.text = str(tempo[1]) + "BPM"
		CHANNEL:
			$Menus/Channel/ChnValue.text = str(channel + 1)
		MEMORY:
			updateMemoryText()
		SAVELOAD:
			# Cambiar Bank al mover, poder mover que archivo de la grilla se elige
			updateBanks()
		_:
			$PianoGrid.paint()

func updateMemoryText():
	if filename != "" and edit == 0:
		for i in len(filename):
			print(filename[i])
			typing[i].text = filename[i]
		for i in typing:
			i.remove_theme_stylebox_override("normal")
		typing[0].add_theme_stylebox_override("normal",editLabel)
		edit = 1
	elif edit == 1:
		for i in typing:
			i.remove_theme_stylebox_override("normal")
		typing[typePointer].add_theme_stylebox_override("normal",editLabel)
	elif edit == 2:
		if curPointer == 0:
			if upper == 0:
				typing[typePointer].text = letters[letterPointer]
			else:
				typing[typePointer].text = shLetters[letterPointer]
		else:
			typing[typePointer].text = special[specialPointer]
		
func selectLetter():
	if edit == 1:
		edit = 2
		typing[typePointer].add_theme_stylebox_override("normal",currentLabel)
		typing[typePointer].add_theme_color_override("font_color",Color.BLACK)
		var findLower = letters.find(typing[typePointer].text)
		var findUpper = shLetters.find(typing[typePointer].text)
		var findSpecial = special.find(typing[typePointer].text)
		if findLower != -1:
			letterPointer = findLower
			curPointer = 0
			upper = 0
		if findUpper != -1:
			letterPointer = findUpper
			curPointer = 0
			upper = 1
		if findSpecial != -1:
			specialPointer = findSpecial
			curPointer = 1
	elif edit == 2:
		edit = 1
		typing[typePointer].add_theme_stylebox_override("normal",editLabel)
		typing[typePointer].add_theme_color_override("font_color",Color.WHITE)
		letterPointer = 0
		specialPointer = 0
		curPointer = 0
		upper = 0

func saveFilename():
	filename = filename.rpad(18," ")
	for i in 18:
		filename[i] = typing[i].text
	print(filename) 
	
func updateBanks():
	$Memory/Bank.text = "Bank " + str(bank)
	var found = midiFile.getFiles(bank)
	for i in len(files):
		files[i].get_child(0).text = found[i].rstrip(".mid")
