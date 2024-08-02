extends Screen

var keys = Array()
var tones = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
var possibleNotes = []
#@export var edit = SELECT_TONE

const blueStyle = preload("res://themes/BlueKey.tres")
const redStyle = preload("res://themes/RedKey.tres")
const greenStyle = preload("res://themes/GreenKey.tres")
const whiteStyle = preload("res://themes/WhiteKey.tres")
const blackStyle = preload("res://themes/BlackKey.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	#$Scale/ToneEdit.text = tones[tone]
	#$Scale/ScaleEdit.text = scales[scale][0]
	keys = [$NC, $"NC#", $ND, $"ND#", $NE, $NF, $"NF#", $NG, $"NG#", $NA, $"NA#", $NB]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getPossible(tone, scale, scales) -> Array:
	# possible = [[note, note2],[style, style2]]
	var actKey = tone
	possibleNotes = []
	possibleNotes.append([])
	possibleNotes.append([])
	
	possibleNotes[0].append(tone)
	possibleNotes[1].append(blueStyle)
	for key in scales[scale][1]:
		actKey += key
		if actKey > 11:
			actKey -= 12
		possibleNotes[0].append(actKey)
		possibleNotes[1].append(redStyle)
	
	$Scale/ToneEdit.text = tones[tone]
	$Scale/ScaleEdit.text = scales[scale][0]
	return possibleNotes

func updateKeys(possible):
	for key in keys:
		if key.name.contains("#"):
			key.add_theme_stylebox_override("panel",blackStyle)
		else:
			key.add_theme_stylebox_override("panel",whiteStyle)
	for i in len(possible[0]):
		keys[possible[0][i]].add_theme_stylebox_override("panel",possible[1][i])

#func updateLabelsEdit():
	#match edit:
		#SELECT_TONE:
			#$Scale/Tone.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
			#$Scale/Scale.add_theme_color_override("font_color", Color.WHITE)
			#$Scale/ToneEdit.add_theme_color_override("font_color", Color.WHITE)
		#SELECT_SCALE:
			#$Scale/Tone.add_theme_color_override("font_color", Color.WHITE)
			#$Scale/Scale.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
			#$Scale/ScaleEdit.add_theme_color_override("font_color", Color.WHITE)
		#TONE:
			#$Scale/ToneEdit.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
			#$Scale/Tone.add_theme_color_override("font_color", Color.WHITE)
		#SCALE:
			#$Scale/ScaleEdit.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
			#$Scale/Scale.add_theme_color_override("font_color", Color.WHITE)

func updateLabelsMenu(scale, note, octave):
	$Menu/Scale.text = scale
	$Menu/Note.text = tones[note] + str(octave)

func changeKeys():
	pass
