class_name TestLevel
extends Node

var score := 0

@onready var spawner1: EntitySpawner = $EntitySpawner1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner1.entity_slashed.connect(_on_entity_slashed)
	spawner1.entity_smashed.connect(_on_entity_smashed)
	
	spawner1.wave_started.connect(_on_wave_started)
	spawner1.wave_completed.connect(_on_wave_completed)
	spawner1.all_waves_completed.connect(_on_all_waves_completed)
	
	$HUD/WinLabel.visible = false
	$HUD/WaveWinLabel.visible = false
	$HUD/RetryButton.visible = false

func _process(delta: float) -> void:
	$HUD/TotalActiveEntitiesLabel.text = "Blue: %d  Red: %d  Green: %d" % [
		 spawner1.get_alive_count("blue"),
		 spawner1.get_alive_count("red"),
		 spawner1.get_alive_count("green")
	 ]

func _on_entity_slashed(entity_type: String) -> void:
	match entity_type:
		"blue":  score += 1
		"green": score -= 5
	$HUD/ScoreLabel.set_new_text(str(score))

func _on_entity_smashed(entity_type: String) -> void:
	match entity_type:
		"red":   score += 1
		"green": score -= 5
	$HUD/ScoreLabel.set_new_text(str(score))

func _on_wave_started(wave_index: int) -> void:
	$HUD/WaveWinLabel.visible = false
	$HUD/RetryButton.visible = false
	$HUD/CurrentWaveLabel.text = "Wave %d" % (wave_index + 1)

func _on_wave_completed(wave_index: int) -> void:
	$HUD/WaveWinLabel.visible = true
	$HUD/WaveWinLabel.text = "Wave %d complete!" % (wave_index + 1)

func _on_all_waves_completed() -> void:
	# only show level win message
	$HUD/WaveWinLabel.visible = false
	$HUD/WinLabel.visible = true
	$HUD/RetryButton.visible = true
	$HUD/WinLabel.text = "You win!"

func _on_retry_button_pressed() -> void:
	print("retry pressed")
	get_tree().reload_current_scene()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Click at: ", event.position)
