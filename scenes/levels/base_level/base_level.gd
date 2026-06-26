
class_name BaseLevel
extends Node

@export var LEVEL_NUMBER := 0

# --------------------
# CORE GAME STATE
# --------------------
# score
var score := 0 : set = _set_score
func _set_score(value: int) -> void:
	score = value
	$CanvasLayer/HUD/ScoreLabel.text = str(score)
	
# pause
var is_paused := false

# lives
@export var max_lives := 3
var current_lives := 0

# countdown
@export var countdown_value_original := 3
var countdown_value := countdown_value_original

# wave manager
@onready var wave_manager: WaveManager = $WaveManager

# --------------------
# UI (shared HUD)
# --------------------
@onready var hud = $CanvasLayer/HUD
@onready var hearts_container = $CanvasLayer/HUD/HeartsContainer
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var countdown_timer = $CountdownTimer
@onready var countdown_label = $CanvasLayer/CountdownLabel
@onready var pause_button = $CanvasLayer/PauseButton
@onready var pause_screen = $CanvasLayer/PauseScreen
@onready var gameover_screen = $CanvasLayer/GameoverScreen
@onready var win_screen = $CanvasLayer/WinLevelScreen
@onready var next_level_button = $CanvasLayer/WinLevelScreen/NextLevelButton
@onready var settings_menu = $SettingsMenu

# --------------------
# RESOURCES
# --------------------
@export var level_music: AudioStream
var heart_scene := preload("res://hud_elements/hearts/heart.tscn")
var entity_particles_scene := preload("res://effects/entity_particles/entity_particles.tscn")

# =========================================================
# READY
# =========================================================
func _ready() -> void:
	_setup_level()
	_setup_ui()
	_setup_spawners()
	_prewarm_particles()
	
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	start_countdown()

# =========================================================
# SETUP
# =========================================================
func _setup_level() -> void:
	score = 0
	
	current_lives = max_lives
	countdown_value = countdown_value_original
	
	AudioManager.play_music(level_music)
	AudioManager.enable_mouse_sfx()
	MouseManager.show_mouse_trail()
	
	GameManager.current_scene = "in_game"

func _setup_ui() -> void:
	pause_screen.hide()
	gameover_screen.hide()
	win_screen.hide()
	hud.hide()
	
	countdown_label.show()
	_update_hearts_ui()

# prevents particle lag when level is loaded for the first time
func _prewarm_particles() -> void:
	if entity_particles_scene == null:
		return

	var p = entity_particles_scene.instantiate()
	add_child(p)
	p.modulate.a = 0.0
	p.spawn_particles(Vector2.ZERO, Color.WHITE)

func _setup_spawners() -> void:
	for wave in wave_manager.waves:
		for child in wave.get_children():
			if child is EntitySpawner:
				child.entity_slashed.connect(_on_entity_slashed)
				child.entity_smashed.connect(_on_entity_smashed)
				child.entity_killed.connect(_on_entity_killed)
				child.entity_spawned.connect(_on_entity_spawned)
				child.entity_despawned.connect(_on_entity_despawned)

# =========================================================
# COUNTDOWN
# =========================================================
func start_countdown() -> void:
	countdown_value = countdown_value_original
	countdown_label.text = str(countdown_value)
	countdown_timer.start()

func _on_countdown_timer_timeout() -> void:
	countdown_value -= 1
	if countdown_value > 0:
		countdown_label.text = str(countdown_value)
		return
	else:
		countdown_timer.stop()
		countdown_label.hide()
		
		_on_level_start()

# override hook
func _on_level_start() -> void:
	hud.show()
	wave_manager.start()

# =========================================================
# SPAWNER EVENTS (override logic allowed)
# =========================================================
func _on_entity_spawned(entity_type: String) -> void:
	CombatAudioSystem.play_throw(entity_type)

func _on_entity_slashed(entity_type: String) -> void:
	_default_score_logic(entity_type, "slash")
	CombatAudioSystem.play_slash()

func _on_entity_smashed(entity_type: String) -> void:
	_default_score_logic(entity_type, "smash")
	CombatAudioSystem.play_smash()
	
func _on_entity_killed(entity_type: String) -> void:
	if entity_type != "green":
		_entity_drop(entity_type)
		wave_manager.register_kill()

func _on_entity_despawned(entity_type: String) -> void:
	if entity_type in ["blue", "red"]:
		_lose_heart()
		CombatAudioSystem.play_despawned()

func _entity_drop(entity_type: String):
	if entity_type != "green":
		GameManager.user_orbs += 5
		GameManager.save_data()

# override if needed
func _default_score_logic(entity_type: String, action: String) -> void:
	match entity_type:
		"blue":
			score += 5 if action == "slash" else 0
		"red":
			score += 5 if action == "smash" else 0
		"green":
			score = max(score - 5, 0)
			_lose_heart()

# =========================================================
# WAVE SIGNALS
# =========================================================
func _on_wave_started() -> void:
	var current_wave = wave_manager.current_wave + 1
	
	print("wave ", current_wave, " started")
	
	$CanvasLayer/HUD/CurrentWaveLabel.text = "Wave: %d" % (current_wave)
	
	wave_manager.start_spawn_loops()
	
func _on_wave_completed() -> void:
	var current_wave = wave_manager.current_wave + 1
	
	print("wave ", current_wave, " completed")

func _on_all_waves_completed() -> void:
	print("You win!")
	
	pause_button.hide()
	hud.hide()
	win_screen.show()
	
	# unlock next level
	GameManager.unlock_level(LEVEL_NUMBER)
	
	# show next level button if there is a next level
	if LEVEL_NUMBER < GameManager.max_unlockable_level:
		next_level_button.show()
	else:
		next_level_button.hide()

# =========================================================
# LIVES / HEARTS
# =========================================================
func _update_hearts_ui() -> void:
	for c in hearts_container.get_children():
		c.queue_free()

	for i in current_lives:
		var heart = heart_scene.instantiate()
		hearts_container.add_child(heart)

func _lose_heart() -> void:
	current_lives = max(current_lives - 1, 0)
	_update_hearts_ui()

	if current_lives <= 0:
		game_over()

func game_over() -> void:
	pause_button.hide()
	hud.hide()
	gameover_screen.show()
	
	wave_manager.game_over()

# =========================================================
# UI ACTIONS
# =========================================================
func _on_pause_button_pressed() -> void:
	if not is_paused:
		_pause_game()
	else:
		_resume_game()
	
func _unhandled_input(event: InputEvent) -> void:
	# don't do anything if settings menu is shown
	if settings_menu.visible:
		return
	
	if event.is_action_pressed("Pause"):
		_handle_pause_input()

func _on_resume_button_pressed() -> void:
	_resume_game()

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_retry_button_pressed() -> void:
	restart_level()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	
	AudioManager.stop_music()
	AudioManager.disable_mouse_sfx()
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_level_menu_button_pressed() -> void:
	get_tree().paused = false
	
	AudioManager.stop_music()
	AudioManager.disable_mouse_sfx()
	
	get_tree().change_scene_to_file("res://scenes/level_menu/level_menu.tscn")

func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_button_pressed() -> void:
	MouseManager.hide_mouse_trail()
	settings_menu.show()

# go to next level in win screen
func _on_next_level_button_pressed() -> void:
	if LEVEL_NUMBER == GameManager.max_unlockable_level:
		return

	var next_level_scene = "res://scenes/levels/levels/level_" + str(LEVEL_NUMBER + 1) + "/level_" + str(LEVEL_NUMBER + 1) + ".tscn"
	get_tree().paused = false
	get_tree().change_scene_to_file(next_level_scene)
	
# PAUSE
func _handle_pause_input() -> void:
	if is_paused:
		_resume_game()
	else:
		_pause_game()
		
func _pause_game() -> void:
	is_paused = true
	get_tree().paused = true

	AudioManager.pause_music()
	AudioManager.disable_mouse_sfx()

	pause_screen.show()
	
func _resume_game() -> void:
	is_paused = false
	get_tree().paused = false

	AudioManager.resume_music()
	AudioManager.enable_mouse_sfx()

	pause_screen.hide()
