extends Node

@onready var whoosh_player: AudioStreamPlayer = $WhooshPlayer
@export var whoosh_sounds: Array[AudioStream]

@export var speed_threshold := 800.0
@export var min_interval := 0.05

var _last_mouse_pos: Vector2
var _last_play_time := 0.0
var _is_lmb_down := false
var _speed := 0.0

var enabled := false

func _ready():
	_last_mouse_pos = get_viewport().get_mouse_position()

func _process(delta):
	if not enabled:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var velocity = (mouse_pos - _last_mouse_pos) / max(delta, 0.0001)

	_speed = velocity.length()
	_last_mouse_pos = mouse_pos

	if _is_lmb_down:
		_try_play_whoosh()


func _input(event):
	if not enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_lmb_down = event.pressed


func _try_play_whoosh():
	if _speed < speed_threshold:
		return

	var now = Time.get_ticks_msec() / 1000.0
	if now - _last_play_time < min_interval:
		return

	_last_play_time = now
	_play_random_whoosh()

func _play_random_whoosh():
	if whoosh_sounds.is_empty():
		return

	whoosh_player.stream = whoosh_sounds.pick_random()
	whoosh_player.play()
