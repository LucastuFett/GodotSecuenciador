class_name Screen
extends Main

enum {EDIT_VEL, EDIT_CHN, EDIT_SCALE, EDIT_TEMPO, HOLD, PROG_MAIN, EDIT_OCTAVE}
const editingLabel = preload("res://themes/EditingLabel.tres")
signal scale_change

var menusProg = Array()
var screenState := PROG_MAIN
var selected = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	menusProg = [$Menus/Velocity/VelValue,$Menus/Channel/ChnValue,$Menus/Scale/ScaleMode,$Menus/Tempo/TempoValue,$Menus/Hold]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_select_pressed():
	pass

func _on_left_pressed():
	match screenState:
		PROG_MAIN:
			selected -= 1
			if selected < 0:
				selected = 4
		EDIT_SCALE:
			mode -= 1
			if mode < 0:
				mode = scales.size() - 1
			$Piano.getPossible()
			#$Piano.updateKeys()
	updateScreen()

func _on_right_pressed():
	match screenState:
		PROG_MAIN:
			selected += 1
			if selected > 4:
				selected = 0
		EDIT_SCALE:
			mode += 1
			if mode > scales.size() - 1:
				mode = 0
			$Piano.getPossible()
			#$Piano.updateKeys()
	updateScreen()

func updateScreen():
	match screenState:
		PROG_MAIN:
			for menu in len(menusProg):
				if menu == selected:
					menusProg[menu].add_theme_stylebox_override("normal",selectLabel)
				else:
					menusProg[menu].add_theme_stylebox_override("normal",editLabel)
		EDIT_SCALE:
			$Piano.getPossible()
			#$Piano.updateKeys()
			#$Piano.updateLabelsEdit()
		_:
			$Piano.paint()
			#$Piano.updateKeys()
