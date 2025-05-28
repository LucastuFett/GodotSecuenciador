class_name Screen
extends Main

const labels = [["Programming", "Play", "Launch", "DAW","","","",""],
				["Note", "Play/Pause", "Stop", "Hold","Memory","Channel","Tempo","Scale"],
				["Accept", "Octave -", "Octave +", "Cancel","","","",""],
				["Save","Shift","Backspace","Load","","Special","Space",""],
				["Accept","Bank -","Bank +","Cancel","","Rename","Delete",""],
				["Save","Shift","Backspace","Cancel","","Special","Space",""],
				["Accept","","","Cancel","","","",""],
				["Accept","Internal","External","Cancel","","","",""],
				["Accept","Mode -","Mode +","Cancel","","","",""],
				["Play/Pause","Bank -","Bank +","Stop","","","",""]]

const titles = ["Main - Config", 
				"Programming", 
				"Edit Note",
				"Memory",
				"Save/Load",
				"Rename",
				"Edit Channel",
				"Edit Tempo",
				"Edit Scale",
				"Play"]
				
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
	
	$Controls/Toggle.set_pressed_no_signal(mode32)
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
