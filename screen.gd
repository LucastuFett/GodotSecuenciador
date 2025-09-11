class_name Screen
extends Main

const labels = [["Sequencer", "Play", "Launch", "DAW","","","",""],
				["Note", "Play/Pause", "Stop", "Hold","Memory","Channel","Tempo","Scale"],
				["Accept", "Octave -", "Octave +", "Cancel","","","",""],
				["Save","Shift","Backspace","Load","","Special","Space",""],
				["Accept","Bank -","Bank +","Cancel","","Rename","Delete",""],
				["Save","Shift","Backspace","Cancel","","Special","Space",""],
				["Accept","","","Cancel","","","",""],
				["Accept","Internal","External","Cancel","","","",""],
				["Accept","Mode -","Mode +","Cancel","","","",""],
				["Play/Pause","Bank -","Bank +","Stop","","","",""],
				["Tone -","Mode -","Mode +","Tone +","","Channel -","Channel +",""],
				["", "Play/Pause", "Stop", "", "", "", "", ""]]

const titles = ["Main - Config", 
				"Edit\nSeq", 
				"Edit Note",
				"Memory",
				"Save/Load",
				"Rename",
				"Edit Channel",
				"Edit Tempo",
				"Edit Scale",
				"Play",
				"Launchpad/Keyboard",
				"DAW"]
				
const letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

const shLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

const special = ['0','1','2','3','4','5','6','7','8','9',"'",'.',',','/',':',';','-','_','?','!','"']

const bluePanel = preload("res://themes/BlueBtn.tres")
const greyPanel = preload("res://themes/GreyBtn.tres")
const purplePanel = preload("res://themes/PurpleBtn.tres")
const currentLabel = preload("res://themes/CurrentLabel.tres")

var typing = Array()
var typePointer = 0
var letterPointer = 0
var specialPointer = 0
var edit = 0			# 0 = carga de variable, 1 = moviendo entre letras, 2 = en una letra
var curPointer = 0 		# 0 = letras, 1 = especiales
var upper = 0			# 0 = minuscula, 1 = MAYUSCULA

var files = Array()
var selectedFile = 0
var currentFile


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
	if hold == 0:
		$Menus/Hold.set_visible(false)
	elif hold == 1:
		$Menus/Hold.set_visible(true)
		$Menus/Hold.text = "1st Value"
	elif hold == 2:
		$Menus/Hold.set_visible(true)
		$Menus/Hold.text = "2nd Value"

func _on_left_pressed():
	match mainState:
		MEMORY,RENAME:
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
		SAVELOAD,PLAY:
			selectedFile -= 1
			if selectedFile < 0:
				selectedFile = 11

func _on_right_pressed():
	match mainState:
		MEMORY,RENAME:
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
		SAVELOAD,PLAY:
			selectedFile += 1
			if selectedFile > 11:
				selectedFile = 0

# Función para actualizar los contenidos de la pantalla en cada modo
func updateScreen():
	match mainState:
		MAIN:
			$Launchpad.set_visible(false)
			$PianoGrid.set_visible(false)
			$Menus.set_visible(false)
			$Title.set_visible(true)
			$TitleProg.set_visible(false)
			$Memory.set_visible(false)
			$Memory/Load.set_visible(false)
			$Memory/Bank.set_visible(false)
		PLAY:
			$Title.set_visible(true)
			$Memory.set_visible(true)
			$Memory/Load.set_visible(true)
			$Memory/Bank.set_visible(true)
			updateBanks()
		PROG:
			$PianoGrid.set_visible(true)
			$Menus.set_visible(true)
			$Title.set_visible(false)
			$TitleProg.set_visible(true)
			$Memory.set_visible(false)
			$PianoGrid.possible = $PianoGrid.getPossible(tone, mode)
			$PianoGrid.paintScales()
			$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
			$Menus/Tempo/TempoValue.text = str(tempo[1]) + "BPM"
			$Menus/Channel/ChnValue.text = str(channel + 1)
			$Menus/Rotary/Value.text = str(velocity)
		SCALE:
			# Conseguir Notas de Escala
			$PianoGrid.getPossible()
			# Pintar Escala y Notas en Grid
			# Actualizar Color de Selected
			$PianoGrid.paintScales()
			# Actualizar Nombre de Escala
			$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
		NOTE:
			# Actualizar Nota y Octava Actual
			# Actualizar Selected
			$PianoGrid.paintScales()
		TEMPO:
			$Menus/Tempo/TempoValue.text = str(tempo[1]) + "BPM"
		CHANNEL:
			$Menus/Channel/ChnValue.text = str(channel + 1)
		MEMORY:
			$Memory.set_visible(true)
			$PianoGrid.set_visible(false)
			$Menus.set_visible(false)
			$Title.set_visible(true)
			$TitleProg.set_visible(false)
			$Memory/Load.set_visible(false)
			$Memory/Bank.set_visible(false)
			$Memory/GridBorder.set_visible(true)
			$Memory/Typing.set_visible(true)
			updateMemoryText()
		RENAME:
			$Memory/Load.set_visible(false)
			$Memory/Bank.set_visible(false)
			$Memory/GridBorder.set_visible(true)
			$Memory/Typing.set_visible(true)
			updateMemoryText()
		SAVELOAD:
			$Memory/Load.set_visible(true)
			$Memory/Bank.set_visible(true)
			$Memory/GridBorder.set_visible(false)
			$Memory/Typing.set_visible(false)
			updateBanks()
		LAUNCH,DAW:
			$Launchpad.set_visible(true)
			updateLaunch()

	$Title.text = titles[mainState]
	$TitleProg.text = titles[mainState]
	$Labels/LF1.text = labels[mainState][0]
	$Labels/LF2.text = labels[mainState][1]
	$Labels/LF3.text = labels[mainState][2]
	$Labels/LF4.text = labels[mainState][3]
	if labels[mainState][4] != "":
		$Labels/SH1.visible = true
		$Labels/SH1.text = labels[mainState][4]
	else:
		$Labels/SH1.visible = false
	if labels[mainState][5] != "":
		$Labels/SH2.visible = true
		$Labels/SH2.text = labels[mainState][5]
	else:
		$Labels/SH2.visible = false
	if labels[mainState][6] != "":
		$Labels/SH3.visible = true
		$Labels/SH3.text = labels[mainState][6]
	else:
		$Labels/SH3.visible = false
	if labels[mainState][7] != "":
		$Labels/SH4.visible = true
		$Labels/SH4.text = labels[mainState][7]
	else:
		$Labels/SH4.visible = false
	if mode32:
		$Menus/Toggler/Mode.text = "32 St"
	else:
		$Menus/Toggler/Mode.text = "16 St"
	if mode32 && half:
		$"Menus/Toggler/1-16".add_theme_color_override("font_color",Color.GRAY)
		$"Menus/Toggler/17-32".add_theme_color_override("font_color",Color.WHITE)
	else:
		$"Menus/Toggler/1-16".add_theme_color_override("font_color",Color.WHITE)
		$"Menus/Toggler/17-32".add_theme_color_override("font_color",Color.GRAY)

# Función para actualizar el texto que se va escribiendo en el nombre
func updateMemoryText():
	var name = ""
	if mainState == MEMORY:
		name = filename
	elif mainState == RENAME:
		name = renameFilename
	if name != "" and edit == 0:
		for i in len(name):
			print(name[i])
			typing[i].text = name[i]
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

# Función que se llama al poner seleccionar en una letra para guardarla
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

# Función para guardar el archivo
func saveFilename() -> String:
	var name = filename
	name = name.rpad(18," ")
	for i in 18:
		name[i] = typing[i].text
	edit = 0
	letterPointer = 0
	specialPointer = 0
	curPointer = 0
	upper = 0
	return name

# Función para cargar el nombre de los archivos en la interfaz
func updateBanks():
	$Memory/Bank.text = "Bank " + str(bank)
	var found = midiFile.getFiles(bank)
	for i in len(files):
		if i == selectedFile:
			files[i].add_theme_stylebox_override("panel",bluePanel)
		else:
			files[i].add_theme_stylebox_override("panel",greyPanel)
		if mainState == PLAY and i == currentFile:
			files[i].add_theme_stylebox_override("panel",purplePanel)
		files[i].get_child(0).text = found[i].rstrip(".mid")

# Función para escribir el nombre del archivo seleccionado en el programa
func getFilename() -> String:
	if mainState == PLAY:
		currentFile = selectedFile
	return files[selectedFile].get_child(0).text
	print(filename)

# Función para analizar el modo de funcionamiento launch/key y realizar los cambios necesarios
func updateLaunch():
	if mainState == LAUNCH:
		$Launchpad/Channel.set_visible(true)
		$Launchpad/Channel.text = "Channel " + str(launchChn+1)
		if launchType == false:	# Launchpad
			launchPossible = $PianoGrid.getPossible(launchTone, launchMode)
			$Launchpad/Keyboard.set_visible(false)
			$Launchpad/Scale.set_visible(true)
			$Launchpad/Scale.text = $PianoGrid.tones[launchTone] + " " + scales[launchMode][0]
			$Launchpad/Launchpad.set_visible(true)
			var sbf1 = StyleBoxFlat.new()
			var sbf4 = StyleBoxFlat.new()
			var sbf8 = StyleBoxFlat.new()
			sbf1.bg_color = Color(0.99,0.19,0.14)
			sbf4.bg_color = Color(0.82,0.52,0.1)
			sbf8.bg_color = Color(0.8,0,0.97)
			$"Launchpad/Keys/1".add_theme_stylebox_override("panel",sbf1)
			$"Launchpad/Keys/4".add_theme_stylebox_override("panel",sbf4)
			$"Launchpad/Keys/8".add_theme_stylebox_override("panel",sbf8)
			for i in 8:
				if (i == 7):
					var noteIndexLow = launchPossible[0][0] + ((launchOctave+1) * 12) + 24
					var noteIndexHigh = launchPossible[0][0] + ((launchOctave+2) * 12) + 24
					get_node("Launchpad/Keys/"+str(i+1)+"/Name").text = $PianoGrid.tones[launchPossible[0][0]] + str(launchOctave+1)
					launchMessages[i] = [0x90 | launchChn,noteIndexLow,127]
					get_node("Launchpad/Keys/"+str(i+9)+"/Name").text = $PianoGrid.tones[launchPossible[0][0]] + str(launchOctave+2)
					launchMessages[i+8] = [0x90 | launchChn,noteIndexHigh,127]
				else:
					var noteIndexLow = launchPossible[0][i] + ((launchOctave) * 12) + 24
					var noteIndexHigh = launchPossible[0][i] + ((launchOctave+1) * 12) + 24
					get_node("Launchpad/Keys/"+str(i+1)+"/Name").text = $PianoGrid.tones[launchPossible[0][i]] + str(launchOctave)
					launchMessages[i] = [0x90 | launchChn,noteIndexLow,127]
					get_node("Launchpad/Keys/"+str(i+9)+"/Name").text = $PianoGrid.tones[launchPossible[0][i]] + str(launchOctave+1)
					launchMessages[i+8] = [0x90 | launchChn,noteIndexHigh,127]
		else:	# Keyboard
			$Launchpad/Keyboard.set_visible(true)
			$Launchpad/Scale.set_visible(false)
			$Launchpad/Launchpad.set_visible(false)
			$"Launchpad/Keys/1".remove_theme_stylebox_override("panel")
			$"Launchpad/Keys/4".remove_theme_stylebox_override("panel")
			$"Launchpad/Keys/8".remove_theme_stylebox_override("panel")
			
			$"Launchpad/Keys/1/Name".text = ""
			$"Launchpad/Keys/2/Name".text = "C#" + str(launchOctave)
			$"Launchpad/Keys/3/Name".text = "D#" + str(launchOctave)
			$"Launchpad/Keys/4/Name".text = ""
			$"Launchpad/Keys/5/Name".text = "F#" + str(launchOctave)
			$"Launchpad/Keys/6/Name".text = "G#" + str(launchOctave)
			$"Launchpad/Keys/7/Name".text = "A#" + str(launchOctave)
			$"Launchpad/Keys/8/Name".text = ""
			
			$"Launchpad/Keys/9/Name".text = "C" + str(launchOctave)
			$"Launchpad/Keys/10/Name".text = "D" + str(launchOctave)
			$"Launchpad/Keys/11/Name".text = "E" + str(launchOctave)
			$"Launchpad/Keys/12/Name".text = "F" + str(launchOctave)
			$"Launchpad/Keys/13/Name".text = "G" + str(launchOctave)
			$"Launchpad/Keys/14/Name".text = "A" + str(launchOctave)
			$"Launchpad/Keys/15/Name".text = "B" + str(launchOctave)
			$"Launchpad/Keys/16/Name".text = "C" + str(launchOctave+1)
			
			launchMessages[0] = [0,0,0]
			launchMessages[1] = [0x90 | launchChn,1 + ((launchOctave) * 12) + 24,127]
			launchMessages[2] = [0x90 | launchChn,3 + ((launchOctave) * 12) + 24,127]
			launchMessages[3] = [0,0,0]
			launchMessages[4] = [0x90 | launchChn,6 + ((launchOctave) * 12) + 24,127]
			launchMessages[5] = [0x90 | launchChn,8 + ((launchOctave) * 12) + 24,127]
			launchMessages[6] = [0x90 | launchChn,10 + ((launchOctave) * 12) + 24,127]
			launchMessages[7] = [0,0,0]
			
			launchMessages[8] = [0x90 | launchChn,0 + ((launchOctave) * 12) + 24,127]
			launchMessages[9] = [0x90 | launchChn,2 + ((launchOctave) * 12) + 24,127]
			launchMessages[10] = [0x90 | launchChn,4 + ((launchOctave) * 12) + 24,127]
			launchMessages[11] = [0x90 | launchChn,5 + ((launchOctave) * 12) + 24,127]
			launchMessages[12] = [0x90 | launchChn,7 + ((launchOctave) * 12) + 24,127]
			launchMessages[13] = [0x90 | launchChn,9 + ((launchOctave) * 12) + 24,127]
			launchMessages[14] = [0x90 | launchChn,11 + ((launchOctave) * 12) + 24,127]
			launchMessages[15] = [0x90 | launchChn,0 + ((launchOctave+1) * 12) + 24,127]
	else:
		$Launchpad/Channel.set_visible(false)
		$Launchpad/Scale.set_visible(false)
		$Launchpad/Launchpad.set_visible(false)
		$Launchpad/Keyboard.set_visible(false)
		var sbf1 = StyleBoxFlat.new()
		var sbf4 = StyleBoxFlat.new()
		var sbf8 = StyleBoxFlat.new()
		sbf1.bg_color = Color(0.99,0.19,0.14)
		sbf4.bg_color = Color(0.82,0.52,0.1)
		sbf8.bg_color = Color(0.8,0,0.97)
		$"Launchpad/Keys/1".add_theme_stylebox_override("panel",sbf1)
		$"Launchpad/Keys/4".add_theme_stylebox_override("panel",sbf4)
		$"Launchpad/Keys/8".add_theme_stylebox_override("panel",sbf8)
		for i in 16:
			get_node("Launchpad/Keys/"+str(i+1)+"/Name").text = str(102 + i)
			launchMessages[i] = [0xB0,102 + i,127] 
