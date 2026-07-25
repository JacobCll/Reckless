class_name BaseLevel
extends Node

@export var LEVEL_NUMBER := 0

# --------------------
# POWER UP FLAGS
# --------------------
var double_orbs_active := false # modify in entity_drop()
var current_shields := 0

# --------------------
# WAVE COMPLETE BANNER
# --------------------
var _wave_complete_tween: Tween

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
@onready var wave_complete_label = $CanvasLayer/WaveCompleteLabel
@onready var hearts_container = $CanvasLayer/HUD/HeartsContainer
@onready var shields_container = $CanvasLayer/HUD/ShieldsContainer
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
var shield_scene := preload("res://hud_elements/shields/shield.tscn")
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
	
	# appy powerups	
	_apply_selected_powerup()
	
	AudioManager.play_music(level_music)
	AudioManager.enable_mouse_sfx()
	MouseManager.show_mouse_trail()
	
	GameManager.current_scene = "in_game"
	
func _apply_selected_powerup():
	match GameManager.selected_powerup:
		"powerup_shields":
			current_shields = 2
			_update_shields_ui()
		"powerup_no_green":
			_apply_no_green_powerup()
		"powerup_double_orbs": 
			double_orbs_active = true
		"": # no powerup selected
			return
			
	if GameManager.selected_powerup != "":
		GameManager.inventory[GameManager.selected_powerup] -= 1
		GameManager.selected_powerup = ""
		GameManager.save_data()

func _setup_ui() -> void:
	pause_screen.hide()
	gameover_screen.hide()
	win_screen.hide()
	hud.hide()
	
	countdown_label.show()
	_update_hearts_ui()
	_update_shields_ui()

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

func _apply_no_green_powerup() -> void:
	for wave in wave_manager.waves:
		for child in wave.get_children():
			if child is EntitySpawner:
				child.set_green_weight(0.0)

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
	# don't drop anything if entity is green
	if entity_type == "green":
		return
	
	var orbs_to_drop = 5
	
	# double orbs power-up
	if double_orbs_active:
		orbs_to_drop *= 2
		
	GameManager.user_orbs += orbs_to_drop
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
	var is_last_wave := wave_manager.current_wave >= wave_manager.waves.size() - 1

	print("wave ", current_wave, " completed")

	if not is_last_wave:
		_show_wave_complete_banner(current_wave)

func _show_wave_complete_banner(wave_number: int) -> void:
	if _wave_complete_tween:
		_wave_complete_tween.kill()

	wave_complete_label.text = "Wave %d Completed!" % wave_number
	wave_complete_label.modulate.a = 0.0
	wave_complete_label.show()

	_wave_complete_tween = create_tween()
	_wave_complete_tween.set_loops(3)
	_wave_complete_tween.tween_property(wave_complete_label, "modulate:a", 1.0, 0.5)
	_wave_complete_tween.tween_property(wave_complete_label, "modulate:a", 0.0, 0.5)
	_wave_complete_tween.finished.connect(wave_complete_label.hide)

func _on_all_waves_completed() -> void:
	print("You win!")
	
	pause_button.hide()
	hud.hide()
	win_screen.show()
	
	# unlock next level
	GameManager.unlock_level(LEVEL_NUMBER)
	
	# show next level button if there is a next level
	if LEVEL_NUMBER < GameManager.MAX_UNLOCKABLE_LEVEL:
		next_level_button.show()
	else:
		next_level_button.hide()

# =========================================================
# LIVES / HEARTS / SHIELDS
# =========================================================
func _update_hearts_ui() -> void:
	for c in hearts_container.get_children():
		c.queue_free()

	for i in current_lives:
		var heart = heart_scene.instantiate()
		hearts_container.add_child(heart)
		
func _update_shields_ui():
	for c in shields_container.get_children():
		c.queue_free()
		
	for i in current_shields:
		var shield = shield_scene.instantiate()
		shields_container.add_child(shield)

func _lose_heart() -> void:
	if current_shields > 0:
		current_shields -= 1
		_update_shields_ui()
		return
	
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
	if LEVEL_NUMBER == GameManager.MAX_UNLOCKABLE_LEVEL:
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
