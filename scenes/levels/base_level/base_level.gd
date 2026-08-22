class_name BaseLevel
extends Node

@export var LEVEL_NUMBER := 0

@export_group("Mouse Parallax")
@export var background_parallax_strength: Vector2 = Vector2(6.0, 3.0)
@export var parallax_smoothing: float = 5.0

var _background_base_position: Vector2
var _parallax_offset: Vector2 = Vector2.ZERO

@export_group("Harm Screen Effect")
@export var harm_flash_alpha: float = 0.25
@export var harm_flash_fade_duration: float = 0.3
@export var harm_shake_strength: float = 10.0
@export var harm_shake_duration: float = 0.25

var _harm_flash_tween: Tween
var _shake_time_left := 0.0

@export_group("Spawn Glow Effect")
@export var spawn_glow_alpha: float = 0.25
@export var spawn_glow_fade_duration: float = 0.6
@export_group("")

var _spawn_glow_tween: Tween

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
# END-OF-LEVEL SCREEN DELAYS
# --------------------
@export var game_over_screen_delay := 1.2
@export var win_screen_delay := 1.2

# --------------------
# WAVE TRANSITION DELAY
# --------------------
@export var wave_end_spawn_delay := 1.5

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
var _resume_countdown_active := false
var _intro_countdown_active := false
@export var resume_countdown_seconds := 3

# lives
@export var max_lives := 3
var current_lives := 0

# countdown
@export var countdown_value_original := 3
var countdown_value := countdown_value_original

# wave manager
@onready var wave_manager: WaveManager = $WaveManager

# background
@onready var background: TextureRect = $Background

# camera / screen effects
@onready var camera: Camera2D = $Camera2D
@onready var harm_effect: ColorRect = $CanvasLayer/HarmEffect
@onready var spawn_glow: TextureRect = $CanvasLayer/SpawnGlow

# --------------------
# UI (shared HUD)
# --------------------
@onready var hud = $CanvasLayer/HUD
@onready var wave_complete_label = $CanvasLayer/WaveCompleteLabel
@onready var hearts_container = $CanvasLayer/HUD/HeartsContainer
@onready var shields_container = $CanvasLayer/HUD/ShieldsContainer
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var level_progress_bar = $CanvasLayer/HUD/LevelProgressBar
@onready var countdown_timer = $CountdownTimer
@onready var countdown_label = $CanvasLayer/CountdownLabel
@onready var countdown_sfx_player = $CountdownSfxPlayer
@onready var victory_sfx_player = $VictorySfxPlayer
@onready var defeat_sfx_player = $DefeatSfxPlayer
@onready var pause_button = $CanvasLayer/PauseButton
@onready var pause_screen = $CanvasLayer/PauseScreen
@onready var gameover_screen = $CanvasLayer/GameoverScreen
@onready var gameover_score_text = $CanvasLayer/GameoverScreen/ScoreText
@onready var win_screen = $CanvasLayer/WinLevelScreen
@onready var win_score_text = $CanvasLayer/WinLevelScreen/ScoreText
@onready var next_level_button = $CanvasLayer/WinLevelScreen/HBoxContainer/NextLevelButton
@onready var settings_menu = $SettingsMenu
@onready var progress_bar = $CanvasLayer/HUD/LevelProgressBar

# --------------------
# RESOURCES
# --------------------
@export var level_music: AudioStream
var countdown_sfx := preload("res://sfx/time_beep.wav")
var victory_sfx := preload("res://sfx/victory_and_gameover_sfx/Victory_2.mp3")
@export var defeat_sfx: Array[AudioStream]
var heart_scene := preload("res://hud_elements/hearts/heart.tscn")
var shield_scene := preload("res://hud_elements/shields/shield.tscn")
var entity_slash_particles_scene := preload("res://effects/entity_particles_slash/entity_particles_slash.tscn")
var entity_smash_particles_scene := preload("res://effects/entity_particles_smash/entity_particles_smash.tscn")

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
	wave_manager.progress_changed.connect(_on_progress_changed)

	start_countdown()

func _process(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var normalized := (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	normalized = normalized.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

	_parallax_offset = _parallax_offset.lerp(normalized, min(parallax_smoothing * delta, 1.0))

	background.position = _background_base_position + _parallax_offset * background_parallax_strength

	if _shake_time_left > 0.0:
		_shake_time_left = max(_shake_time_left - delta, 0.0)
		var shake_amount := harm_shake_strength * (_shake_time_left / harm_shake_duration)
		camera.offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	elif camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO

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

	_background_base_position = background.position

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
	level_progress_bar.value = 0.0

# prevents particle lag when level is loaded for the first time
func _prewarm_particles() -> void:
	for scene in [entity_slash_particles_scene, entity_smash_particles_scene]:
		if scene == null:
			continue

		var p = scene.instantiate()
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
	_intro_countdown_active = true
	countdown_value = countdown_value_original
	countdown_label.text = str(countdown_value)
	_play_countdown_sfx()
	countdown_timer.start()

func _on_countdown_timer_timeout() -> void:
	countdown_value -= 1
	if countdown_value > 0:
		countdown_label.text = str(countdown_value)
		_play_countdown_sfx()
		return
	else:
		countdown_timer.stop()
		countdown_label.hide()
		_intro_countdown_active = false

		_on_level_start()

func _play_countdown_sfx() -> void:
	countdown_sfx_player.stream = countdown_sfx
	countdown_sfx_player.play()

func _play_victory_sfx() -> void:
	victory_sfx_player.stream = victory_sfx
	victory_sfx_player.play()

func _play_defeat_sfx() -> void:
	if defeat_sfx.is_empty():
		return
	defeat_sfx_player.stream = defeat_sfx.pick_random()
	defeat_sfx_player.play()

# override hook
func _on_level_start() -> void:
	hud.show()
	wave_manager.start()

# =========================================================
# SPAWNER EVENTS (override logic allowed)
# =========================================================
func _on_entity_spawned(entity_type: String, spawn_position: Vector2) -> void:
	CombatAudioSystem.play_throw(entity_type)
	_trigger_spawn_glow(entity_type, spawn_position)

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
	else:
		CombatAudioSystem.play_despawned()

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

	# skip the delay for the very first wave, only pause between a completed wave and the next
	if wave_manager.current_wave > 0:
		await get_tree().create_timer(wave_end_spawn_delay, false).timeout

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

func _on_progress_changed(progress: float) -> void:
	level_progress_bar.value = progress

func _on_all_waves_completed() -> void:
	pause_button.hide()
	hud.hide()
	AudioManager.stop_music()

	# unlock next level
	GameManager.unlock_level(LEVEL_NUMBER)

	await get_tree().create_timer(win_screen_delay).timeout

	win_score_text.text = "Score: %d" % score
	win_screen.show()
	_play_victory_sfx()

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

func _spawn_glow_color(entity_type: String) -> Color:
	match entity_type:
		"blue":
			return Color(0.3254902, 0.65882355, 0.9529412)
		"red":
			return Color(0.9607843, 0.019607844, 0.023529412)
		"green":
			return Color(0.0, 0.5818609, 0.059796207)
		_:
			return Color.WHITE

func _trigger_spawn_glow(entity_type: String, spawn_position: Vector2) -> void:
	if _spawn_glow_tween:
		_spawn_glow_tween.kill()

	var glow_color := _spawn_glow_color(entity_type)
	spawn_glow.modulate = Color(glow_color.r, glow_color.g, glow_color.b, spawn_glow_alpha)

	var screen_position: Vector2 = get_viewport().canvas_transform * spawn_position
	spawn_glow.position.x = screen_position.x - spawn_glow.size.x / 2.0

	_spawn_glow_tween = create_tween()
	_spawn_glow_tween.tween_property(spawn_glow, "modulate:a", 0.0, spawn_glow_fade_duration)

func _trigger_harm_effect() -> void:
	if _harm_flash_tween:
		_harm_flash_tween.kill()

	harm_effect.color.a = harm_flash_alpha
	_harm_flash_tween = create_tween()
	_harm_flash_tween.tween_property(harm_effect, "color:a", 0.0, harm_flash_fade_duration)

	_shake_time_left = harm_shake_duration

func _lose_heart() -> void:
	_trigger_harm_effect()

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
	AudioManager.stop_music()

	wave_manager.game_over()

	await get_tree().create_timer(game_over_screen_delay).timeout

	gameover_score_text.text = "Score: %d" % score
	gameover_screen.show()
	_play_defeat_sfx()

# =========================================================
# UI ACTIONS
# =========================================================
func _on_pause_button_pressed() -> void:
	if not is_paused:
		_pause_game()
	elif not _resume_countdown_active:
		_start_resume_countdown()
	
func _unhandled_input(event: InputEvent) -> void:
	# don't do anything if settings menu is shown
	if settings_menu.visible:
		return
	
	if event.is_action_pressed("Pause"):
		_handle_pause_input()

func _on_resume_button_pressed() -> void:
	if not _resume_countdown_active:
		_start_resume_countdown()

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
		if not _resume_countdown_active:
			_start_resume_countdown()
	else:
		_pause_game()

func _pause_game() -> void:
	if _intro_countdown_active:
		return

	is_paused = true
	get_tree().paused = true

	AudioManager.pause_music()
	AudioManager.disable_mouse_sfx()

	pause_screen.show()

# counts down while the game stays paused, then actually resumes
func _start_resume_countdown() -> void:
	_resume_countdown_active = true
	pause_screen.hide()

	var count := resume_countdown_seconds
	countdown_label.text = str(count)
	countdown_label.show()
	_play_countdown_sfx()

	while count > 0:
		await get_tree().create_timer(1.0).timeout
		count -= 1
		if count > 0:
			countdown_label.text = str(count)
			_play_countdown_sfx()

	countdown_label.hide()
	_resume_countdown_active = false

	_resume_game()

func _resume_game() -> void:
	is_paused = false
	get_tree().paused = false

	AudioManager.resume_music()
	AudioManager.enable_mouse_sfx()

	pause_screen.hide()
