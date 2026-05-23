class_name TestLevel
extends Node

var score := 0 : set = _set_score

@export var countdown_value := 3

@onready var spawner1: EntitySpawner = $EntitySpawner1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	
	spawner1.entity_slashed.connect(_on_entity_slashed)
	spawner1.entity_smashed.connect(_on_entity_smashed)
	
	spawner1.wave_started.connect(_on_wave_started)
	spawner1.wave_completed.connect(_on_wave_completed)
	spawner1.all_waves_completed.connect(_on_all_waves_completed)
	
	play_level()

func _process(_delta: float) -> void:
	$HUD/InGame/TotalActiveEntitiesLabel.text = "Blue: %d  Red: %d  Green: %d" % [
		 spawner1.get_alive_count("blue"),
		 spawner1.get_alive_count("red"),
		 spawner1.get_alive_count("green")
	 ]

func _on_entity_slashed(entity_type: String) -> void:
	match entity_type:
		"blue":  score += 1
		"green": score -= 5

func _on_entity_smashed(entity_type: String) -> void:
	match entity_type:
		"red":   score += 1
		"green": score -= 5

func _on_wave_started(wave_index: int) -> void:
	$HUD/PostGame.hide()
	
	$HUD/InGame/CurrentWaveLabel.text = "Wave: %d" % (wave_index + 1)

func _on_wave_completed(wave_index: int) -> void:
	$HUD/PostGame/WaveWinLabel.text = "Wave %d complete!" % (wave_index + 1)
	$HUD/PostGame/WaveWinLabel.show()

func _on_all_waves_completed() -> void:
	# only show level win message
	$HUD/PostGame.show()
	$HUD/PostGame/WaveWinLabel.hide()
	
	$HUD/InGame.hide()

func _on_retry_button_pressed() -> void:
	retry_level()

func _on_start_button_pressed() -> void:
	$HUD/PreGame/StartButton.hide()
	$HUD/PreGame/WelcomeLabel.hide()
	
	$HUD/InGame.show()
	
	start_countdown()

func start_countdown() -> void:
	countdown_value = 3
	$HUD/PreGame/CountdownLabel.text = str(countdown_value)
	$HUD/PreGame/CountdownLabel.show()
	$CountdownTimer.wait_time = 1.0
	$CountdownTimer.start()

func _on_countdown_timer_timeout() -> void:
	countdown_value -= 1
	if countdown_value > 0:
		$HUD/PreGame/CountdownLabel.text = str(countdown_value)
	else:
		$CountdownTimer.stop() 
		$HUD/PreGame/CountdownLabel.hide()
		spawner1.start()

func play_level():
	$HUD/PreGame.show()
	$HUD/InGame.hide()
	$HUD/PostGame.hide()

func retry_level():
	score = 0
	$HUD/InGame/ScoreLabel.text = str(score)
	spawner1.reset()
	
	$HUD/PostGame.hide()
	# Only show the countdown 
	$HUD/PreGame/WelcomeLabel.hide()
	$HUD/PreGame/StartButton.hide()
	$HUD/InGame.show()
	
	start_countdown()

func _set_score(value: int) -> void:
	score = value
	$HUD/InGame/ScoreLabel.text = str(score)
