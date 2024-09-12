class_name Screen
extends Main

signal scale_change

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
			pass
			# Cambiar Tono
	updateScreen()

func _on_right_pressed():
	match mainState:
		PROG:
			pass
			# Cambiar Velocity
		SCALE:
			pass
			# Cambiar Tono
	updateScreen()

func updateScreen():
	match mainState:
		PROG:
			pass
			# Actualizar Label de Nota
			# Actualizar Ubicacion y Color de Selected
		SCALE:
			# Conseguir Notas de Escala
			# Pintar Escala y Notas en Grid
			# Actualizar Nombre de Escala
			# Actualizar Color de Selected
			$Piano.getPossible()
			#$Piano.updateKeys()
			#$Piano.updateLabelsEdit()
		NOTE:
			pass
			# Actualizar Nota y Octava Actual
			# Actualizar Selected
		_:
			$Piano.paint()
			#$Piano.updateKeys()
