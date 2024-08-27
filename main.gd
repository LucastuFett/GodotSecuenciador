class_name Main
extends Control

enum {MAIN, PROG, NOTE, MEMORY, PLAY, LAUNCH, DAW}
const labels = [["Prog", "Play", "Launch", "DAW"],["Note", "Play\nPause", "Stop", "Memory"],["Accept", "", "", "Cancel"]]
const titles = ["Main - Config", "Programming", "Edit Note"]
const scales = [["Major", [2,2,1,2,2,2]], ["Minor", [2,1,2,2,1,2]], ["Chromatic", [1,1,1,1,1,1,1,1,1,1,1]]]
const editLabel = preload("res://themes/EditableLabel.tres")
const selectLabel = preload("res://themes/SelectedLabel.tres")
signal ok
var midi : Midi

var mainState := MAIN
var possible = Array()
var messages = Array()
var beatsPerTone = Array()
var beat := 1
var tone = 0
var mode = 0
var note = 0
var octave = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	midi = Midi.new()
	#$Timer.wait_time = 1/($SpinBox.value/60)
	$Timer.start()
	changeState()
	ok.connect($Screen._on_select_pressed.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_select_pressed():
	if mainState == NOTE:
		mainState = PROG
		changeState()
	ok.emit()

func _on_f_1_pressed():
	match mainState:
		MAIN:
			mainState = PROG
		PROG:
			mainState = NOTE
		NOTE:
			mainState = PROG
	changeState()

func _on_f_2_pressed():
	pass

func _on_exit_pressed():
	match mainState:
		PROG:
			mainState = MAIN
		NOTE:
			mainState = PROG
	changeState()
	
#func _on_timer_timeout():
	#beatPlay(beat)
	#beat += 1
	#if beat == 17:
		#beat = 1
		

#func beatPlay(beat):
	#midi.sendNoteOff(15, 60, 127)
	#if $Buttons.pressed[beat - 1]:
		#midi.sendNoteOn(15, 60, 127)

func changeState():
	match mainState:
		MAIN:
			$Screen/Piano.set_visible(false)
			$Screen/Menus/Velocity.set_visible(false)
			$Screen/Menus/Channel.set_visible(false)
			$Screen/Menus/Scale.set_visible(false)
			$Screen/Menus/Tempo.set_visible(false)
			$Screen/Menus/Hold.set_visible(false)
		PROG:
			$Screen/Piano.set_visible(true)
			$Screen/Menus/Velocity.set_visible(true)
			$Screen/Menus/Channel.set_visible(true)
			$Screen/Menus/Scale.set_visible(true)
			$Screen/Menus/Tempo.set_visible(true)
			$Screen/Menus/Hold.set_visible(true)
			
			$Screen/Menus/Velocity/VelValue.add_theme_stylebox_override("normal",selectLabel)
			$Screen/Menus/Channel/ChnValue.add_theme_stylebox_override("normal",editLabel)
			$Screen/Menus/Scale/ScaleMode.add_theme_stylebox_override("normal",editLabel)
			$Screen/Menus/Tempo/TempoValue.add_theme_stylebox_override("normal",editLabel)
			$Screen/Menus/Hold.add_theme_stylebox_override("normal",editLabel)
		NOTE:
			$Screen/Menus/Velocity/VelValue.remove_theme_stylebox_override("normal")
			$Screen/Menus/Channel/ChnValue.remove_theme_stylebox_override("normal")
			$Screen/Menus/Scale/ScaleMode.remove_theme_stylebox_override("normal")
			$Screen/Menus/Tempo/TempoValue.remove_theme_stylebox_override("normal")
			$Screen/Menus/Hold.remove_theme_stylebox_override("normal")
	
	$Screen/Title.text = titles[mainState]
	$Screen/Controls/LF1.text = labels[mainState][0]
	$Screen/Controls/LF2.text = labels[mainState][1]
	$Screen/Controls/LF3.text = labels[mainState][2]
	$Screen/Controls/LF4.text = labels[mainState][3]



