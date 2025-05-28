extends Node
class_name MidiTimer

var startTime = 0
var curTime = 0
var division = 0
@export var running := false
signal timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startTime = Time.get_unix_time_from_system() * 1000

func _process(delta: float) -> void:
	if running:
		curTime = Time.get_unix_time_from_system() * 1000
		if curTime - startTime >= division:
			timeout.emit()
			startTime = curTime

func start():
	running = true
	startTime = Time.get_unix_time_from_system() * 1000
	timeout.emit()

func stop():
	running = false

func playPause():
	if running:
		stop()
	else:
		start()

func setTempo(div):
	division = div
