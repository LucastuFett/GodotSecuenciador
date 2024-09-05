extends Screen

var keys = Array()
var tones = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

const blueStyle = preload("res://themes/BlueKey.tres")
const redStyle = preload("res://themes/RedKey.tres")
const pinkStyle = preload("res://themes/PinkKey.tres")
const greenStyle = preload("res://themes/GreenKey.tres")
const whiteStyle = preload("res://themes/WhiteKey.tres")
const blackStyle = preload("res://themes/BlackKey.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	keys = [$NC, $"NC#", $ND, $"ND#", $NE, $NF, $"NF#", $NG, $"NG#", $NA, $"NA#", $NB]
	getPossible()
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
	possible[1].append(blueStyle)
	for key in scales[mode][1]:
		actKey += key
		if actKey > 11:
			actKey -= 12
		possible[0].append(actKey)
		possible[1].append(redStyle)
	
	$"../Menus/Scale/ScaleValue".text = tones[tone] + " " + scales[mode][0]

func paint():
	for key in keys:
		if key.name.contains("#"):
			key.add_theme_stylebox_override("panel",blackStyle)
		else:
			key.add_theme_stylebox_override("panel",whiteStyle)
	for i in len(possible[0]):
		keys[possible[0][i]].add_theme_stylebox_override("panel",possible[1][i])

