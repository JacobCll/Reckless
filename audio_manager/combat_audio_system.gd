extends Node

@onready var CombatSfxPlayer := $CombatSfxPlayer
@onready var throwSfxPlayer := $ThrowSfxPlayer

@export var slash_sounds: Array[AudioStream]
@export var smash_sounds: Array[AudioStream]

@export var good_entity_throw: AudioStream
@export var bad_entity_throw: AudioStream

@export var min_interval := 0.03

var _last_play_time := 0.0
 
func play_slash() -> void:
	if not _can_play():
		return

	var stream = slash_sounds.pick_random()
	_play(stream)


func play_smash() -> void:
	if not _can_play():
		return

	var stream = smash_sounds.pick_random()
	_play(stream)


func _play(stream: AudioStream) -> void:
	CombatSfxPlayer.stream = stream
	CombatSfxPlayer.pitch_scale = randf_range(0.9, 1.1)

	CombatSfxPlayer.play()

	CombatSfxPlayer.finished.connect(CombatSfxPlayer.queue_free)

	_last_play_time = Time.get_ticks_msec() / 1000.0

func _can_play() -> bool:
	var now = Time.get_ticks_msec() / 1000.0
	return now - _last_play_time >= min_interval

func play_throw(entity_type: String):
	match entity_type:
		"blue":
			throwSfxPlayer.stream = good_entity_throw
		"red":
			throwSfxPlayer.stream = good_entity_throw
		"green":
			throwSfxPlayer.stream = bad_entity_throw
	
	throwSfxPlayer.play()
