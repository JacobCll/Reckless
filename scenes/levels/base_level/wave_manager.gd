class_name WaveManager
extends Node

signal wave_started()
signal wave_completed()
signal all_waves_completed

@export var waves: Array[Wave]
@export var wave_start_delay := 1.0

var active_spawners: Array[EntitySpawner] = []

var current_wave := 0
var kills := 0

func start() -> void:
	current_wave = 0
	start_wave()

func start_wave() -> void:
	kills = 0
	
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return

	var wave = waves[current_wave]
	
	for child in wave.get_children():
		if child is EntitySpawner:
			active_spawners.append(child)
			child.start()

	wave_started.emit()

# start the spawn loops for all spawners in the current wave
func start_spawn_loops() -> void:
	var wave = waves[current_wave]
	
	for child in wave.get_children():
		if child is EntitySpawner:
			active_spawners.append(child)
			child.start_spawn_loop()

func register_kill() -> void:
	kills += 1
	if kills >= waves[current_wave].kill_requirement:
		complete_wave()

func complete_wave() -> void:
	var wave = waves[current_wave]
	
	active_spawners.clear()
	
	for child in wave.get_children():
		if child is EntitySpawner:
			child.stop()

	wave_completed.emit()

	current_wave += 1
	
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return
	
	await get_tree().create_timer(wave_start_delay).timeout

	start_wave()

func game_over():
	var wave = waves[current_wave]
	
	active_spawners.clear()
	
	for child in wave.get_children():
		if child is EntitySpawner:
			child.stop()
