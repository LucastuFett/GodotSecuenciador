class_name Main
extends Control

enum {MAIN, PROG, NOTE, MEMORY, SAVELOAD, RENAME, CHANNEL, TEMPO, SCALE, PLAY, LAUNCH, DAW}

const scales = [["Major", [2,2,1,2,2,2]], ["Minor", [2,1,2,2,1,2]], ["Chrom", [1,1,1,1,1,1,1,1,1,1,1]]]
const editLabel = preload("res://themes/EditableLabel.tres")
var midi : Midi
static var midiFile : MidiFile

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
static var velocity = 127
static var channels = PackedByteArray()
static var mode32 = false
static var half = false
static var control = 0
static var tempo = [0,120] # 0 = Int, 1 = Ext, en Ext, 0 = Half, 2 = Dbl
static var filename = "Test"
static var renameFilename = ""
static var bank = 1
static var hold = 0 # 0 = Sin Hold, 1 = Esperando primer valor, 2 = Esperando segundo valor
static var holded = Dictionary() # {[Beat1, Canal, Nota]:Beat2,}

var shift = false
var prevNote = 0
var prevMode = 0
var prevTone = 0
var prevChn = 0
var prevTempo = [0,120]

# Called when the node enters the scene tree for the first time.
func _ready():
	midi = Midi.new()
	midiFile = MidiFile.new()
	changeState()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mainState == TEMPO:
		tempoChange()
	
func _on_select_pressed():
	match mainState:
		NOTE, SCALE, TEMPO:
			mainState = PROG
		PROG:
			if mode32:
				half = not half
			$Buttons.toggledMode = 1
		MEMORY,RENAME:
			$Screen.selectLetter()
		SAVELOAD:
			filename = $Screen.getFilename()
	changeState()

func _on_f_1_pressed():
	match mainState:
		MAIN, NOTE, SCALE, TEMPO, CHANNEL:
			mainState = PROG
		PROG:
			if shift:
				$Screen.updateMemoryText()
				$Screen.edit = 0
				mainState = MEMORY
			else:
				mainState = NOTE
				prevNote = note
		MEMORY:
			filename = $Screen.saveFilename()
			midiFile.save_to_file(messages,offMessages,tempo[1],filename,bank)
			mainState = PROG
		SAVELOAD:
			filename = $Screen.getFilename()
			midiFile.read_from_file(messages,offMessages,tempo,filename,bank)
			$Buttons.updateBPT()
			$Buttons.updateHolded()
			#print(filename)
			mainState = PROG
		RENAME:
			midiFile.renameFile(renameFilename,$Screen.saveFilename(),bank)
			mainState = SAVELOAD
	changeState()

func _on_f_2_pressed():
	match mainState:
		PROG:
			if shift:
				prevChn = channel
				mainState = CHANNEL
			else:
				if !$MidiTimer.running:
					beat -= 1
				else:
					midi.allNotesOff(channels)
					$Buttons.updateColors()
				$MidiTimer.playPause()
		NOTE:
			octave -= 1
			if octave < 0:
				octave = 0
		SCALE:
			mode -= 1
			if mode < 0:
				mode = len(scales)
		TEMPO:
			tempo[0] = 0
		MEMORY,RENAME:
			if shift:
				if $Screen.curPointer == 0:
					$Screen.curPointer = 1
				else:
					$Screen.curPointer = 0
			else:
				if $Screen.upper == 1:
					$Screen.upper = 0
				else:
					$Screen.upper = 1
		SAVELOAD:
			if shift:
				mainState = RENAME
				renameFilename = $Screen.getFilename()
				$Screen.edit = 0
				print(renameFilename)
			else:
				bank -= 1
				if bank < 1:
					bank = 8
	changeState()

func _on_f_3_pressed():
	match mainState:
		PROG:
			if shift:
				prevTempo = tempo
				mainState = TEMPO
			else:
				$MidiTimer.stop()
				midi.allNotesOff(channels)
				$Buttons.updateColors()
				beat = 0
		NOTE:
			octave += 1
			if octave > 7:
				octave = 7
		SCALE:
			mode += 1
			if mode == len(scales):
				mode = 0
		TEMPO:
			tempo[0] = 1
		MEMORY,RENAME:
			$Screen.typing[$Screen.typePointer].text = " "
			if not shift:
				$Screen._on_left_pressed()
		SAVELOAD:
			if shift:
				midiFile.deleteFile($Screen.getFilename(),bank)
				$Screen.updateBanks()
			else:
				bank += 1
				if bank > 8:
					bank = 1
	changeState()

func _on_f_4_pressed():
	match mainState:
		PROG:
			if shift:
				prevMode = mode
				prevTone = tone
				mainState = SCALE
			else:
				if hold != 0:
					hold = 0
				else:
					hold = 1
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
		CHANNEL:
			channel = prevChn
			mainState = PROG
		MEMORY:
			mainState = SAVELOAD
			filename = $Screen.saveFilename()
		SAVELOAD:
			mainState = MEMORY
		RENAME:
			mainState = SAVELOAD
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
		CHANNEL:
			channel = prevChn
			mainState = PROG
		MEMORY:
			mainState = PROG
		SAVELOAD:
			mainState = MEMORY
	changeState()
	
func _shift(toggled_on):
	shift = toggled_on
	
func _on_left_pressed():
	match mainState:
		PROG:
			velocity -= 1
			if velocity < 0:
				velocity = 0
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
	$Screen._on_left_pressed()
	changeState()
	
func _on_right_pressed():
	match mainState:
		PROG:
			velocity += 1
			if velocity > 127:
				velocity = 127
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
	$Screen._on_right_pressed()
	changeState()
	
func _toggle(toggled_on):
	mode32 = toggled_on
	# Pasar off del 0 al 16 o del 16 al 0
	# Recalcular off del 0 si se pasa a 32
	changeState()

func changeState():
	$Screen.updateScreen()
	$Buttons.updateColors()
	tempoChange()

# Función generada por el timer, llama a sonar un beat
func _on_timeout() -> void:
	beat += 1
	if (mode32 && beat == 32) || (!mode32 && beat == 16):
		beat = 0
	midi.beatPlay(beat, control, messages, offMessages)
	$Buttons.updateColors()
	print(holded)
	#print(beat)

# Función llamada cuando se cambia el tempo para recalcular el tempo
func tempoChange():
	var tempoMS
	if tempo[0] == 0:
		tempoMS = (float(1)/(float(tempo[1])/60))*1000
		#print(tempoMS)
		$MidiTimer.setTempo(int(tempoMS))
