class_name Main
extends Control

enum {MAIN, PROG, NOTE, MEMORY, CHANNEL, TEMPO, SCALE, PLAY, LAUNCH, DAW}
const labels = [["Programming", "Play", "Launch", "DAW","","","",""],["Note", "Play/Pause", "Stop", "Hold","Memory","Channel","Tempo","Scale"],["Accept", "Octave -", "Octave +", "Cancel","","","",""]]
const titles = ["Main - Config", "Programming", "Edit Note"]
const scales = [["Major", [2,2,1,2,2,2]], ["Minor", [2,1,2,2,1,2]], ["Chromatic", [1,1,1,1,1,1,1,1,1,1,1]]]
const editLabel = preload("res://themes/EditableLabel.tres")
signal ok
var midi : Midi

var mainState := MAIN
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
	match mainState:
		NOTE:
			octave -= 1
		_:
			pass
			
func _on_f_3_pressed():
	match mainState:
		NOTE:
			octave += 1
		_:
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
			$Screen/PianoGrid.set_visible(false)
			$Screen/Menus.set_visible(false)
		PROG:
			$Screen/PianoGrid.set_visible(true)
			$Screen/Menus.set_visible(true)
		NOTE:
			pass
	
	$Screen/Title.text = titles[mainState]
	$Screen/Labels/LF1.text = labels[mainState][0]
	$Screen/Labels/LF2.text = labels[mainState][1]
	$Screen/Labels/LF3.text = labels[mainState][2]
	$Screen/Labels/LF4.text = labels[mainState][3]
	if labels[mainState][4] != "":
		$Screen/Labels/SH1.visible = true
		$Screen/Labels/SH1.text = labels[mainState][4]
	else:
		$Screen/Labels/SH1.visible = false
	if labels[mainState][5] != "":
		$Screen/Labels/SH2.visible = true
		$Screen/Labels/SH2.text = labels[mainState][5]
	else:
		$Screen/Labels/SH2.visible = false
	if labels[mainState][6] != "":
		$Screen/Labels/SH3.visible = true
		$Screen/Labels/SH3.text = labels[mainState][6]
	else:
		$Screen/Labels/SH3.visible = false
	if labels[mainState][7] != "":
		$Screen/Labels/SH4.visible = true
		$Screen/Labels/SH4.text = labels[mainState][7]
	else:
		$Screen/Labels/SH4.visible = false
