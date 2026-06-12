class_name TutorialLevel
extends BaseLevel

enum TutorialStep {
	SLASH,
	SMASH,
	AVOID
}

var current_step := TutorialStep.SLASH

var tutorial_slash_done := false
var tutorial_smash_done := false
var tutorial_avoid_done := false
var tutorial_all_done := false

var blue_entities_slashed := 0
var red_entities_smashed := 0

# override - remove countdown
func _ready() -> void:
	_setup_level()
	_setup_ui()
	_setup_spawners()
	_prewarm_particles()
	
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	
	_on_level_start()

# override - show hud
func _setup_ui() -> void:
	pause_screen.hide()
	gameover_screen.hide()
	win_screen.hide()
	hud.show()

# override hook
func _on_level_start() -> void:
	wave_manager.start()
	
	start_step()

# =========================================================
# ENTITY SIGNALS
# =========================================================
# override - forgive the user from missing
func _on_entity_despawned(_entity_type: String) -> void:
	pass

func _on_entity_slashed(entity_type: String) -> void:
	super(entity_type)
	
	blue_entities_slashed += 1
	
	if current_step == 0:
		current_step = (current_step + 1) as TutorialStep
		start_step()
	else:
		return

func _on_entity_smashed(entity_type: String) -> void:
	super(entity_type)
	
	red_entities_smashed += 1
	
	if current_step == 1:
		current_step = (current_step + 1) as TutorialStep
		start_step()
	else:
		return

# =========================================================
# WAVE SIGNALS
# =========================================================
func _on_wave_started() -> void:
	var current_wave = wave_manager.current_wave + 1
	print("Tutorial Step ", current_wave, " started")
	$CanvasLayer/HUD/CurrentWaveLabel.text = "Wave: %d" % (current_wave)

func _on_wave_completed() -> void:
	var current_wave = wave_manager.current_wave + 1
	print("Tutorial Step ", current_wave, " completed")

func _on_all_waves_completed() -> void:
	hud.hide()
	win_screen.show()

# STEPS
func start_step():
	match current_step:
		TutorialStep.SLASH:
			_handle_tutorial_slash()
		TutorialStep.SMASH:
			_handle_tutorial_smash()

func _handle_tutorial_slash():
	var blue_spawner := $Waves/SlashTutorial/BlueSpawner
	
	blue_spawner.spawn_entity(1)

func _handle_tutorial_smash():
	var red_spawner := $Waves/SmashTutorial/RedSpawner
	
	red_spawner.spawn_entity(1)
