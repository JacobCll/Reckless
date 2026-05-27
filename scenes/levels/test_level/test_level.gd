class_name TestLevel
extends Node

var score := 0 : set = _set_score

# hearts
@onready var hearts_container = $CanvasLayer/HUD/HeartsContainer
@export var heart_scene: PackedScene
@export var max_lives := 3
var current_lives = 0

@export var countdown_value := 3
@export var delay_between_waves: float = 2.0

# spawners
@onready var spawner1: EntitySpawner = $EntitySpawner1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	
	current_lives = max_lives
	_update_hearts_ui()
	
	# spawners set up
	spawner1.entity_slashed.connect(_on_entity_slashed)
	spawner1.entity_smashed.connect(_on_entity_smashed)
	spawner1.entity_despawned.connect(_on_entity_despawned)
	
	spawner1.wave_started.connect(_on_wave_started)
	spawner1.wave_completed.connect(_on_wave_completed)
	spawner1.all_waves_completed.connect(_on_all_waves_completed)
	
	$CanvasLayer/PauseScreen.hide()
	$CanvasLayer/GameoverScreen.hide()
	$CanvasLayer/WinLevelScreen.hide()
	$CanvasLayer/HUD.hide()
	$CanvasLayer/CountdownLabel.hide()
	$CanvasLayer/WaveWinLabel.hide()
	$CanvasLayer/PreGameScreen.show()

func _process(_delta: float) -> void:
	$CanvasLayer/HUD/TotalActiveEntitiesLabel.text = "Blue: %d  Red: %d  Green: %d" % [
		 spawner1.get_alive_count("blue"),
		 spawner1.get_alive_count("red"),
		 spawner1.get_alive_count("green")
	 ]

func _on_entity_slashed(entity_type: String) -> void:
	match entity_type:
		"blue":  
			score += 5
		"green": 
			score -= 5
			_lose_heart()

func _on_entity_smashed(entity_type: String) -> void:
	match entity_type:
		"red":   
			score += 5
		"green": 
			score -= 5
			_lose_heart()
			
func _on_entity_despawned(entity_type: String) -> void:
	if entity_type == "blue" or entity_type == "red":
		_lose_heart()
		_update_hearts_ui()

func _on_wave_started(wave_index: int) -> void:
	$CanvasLayer/HUD.show()
	$CanvasLayer/HUD/CurrentWaveLabel.text = "Wave: %d" % (wave_index + 1)

# if wave is not last and it is completed
func _on_wave_completed(wave_index: int) -> void:
	print("Wave ", wave_index + 1, " completed")
	$CanvasLayer/WaveWinLabel.show()
	$CanvasLayer/WaveWinLabel.text = "Wave %d complete!" % (wave_index + 1)
	
	# if wave is not last
	if wave_index < spawner1.waves.size() - 1:
		# delay before next wave
		await get_tree().create_timer(delay_between_waves, false).timeout
		$CanvasLayer/WaveWinLabel.hide()
		spawner1.start_next_wave()

func _on_all_waves_completed() -> void:
	$CanvasLayer/HUD.hide()
	$CanvasLayer/WinLevelScreen.show()

func _on_start_button_pressed() -> void:
	$CanvasLayer/PreGameScreen.hide()
	$CanvasLayer/CountdownLabel.show()
	
	start_countdown()

func _on_play_again_button_pressed() -> void:
	# tentative
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_retry_button_pressed() -> void:
	restart_level()

func start_countdown() -> void:
	countdown_value = 3
	$CanvasLayer/CountdownLabel.text = str(countdown_value)
	$CountdownTimer.start()

func _on_countdown_timer_timeout() -> void:
	countdown_value -= 1
	if countdown_value > 0:
		$CanvasLayer/CountdownLabel.text = str(countdown_value)
	else:
		$CountdownTimer.stop() 
		$CanvasLayer/CountdownLabel.hide()
		$CanvasLayer/HUD.show()
		spawner1.start()

func restart_level():
	score = 0
	spawner1.reset()
	current_lives = 3
	_update_hearts_ui()
	
	$CanvasLayer/GameoverScreen.hide()
	$CanvasLayer/WinLevelScreen.hide()
	$CanvasLayer/WaveWinLabel.hide()
	$CanvasLayer/CountdownLabel.show()
	
	start_countdown()

func _set_score(value: int) -> void:
	score = value
	$CanvasLayer/HUD/ScoreLabel.text = str(score)

func _update_hearts_ui():
	for child in hearts_container.get_children():
		child.queue_free()

	for i in current_lives:
		var heart = heart_scene.instantiate()
		hearts_container.add_child(heart)

func _lose_heart():
	current_lives -= 1
	current_lives = max(current_lives, 0) # prevent going below 0
	
	_update_hearts_ui()

	if current_lives <= 0:
		game_over()

func game_over():
	print("Game Over")
	
	$CanvasLayer/HUD.hide()
	$CanvasLayer/GameoverScreen.show()
	
	spawner1.stop()

# show paused menu, pause everything except button input and sfx
func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$CanvasLayer/PauseScreen.show()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	$CanvasLayer/PauseScreen.hide()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
