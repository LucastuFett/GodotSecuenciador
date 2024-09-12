extends Screen

var keys = Array()
var selection = Array()
var possible = Array()
var tones = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
var curOctave = 3

const blueStyle = preload("res://themes/BlueScale.tres")
const pinkStyle = preload("res://themes/PinkScale.tres")
const greenStyle = preload("res://themes/GreenScale.tres")
const greenSel = preload("res://themes/GreenSel.tres")
const orangeStyle = preload("res://themes/OrangeScale.tres")
const orangeSel = preload("res://themes/OrangeSel.tres")
const noStyle = preload("res://themes/TransparentKey.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in $Scale.get_children():
		keys.append(i)
	for i in $Selected.get_children():
		selection.append(i)
	paint()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getPossible():
	# possible = [[note, note2],[style, style2]]
	var actKey = tone
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
	getPossible()
	for key in keys:
		key.add_theme_stylebox_override("panel",noStyle)
	for sel in selection:
		sel.add_theme_stylebox_override("panel",noStyle)
	for i in len(possible[0]):
		keys[possible[0][i]].add_theme_stylebox_override("panel",possible[1][i])
		keys[possible[0][i]+12].add_theme_stylebox_override("panel",possible[1][i])
	var offset = 0
	if octave != curOctave:
		offset += 12
	if note in possible[0]:
		keys[possible[0][note] + offset].add_theme_stylebox_override("panel",greenStyle)
		selection[possible[0][note] + offset].add_theme_stylebox_override("panel",greenSel)
	else:
		keys[note + offset].add_theme_stylebox_override("panel",orangeStyle)
		selection[note + offset].add_theme_stylebox_override("panel",orangeSel)
