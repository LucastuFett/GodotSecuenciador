class_name Screen
extends Main

static var curOctave = 2
const letters = [
  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',
  'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
]
const shLetters = [
  'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
  'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':',
  'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?',
  '!', '@', '#', '$', '%', '_', '-', '*', '(', ')'
]


# Called when the node enters the scene tree for the first time.
func _ready():
	# Actualizar Labels de Menu
	$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
	for i in $Memory/Keyboard.get_child_count():
		$Memory/Keyboard.get_children()[i].text = letters[i]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_select_pressed():
	pass

func _on_left_pressed():
	match mainState:
		PROG:
			pass
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
	updateScreen()

func _on_right_pressed():
	match mainState:
		PROG:
			pass
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
		_:
			$PianoGrid.paint()
