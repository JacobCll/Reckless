extends Node

@onready var combat_sfx_player := $CombatSfxPlayer
@onready var throw_sfx_player := $ThrowSfxPlayer
@onready var impact_sfx_player := $ImpactSfxPlayer
@onready var despawned_sfx_player := $DespawnedSfxPlayer

@export var slash_impact_sfx: Array[AudioStream]

@export var slash_sfx: Array[AudioStream]
@export var smash_sfx: Array[AudioStream]

@export var good_entity_throw: AudioStream
@export var bad_entity_throw: AudioStream

@export var despawned_sfx: AudioStream

@export var min_interval := 0.03

var _last_play_time := 0.0
 
func play_slash() -> void:
	#if not _can_play():
		#return
	
	var slash_stream = slash_sfx.pick_random()
	_play(slash_stream)
	
	await get_tree().create_timer(0.03).timeout
	
	_play_impact_sfx()

func play_smash() -> void:
	#if not _can_play():
		#return
	
	var stream = smash_sfx.pick_random()
	_play(stream)
	
	await get_tree().create_timer(0.03).timeout
	
	_play_impact_sfx()

func _play(stream: AudioStream) -> void:
	combat_sfx_player.stream = stream
	combat_sfx_player.play()

	#combat_sfx_player.finished.connect(combat_sfx_player.queue_free)
	#_last_play_time = Time.get_ticks_msec() / 1000.0

func _play_impact_sfx():
	var impact_sfx_stream = slash_impact_sfx.pick_random()
	impact_sfx_player.stream = impact_sfx_stream
	impact_sfx_player.play()

func _can_play() -> bool:
	var now = Time.get_ticks_msec() / 1000.0
	return now - _last_play_time >= min_interval

func play_throw(entity_type: String):
	match entity_type:
		"blue":
			throw_sfx_player.stream = good_entity_throw
		"red":
			throw_sfx_player.stream = good_entity_throw
		"green":
			throw_sfx_player.stream = bad_entity_throw
	
	throw_sfx_player.play()
	
func play_despawned():
	despawned_sfx_player.stream = despawned_sfx
	despawned_sfx_player.play()
