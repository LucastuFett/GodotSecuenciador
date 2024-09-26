class_name Midi

var midi_out = MidiOut.new()

# Called when the node enters the scene tree for the first time.
func _init():
	for i in range(MidiOut.get_port_count()):
		#print(MidiOut.get_port_name(i))
		if MidiOut.get_port_name(i).contains("loopMIDI Port"):
			midi_out.open_port(i)
	print(midi_out.is_port_open())


func sendNoteOn(chn: int, note, vel):
	midi_out.send_message([0x90 | chn,note,vel])
	
func sendNoteOff(chn: int, note, vel):
	midi_out.send_message([0x80 | chn,note,vel])

func sendMessage(mes):
	midi_out.send_message(mes)
