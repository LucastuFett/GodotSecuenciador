class_name Screen
extends Node

enum {PROG_MAIN, EDIT_VEL, EDIT_CHN, EDIT_SCALE, EDIT_TEMPO, EDIT_OCTAVE}
const editingLabel = preload("res://themes/EditingLabel.tres")
signal scale_change
var screenState := PROG_MAIN

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_select_pressed():
	pass

#func _on_left_pressed():
	#if screenState == EDIT_SCALE:
		#match $Piano.edit:
			#SELECT_TONE:
				#$Piano.edit = SELECT_SCALE
				#$Piano.updateLabelsEdit()
			#SELECT_SCALE:
				#$Piano.edit = SELECT_TONE
				#$Piano.updateLabelsEdit()
			#TONE:
				#tone -= 1
				#if tone < 0:
					#tone = 11
				#possible = $Piano.getPossible(tone, scale, scales)
				#$Piano.updateKeys(possible)
			#SCALE:
				#scale -= 1
				#if scale < 0:
					#scale = $Piano.scales.size() - 1
				#possible = $Piano.getPossible(tone, scale, scales)
				#$Piano.updateKeys(possible)

#func _on_right_pressed():
	#if screenState == EDIT_SCALE:
		#match $Piano.edit:
			#SELECT_TONE:
				#$Piano.edit = SELECT_SCALE
				#$Piano.updateLabelsEdit()
			#SELECT_SCALE:
				#$Piano.edit = SELECT_TONE
				#$Piano.updateLabelsEdit()
			#TONE:
				#tone += 1
				#if tone > 11:
					#tone = 0
				#possible = $Piano.getPossible(tone, scale, scales)
				#$Piano.updateKeys(possible)
			#SCALE:
				#scale += 1
				#if scale > $Piano.scales.size() - 1:
					#scale = 0
				#possible = $Piano.getPossible(tone, scale, scales)
				#$Piano.updateKeys(possible)

#func toggleScale():
	#if screenState != EDIT_SCALE:
		#screenState = EDIT_SCALE
		#possible = $Piano.getPossible(tone, scale, scales)
		#$Piano.updateKeys(possible)
		#$Piano.updateLabelsEdit()
		#$Piano/Scale.set_visible(true)
		#$Piano/Menu.set_visible(false)
	#else:
		#screenState = MENU
		#var txt = $Piano.tones[tone] + " " + scales[scale][0]
		#if note not in possible[0]:
			#note = possible[0][0]
			#possible[1][0] = $Piano.greenStyle
		#else:
			#paintNote()
		#$Piano.updateLabelsMenu(txt, note, octave)
		#$Piano.updateKeys(possible)
		#$Piano/Scale.set_visible(false)
		#$Piano/Menu.set_visible(true)

#func paintNote():
	#for i in len(possible[0]):
		#if possible[0][i] == note:
			#possible[1][i] = $Piano.greenStyle
		#else:
			#possible[1][i] = $Piano.redStyle
	#


func _on_left_pressed():
	pass # Replace with function body.


func _on_right_pressed():
	pass # Replace with function body.
