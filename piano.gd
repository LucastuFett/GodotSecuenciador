extends Screen
class_name Piano

var keys = Array()
var selection = Array()
var possible = Array()
var grid = Array()
var tones = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

const blueStyle = preload("res://themes/BlueScale.tres")
const blueCell = preload("res://themes/BlueCell.tres")
const pinkStyle = preload("res://themes/PinkScale.tres")
const pinkCell = preload("res://themes/PinkCell.tres")
const pinkSel = preload("res://themes/PinkSel.tres")
const greenStyle = preload("res://themes/GreenScale.tres")
const greenCell = preload("res://themes/GreenCell.tres")
const greenSel = preload("res://themes/GreenSel.tres")
const orangeStyle = preload("res://themes/OrangeScale.tres")
const orangeCell = preload("res://themes/OrangeCell.tres")
const orangeSel = preload("res://themes/OrangeSel.tres")
const redCell = preload("res://themes/RedCell.tres")
const noStyle = preload("res://themes/TransparentKey.tres")
const emptyCell = preload("res://themes/EmptyCell.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in $Scale.get_children():
		keys.append(i)
	for i in $Selected.get_children():
		selection.append(i)
	for i in $SequenceGrid.get_children():
		grid.append(i)
	getPossible()
	paint()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pintar los cuadrados de la grilla
	# grid[0] = Beat 15, Note 0, Octave = Cur
	# grid[23] = Beat 15, Note 11, Octave = Cur + 1
	# grid[360] = Beat 0, Note 0, Octave = Cur
	# grid[383] = Beat 0, Note 11, Octave = Cur + 1
	var gridBeat = 16
	var gridNote = 0
	var gridOctave = curOctave
	var bptIndex
	var beatMask = 0
	
	for i in len(grid):
		if i % 24 == 0:
			gridBeat -= 1
			gridNote = 0
			gridOctave = curOctave
			
		var indNote = gridNote
		if gridNote > 11:
			indNote = gridNote - 12
			if gridOctave == curOctave:
				gridOctave += 1
		
		var num = gridBeat
		if mode32 && half:
			num += 16
		bptIndex = (indNote + (gridOctave * 12)) * 16 + channel
		beatMask = 0x80000000 >> num
		#print(tones[indNote],gridBeat,gridOctave)
		if beatsPerTone[bptIndex] & beatMask != 0:
			if indNote in possible[0]:
				#print(note,indNote)
				if note == indNote:
					grid[i].add_theme_stylebox_override("panel",greenCell)
				elif indNote == possible[0][0]:
					grid[i].add_theme_stylebox_override("panel",pinkCell)
				else:
					grid[i].add_theme_stylebox_override("panel",blueCell)
			else:
				if note == indNote:
					grid[i].add_theme_stylebox_override("panel",orangeCell)
				else:
					grid[i].add_theme_stylebox_override("panel",redCell)
		else:
			grid[i].add_theme_stylebox_override("panel",emptyCell)
		gridNote += 1
			
func getPossible():
	# possible = [[note, note2],[style, style2]]
	var actKey = tone
	possible = []
	possible.append([])
	possible.append([])
	
	possible[0].append(tone)
	possible[1].append(pinkStyle)
	for key in scales[mode][1]:
		actKey += key
		if actKey > 11:
			actKey -= 12
		possible[0].append(actKey)
		possible[1].append(blueStyle)

func paint():
	# Pintar Escala y Seleccionado
	var pos = null
	for key in keys:
		key.add_theme_stylebox_override("panel",noStyle)
	for sel in selection:
		sel.add_theme_stylebox_override("panel",noStyle)
	for i in len(possible[0]):
		keys[possible[0][i]].add_theme_stylebox_override("panel",possible[1][i])
		keys[possible[0][i]+12].add_theme_stylebox_override("panel",possible[1][i])
		if note == possible[0][i]:
			pos = i
	var offset = 0
	if octave == curOctave - 1:
		curOctave -= 2
	if octave == curOctave + 2:
		curOctave += 2
	if octave == curOctave + 1:
		offset += 12
	if mainState != SCALE:
		if pos != null:
			keys[possible[0][pos] + offset].add_theme_stylebox_override("panel",greenStyle)
			selection[possible[0][pos] + offset].add_theme_stylebox_override("panel",greenSel)
		else:
			keys[note + offset].add_theme_stylebox_override("panel",orangeStyle)
			selection[note + offset].add_theme_stylebox_override("panel",orangeSel)
	else:
		selection[tone].add_theme_stylebox_override("panel",pinkSel)
		selection[tone + 12].add_theme_stylebox_override("panel",pinkSel)
	$Octave.text = "C" + str(curOctave)
