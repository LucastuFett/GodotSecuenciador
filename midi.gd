class_name Midi

var midi_out = MidiOut.new()

# Called when the node enters the scene tree for the first time.
func _init():
	for i in range(MidiOut.get_port_count()):
		#print(MidiOut.get_port_name(i))
		if MidiOut.get_port_name(i).contains("loopMIDI Port"):
			midi_out.open_port(i)
		if MidiOut.get_port_name(i).contains("IAC Driver"):
			midi_out.open_port(i)
		
	print(midi_out.is_port_open())

func sendNoteOn(chn: int, note, vel):
	midi_out.send_message([0x90 | chn,note,vel])
	
func sendNoteOff(chn: int, note, vel):
	midi_out.send_message([0x80 | chn,note,vel])

func sendMessage(mes):
	midi_out.send_message(mes)

# Función que se llama cada "beat", envía el mensaje MIDI necesario
func beatPlay(beat, control, messages, offMessages, channelEnabled):
	var index
	var beatMask = 0x80000000 >> beat
	if control & beatMask == 0:
		#print("empty")
		return
	for i in 10:
		index = (i * 32) + beat
		#print(messages[index][0])
		if offMessages[index][0] != 0:
			if (channelEnabled[offMessages[index][0] & 0xF] == false):
				continue
			sendMessage(offMessages[index])
	for i in 10:
		index = (i * 32) + beat
		if messages[index][0] != 0:
			if (channelEnabled[messages[index][0] & 0xF] == false):
				continue
			sendMessage(messages[index])

# Función para enviar un mensaje de apagado en los canales necesarios
func allNotesOff(channels):
	for i in 16:
		if channels[i] != 0:
			sendMessage([0xB0 | i,123,0])
