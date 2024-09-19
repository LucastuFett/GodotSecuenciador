class_name Screen
extends Main

static var curOctave = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Actualizar Labels de Menu
	$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
	pass
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
	updateScreen()

func updateScreen():
	match mainState:
		PROG:
			# Actualizar Label de Nota
			# Actualizar Ubicacion y Color de Selected
			$PianoGrid.getPossible()
			$PianoGrid.paint()
			$Menus/Scale/ScaleValue.text = $PianoGrid.tones[tone] + " " + scales[mode][0]
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
		_:
			$PianoGrid.paint()
			#$Piano.updateKeys()
