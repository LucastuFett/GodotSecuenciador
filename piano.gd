extends Screen

var keys = Array()
var tones = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
@export var edit = SELECT_TONE

var blueStyle = preload("res://themes/BlueKey.tres")
var redStyle = preload("res://themes/RedKey.tres")
var whiteStyle = preload("res://themes/WhiteKey.tres")
var blackStyle = preload("res://themes/BlackKey.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Edit/ToneEdit.text = tones[tone]
	$Edit/ScaleEdit.text = scales[scale][0]
	keys = [$NC, $"NC#", $ND, $"ND#", $NE, $NF, $"NF#", $NG, $"NG#", $NA, $"NA#", $NB]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateKeys(tone, scale, scales) -> Array:
	var actKey = tone
	var possible = []
	for key in keys:
		if key.name.contains("#"):
			key.add_theme_stylebox_override("panel",blackStyle)
		else:
			key.add_theme_stylebox_override("panel",whiteStyle)
	possible.append(tone)
	keys[tone].add_theme_stylebox_override("panel",blueStyle)
	for key in scales[scale][1]:
		actKey += key
		if actKey > 11:
			actKey -= 12
		keys[actKey].add_theme_stylebox_override("panel",redStyle)
		possible.append(actKey)
	
	$Edit/ToneEdit.text = tones[tone]
	$Edit/ScaleEdit.text = scales[scale][0]
	return possible

func updateLabels(reset):
	if reset:
		$Edit/Tone.add_theme_color_override("font_color", Color.WHITE)
		$Edit/Scale.add_theme_color_override("font_color", Color.WHITE)
		$Edit/ToneEdit.add_theme_color_override("font_color", Color.WHITE)
		$Edit/ScaleEdit.add_theme_color_override("font_color", Color.WHITE)
	else:
		match edit:
			SELECT_TONE:
				$Edit/Tone.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
				$Edit/Scale.add_theme_color_override("font_color", Color.WHITE)
				$Edit/ToneEdit.add_theme_color_override("font_color", Color.WHITE)
			SELECT_SCALE:
				$Edit/Tone.add_theme_color_override("font_color", Color.WHITE)
				$Edit/Scale.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
				$Edit/ScaleEdit.add_theme_color_override("font_color", Color.WHITE)
			TONE:
				$Edit/ToneEdit.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
				$Edit/Tone.add_theme_color_override("font_color", Color.WHITE)
			SCALE:
				$Edit/ScaleEdit.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
				$Edit/Scale.add_theme_color_override("font_color", Color.WHITE)

