extends Screen
class_name Piano

var keys = Array()
var selection = Array()
var possible = Array()
var grid = Array()
var tones = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
var curOctave = 2

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
	paintScales()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pintar los cuadrados de la grilla
	# grid[0] = Beat 15, Note 11, Octave = Cur + 1
	# grid[23] = Beat 15, Note 0, Octave = Cur 
	# grid[360] = Beat 0, Note 11, Octave = Cur + 1
	# grid[383] = Beat 0, Note 0, Octave = Cur
	var gridBeat = 16
	var gridNote = 0
	var gridOctave = curOctave
	var bptIndex
	var beatMask = 0
	
	for i in len(grid):
		# Si se termina de ver una linea, se reinicia a la nota original, octava cur + 1
		if i % 24 == 0:
			gridBeat -= 1
			gridNote = 11
			gridOctave = curOctave + 1
		
		# Si la nota ya llego a menos de 0, se la vuelve a 11, y se reduce la octava
		var indNote = gridNote
		if gridNote < 0:
			indNote = gridNote + 12
			if gridOctave == curOctave + 1:
				gridOctave -= 1
		
		var num = gridBeat
		if mode32 && half:
			num += 16
		bptIndex = (indNote + (gridOctave * 12)) * 16 + channel
		beatMask = 0x80000000 >> num
		#print(tones[indNote],gridBeat,gridOctave)
		if beatsPerTone[bptIndex] & beatMask != 0:
			if indNote in possible[0]:
				#print(note,indNote)
				if (note == indNote && octave == gridOctave):
					grid[i].add_theme_stylebox_override("panel",greenCell)
				elif indNote == possible[0][0]:
					grid[i].add_theme_stylebox_override("panel",pinkCell)
				else:
					grid[i].add_theme_stylebox_override("panel",blueCell)
			else:
				if (note == indNote && octave == gridOctave):
					grid[i].add_theme_stylebox_override("panel",orangeCell)
				else:
					grid[i].add_theme_stylebox_override("panel",redCell)
		else:
			grid[i].add_theme_stylebox_override("panel",emptyCell)
		gridNote -= 1
	for i in holded.keys():
		# Fijarse en cada holded, sobreescribir lo anterior
		#print(i[2],curOctave)
		var endBeat = holded.get(i)
		var n = i[0] >= 16
		var e = endBeat >= 16
		var firstBeat = i[0]
		
		if ((not mode32) and (n or e)) or (n and not half) or ((not n) and (not e) and mode32 and half):
			continue
			
		if e and half:
			endBeat -= 16
		elif (n and not e) or (e and not half):
			endBeat = 15
		
		if n:
			firstBeat -= 16
		elif (not n) and e and half:
			firstBeat = 0
		
		if i[1] == channel:
			if i[2] >= curOctave*12 + 24 and i[2] < (curOctave+2)*12 + 24:
				var holdNote = ((i[2] - 24) % 12)
				var paintNote = 11 - ((i[2] - 24) % 12)
				var paintOctave = ((i[2] - 24) / 12)
				var firstGrid
				if paintOctave == curOctave:
					firstGrid = (15 - firstBeat)*24 + paintNote + 12
				else:
					firstGrid = (15 - firstBeat)*24 + paintNote 
				
				for j in range(firstGrid,firstGrid - 1 - (endBeat-firstBeat)*24,-24):
					if holdNote in possible[0]:
						#print(note,holdNote, octave, paintOctave)
						if (note == holdNote && octave == paintOctave):
							grid[j].add_theme_stylebox_override("panel",greenCell)
						elif holdNote == possible[0][0]:
							grid[j].add_theme_stylebox_override("panel",pinkCell)
						else:
							grid[j].add_theme_stylebox_override("panel",blueCell)
					else:
						if (note == holdNote && octave == paintOctave):
							grid[j].add_theme_stylebox_override("panel",orangeCell)
						else:
							grid[j].add_theme_stylebox_override("panel",redCell)
				#print(i[0],i[2])

# Función para devolver las notas que pertenecen a una escala determinada
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

# Función para pintar Escala y Seleccionado
func paintScales():
	var pos = null
	for key in keys:
		key.add_theme_stylebox_override("panel",noStyle)
	for sel in selection:
		sel.add_theme_stylebox_override("panel",noStyle)
	for i in len(possible[0]):
		keys[23 - possible[0][i]].add_theme_stylebox_override("panel",possible[1][i])
		keys[23 - (possible[0][i]+12)].add_theme_stylebox_override("panel",possible[1][i])
		if note == possible[0][i]:
			pos = i
	var offset = 0
	if octave == curOctave - 1:
		curOctave -= 2
	if octave == curOctave + 2:
		curOctave += 2
	if octave == curOctave + 1:
		offset += 12
	print(pos)
	if mainState != SCALE:
		if pos != null:
			keys[23 - (possible[0][pos] + offset)].add_theme_stylebox_override("panel",greenStyle)
			selection[23 - (possible[0][pos] + offset)].add_theme_stylebox_override("panel",greenSel)
			print("possible + offset ",possible[0][pos] + offset)
		else:
			keys[23 - (note + offset)].add_theme_stylebox_override("panel",orangeStyle)
			selection[23 - (note + offset)].add_theme_stylebox_override("panel",orangeSel)
			print("note + offset ",note + offset)
	else:
		selection[23 - tone].add_theme_stylebox_override("panel",pinkSel)
		selection[23 - (tone + 12)].add_theme_stylebox_override("panel",pinkSel)
		print(tone)
	$Octave.text = "C" + str(curOctave)
