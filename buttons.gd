extends Control

var pressed = Array()
var listbtn = Array()
var messages = Array()
var azul = StyleBoxFlat.new()
var gris = StyleBoxFlat.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.resize(16)
	pressed.fill(false)
	listbtn = [$B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $B10, $B11, $B12, $B13, $B14, $B15, $B16]
	messages.resize(320)
	azul.set_bg_color(Color.AQUAMARINE)
	
	var n = 1
	for btn in listbtn:
		btn.pressed.connect(_buttonPress.bind(n))
		n += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var n = 1
	for btn in listbtn:
		btn.pressed.connect(_buttonPress.bind(n))
		if pressed[n - 1]:
			btn.add_theme_stylebox_override("normal",azul)
		else:
			btn.add_theme_stylebox_override("normal",gris)
		n += 1

func _buttonPress(num):
	var btn = get_node("B" + str(num))
	pressed[num - 1] = not(pressed[num - 1])
	


