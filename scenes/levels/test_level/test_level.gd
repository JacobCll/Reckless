class_name TestLevel
extends Node

var score := 0 : set = _set_score

@export var countdown_value := 3
@export var delay_between_waves: float = 2.0

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
		"blue":  score += 5
		"green": score -= 5

func _on_entity_smashed(entity_type: String) -> void:
	match entity_type:
		"red":   score += 5
		"green": score -= 5

func _on_wave_started(wave_index: int) -> void:
	$HUD/PostGame.hide()
	$HUD/InGame.show()
	$HUD/InGame/CurrentWaveLabel.text = "Wave: %d" % (wave_index + 1)

func _on_wave_completed(wave_index: int) -> void:
	# only show wave win message
	$HUD/PostGame.show()
	$HUD/PostGame/WinLabel.hide()
	$HUD/PostGame/RetryButton.hide()
	$HUD/PostGame/WaveWinLabel.show()
	$HUD/PostGame/WaveWinLabel.text = "Wave %d complete!" % (wave_index + 1)
	
	# delay before next wave
	if wave_index < spawner1.waves.size() - 1:
		await get_tree().create_timer(delay_between_waves).timeout
		$HUD/PostGame.hide()
		spawner1.start_next_wave()
	else:
		print("All levels completed")

func _on_all_waves_completed() -> void:
	# only show level win message
	$HUD/PostGame.show()
	$HUD/PostGame/WaveWinLabel.hide()
	$HUD/PostGame/WinLabel.show()
	$HUD/PostGame/RetryButton.show()

	$HUD/InGame.hide()
	$HUD/PreGame.hide()

func _on_retry_button_pressed() -> void:
	retry_level()

func _on_start_button_pressed() -> void:
	$HUD/PreGame/StartButton.hide()
	$HUD/PreGame/WelcomeLabel.hide()
	
	$HUD/InGame.show()
	$HUD/InGame/CurrentWaveLabel.text = "Wave: 1"
	
	start_countdown()

func start_countdown() -> void:
	countdown_value = 3
	$HUD/PreGame/CountdownLabel.text = str(countdown_value)
	$HUD/PreGame/CountdownLabel.show()
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
	spawner1.reset()
	
	$HUD/PostGame.hide()
	$HUD/PreGame.show()
	$HUD/PreGame/WelcomeLabel.hide()
	$HUD/PreGame/StartButton.hide()
	$HUD/PreGame/CountdownLabel.show() # Only show the countdown 
	$HUD/InGame.show()
	$HUD/InGame/CurrentWaveLabel.text = "Wave: 1"
	
	start_countdown()

func _set_score(value: int) -> void:
	score = value
	$HUD/InGame/ScoreLabel.text = str(score)
