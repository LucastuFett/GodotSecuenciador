class_name Screen
extends Node

enum {SELECT_TONE, SELECT_SCALE, TONE, SCALE}
enum {MENU, EDIT_SCALE}

var scales = [["Major", [2,2,1,2,2,2]], ["Minor", [2,1,2,2,1,2]], ["Chromatic", [1,1,1,1,1,1,1,1,1,1,1]]]
var tone = 0
var scale = 0
var mode = MENU
var possible = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_left_pressed():
	if mode == EDIT_SCALE:
		match $Piano.edit:
			SELECT_TONE:
				$Piano.edit = SELECT_SCALE
				$Piano.updateLabels(false)
			SELECT_SCALE:
				$Piano.edit = SELECT_TONE
				$Piano.updateLabels(false)
			TONE:
				tone -= 1
				if tone < 0:
					tone = 11
				$Piano.updateKeys(tone, scale, scales)
			SCALE:
				scale -= 1
				if scale < 0:
					scale = $Piano.scales.size() - 1
				$Piano.updateKeys(tone, scale, scales)

func _on_right_pressed():
	if mode == EDIT_SCALE:
		match $Piano.edit:
			SELECT_TONE:
				$Piano.edit = SELECT_SCALE
				$Piano.updateLabels(false)
			SELECT_SCALE:
				$Piano.edit = SELECT_TONE
				$Piano.updateLabels(false)
			TONE:
				tone += 1
				if tone > 11:
					tone = 0
				$Piano.updateKeys(tone, scale, scales)
			SCALE:
				scale += 1
				if scale > $Piano.scales.size() - 1:
					scale = 0
				$Piano.updateKeys(tone, scale, scales)

func _on_select_pressed():
	if mode == EDIT_SCALE:
		match $Piano.edit:
			SELECT_TONE:
				$Piano.edit = TONE
				$Piano.updateLabels(false)
			SELECT_SCALE:
				$Piano.edit = SCALE
				$Piano.updateLabels(false)
			TONE:
				$Piano.edit = SELECT_TONE
				$Piano.updateLabels(false)
			SCALE:
				$Piano.edit = SELECT_SCALE
				$Piano.updateLabels(false)

func _on_f_1_pressed():
	togglePiano()

func togglePiano():
	if mode == MENU:
		mode = EDIT_SCALE
		$Piano.updateKeys(tone, scale, scales)
		$Piano.updateLabels(false)
		$Piano/Edit.set_visible(true)
		$Piano/Menu.set_visible(false)
	else:
		mode = MENU
		$Piano.updateLabels(true)
		$Piano/Edit.set_visible(false)
		$Piano/Menu.set_visible(true)
