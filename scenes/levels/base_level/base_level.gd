class_name BaseLevel
extends Node

# --------------------
# CORE GAME STATE
# --------------------
# score
var score := 0 : set = _set_score
func _set_score(value: int) -> void:
	score = value
	$CanvasLayer/HUD/ScoreLabel.text = str(score)

# lives
@export var max_lives := 3
var current_lives := 0

# countdown
@export var countdown_value_original := 3
var countdown_value := countdown_value_original

# waves
@export var wave_start_delay := 1.0
var current_wave = 0
var wave_to_kill = [10]
var total_killed_this_wave := 0

# --------------------
# UI (shared HUD)
# --------------------
@onready var hud = $CanvasLayer/HUD
@onready var hearts_container = $CanvasLayer/HUD/HeartsContainer
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var countdown_timer = $CountdownTimer
@onready var countdown_label = $CanvasLayer/CountdownLabel
@onready var pause_screen = $CanvasLayer/PauseScreen
@onready var gameover_screen = $CanvasLayer/GameoverScreen
@onready var win_screen = $CanvasLayer/WinLevelScreen
@onready var wave_label = $CanvasLayer/WaveWinLabel
@onready var settings_menu = $SettingsMenu

# --------------------
# RESOURCES
# --------------------
@export var level_music: AudioStream
@export var heart_scene: PackedScene
@export var entity_particles_scene: PackedScene

# --------------------
# SPAWNERS (assigned by child level)
# --------------------
@onready var spawners: Array = []

# =========================================================
# READY
# =========================================================
func _ready() -> void:
	_setup_level()
	_setup_ui()
	_setup_spawners()
	_prewarm_particles()

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
	
	GameManager.current_scene = "in_game"

func _setup_ui() -> void:
	pause_screen.hide()
	gameover_screen.hide()
	win_screen.hide()
	wave_label.hide()
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

# override this in child levels since a child level can have different spawner setups
func _setup_spawners() -> void:
	pass

func register_spawner(spawner) -> void:
	spawners.append(spawner)

	spawner.entity_slashed.connect(_on_entity_slashed)
	spawner.entity_smashed.connect(_on_entity_smashed)
	spawner.entity_killed.connect(_on_entity_killed)
	spawner.entity_spawned.connect(_on_entity_spawned)
	spawner.entity_despawned.connect(_on_entity_despawned)

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
	start_wave()

# =========================================================
# SPAWNER EVENTS (override logic allowed)
# =========================================================
func _on_entity_spawned(entity_type: String) -> void:
	CombatAudioSystem.play_throw(entity_type)

func _on_entity_slashed(entity_type: String) -> void:
	_default_score_logic(entity_type, "slash")

func _on_entity_smashed(entity_type: String) -> void:
	_default_score_logic(entity_type, "smash")

func _on_entity_killed(entity_type: String) -> void:
	if entity_type != "green":
		total_killed_this_wave += 1

	if total_killed_this_wave >= wave_to_kill[current_wave]:
		complete_wave()

func _on_entity_despawned(entity_type: String) -> void:
	if entity_type in ["blue", "red"]:
		_lose_heart()

# override if needed
func _default_score_logic(entity_type: String, action: String) -> void:
	match entity_type:
		"blue":
			score += 5 if action == "slash" else 0
		"red":
			score += 5 if action == "smash" else 0
		"green":
			score -= 5
			_lose_heart()

# =========================================================
# WAVES
# =========================================================
func start_wave() -> void:
	print("wave ", current_wave + 1, " started")

	for spawner in spawners:
		spawner.start()

	_on_wave_started()

func complete_wave() -> void:
	print("wave completed")
	for s in spawners:
		s.stop()
		s.reset()
		
	_on_wave_completed()
	
	current_wave += 1
	total_killed_this_wave = 0
	
	if current_wave < wave_to_kill.size() - 1:
		await get_tree().create_timer(wave_start_delay, false).timeout
		wave_label.hide()
		start_wave()
	else:
		_on_all_waves_completed()

func _on_wave_completed():
	pass

func _on_wave_started() -> void:
	wave_label.show()
	$CanvasLayer/HUD/CurrentWaveLabel.text = "Wave: %d" % (current_wave + 1)

func _on_all_waves_completed() -> void:
	hud.hide()
	win_screen.show()

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
	hud.hide()
	gameover_screen.show()

	for s in spawners:
		s.stop()

# =========================================================
# UI ACTIONS
# =========================================================
func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	AudioManager.pause_music()
	AudioManager.disable_mouse_sfx()
	pause_screen.show()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.resume_music()
	AudioManager.enable_mouse_sfx()
	pause_screen.hide()

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_retry_button_pressed() -> void:
	restart_level()

func _on_main_menu_button_pressed() -> void:
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
