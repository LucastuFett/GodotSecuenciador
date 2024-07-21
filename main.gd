extends Control

var pressed = Array()
var midi : Midi
var beat := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	midi = Midi.new()
	$Timer.wait_time = 1/($SpinBox.value/60)
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_timer_timeout():
	beatPlay(beat)
	beat += 1
	if beat == 17:
		beat = 1
		

func beatPlay(beat):
	midi.sendNoteOff(15, 60, 127)
	if $Buttons.pressed[beat - 1]:
		midi.sendNoteOn(15, 60, 127)

func _on_spin_box_value_changed(value):
	print("cambio")
	$Timer.wait_time = 1/(value/60)
