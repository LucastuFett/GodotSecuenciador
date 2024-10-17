class_name Main
extends Control

enum {MAIN, PROG, NOTE, MEMORY, CHANNEL, TEMPO, SCALE, PLAY, LAUNCH, DAW}
const labels = [["Programming", "Play", "Launch", "DAW","","","",""],
				["Note", "Play/Pause", "Stop", "Hold","Memory","Channel","Tempo","Scale"],
				["Accept", "Octave -", "Octave +", "Cancel","","","",""],
				["Save","","","Load","","","",""],
				["","","","","","","",""],
				["Accept","Internal","External","Cancel","","","",""],
				["Accept","Mode -","Mode +","Cancel","","","",""]]
const titles = ["Main - Config", 
				"Programming", 
				"Edit Note",
				"Memory",
				"Edit Channel",
				"Edit Tempo",
				"Edit Scale"]
const scales = [["Major", [2,2,1,2,2,2]], ["Minor", [2,1,2,2,1,2]], ["Chromatic", [1,1,1,1,1,1,1,1,1,1,1]]]
const editLabel = preload("res://themes/EditableLabel.tres")
signal ok
var midi : Midi
var midiFile : MidiFile

static var mainState := MAIN
static var messages = Array()
static var offMessages = Array()
static var beatsPerTone = PackedInt32Array()
static var beat := 0
static var tone = 0
static var mode = 0
static var note = 0
static var octave = 3
static var channel = 0
static var velocity = 0
static var channels = PackedByteArray()
static var mode32 = false
static var half = false
static var control = 0
static var tempo = [0,120] # 0 = Int, 1 = Ext, en Ext, 0 = Half, 2 = Dbl

var shift = false
var prevNote = 0
var prevMode = 0
var prevTone = 0
var prevTempo = [0,120]

# Called when the node enters the scene tree for the first time.
func _ready():
	midi = Midi.new()
	midiFile = MidiFile.new()
	velocity = int($Screen/Menus/Rotary/Value.text)
	if tempo[0] == 0:
		var tempoMS = (float(1)/(tempo[1]/60))*1000
		print(tempoMS)
		$MidiTimer.setTempo(int(tempoMS))
	changeState()
	ok.connect($Screen._on_select_pressed.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if tempo[0] == 0:
		#$Timer.wait_time = 1/(tempo[1]/60)
	pass
	
func _on_select_pressed():
	match mainState:
		NOTE, SCALE, TEMPO:
			mainState = PROG
		PROG:
			if mode32:
				half = not half
	changeState()
	ok.emit()

func _on_f_1_pressed():
	match mainState:
		MAIN, NOTE, SCALE, TEMPO:
			mainState = PROG
		PROG:
			if shift:
				mainState = MEMORY
			else:
				mainState = NOTE
				prevNote = note
		MEMORY:
			midiFile.save_to_file(messages,offMessages,tempo[1])
			mainState = PROG
	changeState()

func _on_f_2_pressed():
	match mainState:
		PROG:
			if !$MidiTimer.running:
				beat -= 1
			$MidiTimer.playPause()
		NOTE:
			octave -= 1
			if octave < 0:
				octave = 0
			$Screen/PianoGrid.paint()
		SCALE:
			mode -= 1
			if mode < 0:
				mode = len(scales)
			$Screen.updateScreen()
		_:
			pass
			
func _on_f_3_pressed():
	match mainState:
		PROG:
			if shift:
				prevTempo = tempo
				mainState = TEMPO
			else:
				$MidiTimer.stop()
				beat = 0
		NOTE:
			octave += 1
			if octave > 7:
				octave = 7
			$Screen/PianoGrid.paint()
		SCALE:
			mode += 1
			if mode == len(scales):
				mode = 0
			$Screen.updateScreen()
		_:
			pass

func _on_f_4_pressed():
	match mainState:
		PROG:
			if shift:
				prevMode = mode
				prevTone = tone
				mainState = SCALE
		NOTE:
			note = prevNote
			mainState = PROG
		SCALE:
			mode = prevMode
			tone = prevTone
			mainState = PROG
		TEMPO:
			tempo = prevTempo
			mainState = PROG
		MEMORY:
			midiFile.read_from_file(messages,offMessages)
			$Buttons.updateBPT()
			mainState = PROG
	changeState()

func _on_exit_pressed():
	match mainState:
		PROG:
			mainState = MAIN
		NOTE:
			note = prevNote
			mainState = PROG
		SCALE:
			mode = prevMode
			tone = prevTone
			mainState = PROG
		TEMPO:
			tempo = prevTempo
			mainState = PROG
	changeState()
	
func _shift(toggled_on):
	shift = toggled_on
	
func _toggle(toggled_on):
	mode32 = toggled_on
	# Pasar off del 0 al 16 o del 16 al 0
	# Recalcular off del 0 si se pasa a 32
	changeState()

func changeState():
	match mainState:
		MAIN:
			$Screen/PianoGrid.set_visible(false)
			$Screen/Menus.set_visible(false)
		PROG:
			$Screen/PianoGrid.set_visible(true)
			$Screen/Menus.set_visible(true)
	
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
	if mode32 && half:
		$"Screen/Menus/Toggler/1-16".add_theme_color_override("font_color",Color.GRAY)
		$"Screen/Menus/Toggler/17-32".add_theme_color_override("font_color",Color.WHITE)
	else:
		$"Screen/Menus/Toggler/1-16".add_theme_color_override("font_color",Color.WHITE)
		$"Screen/Menus/Toggler/17-32".add_theme_color_override("font_color",Color.GRAY)
	$Screen.updateScreen()

func beatPlay():
	var index
	var beatMask = 0x80000000 >> beat
	if control & beatMask == 0:
		#print("empty")
		return
	for i in 10:
		index = (i * 32) + beat
		#print(messages[index][0])
		if messages[index][0] != 0:
			print(messages[index])
			midi.sendMessage(messages[index])

func _on_timeout() -> void:
	beat += 1
	if (mode32 && beat == 32) || (!mode32 && beat == 16):
		beat = 0
	beatPlay()
	#print(beat)
