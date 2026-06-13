class_name TutorialLevel
extends BaseLevel

enum TutorialStep {
	SLASH,
	SMASH,
	AVOID
}

var current_step := TutorialStep.SLASH

var blue_entities_slashed := 0
var red_entities_smashed := 0

# override - remove countdown
func _ready() -> void:
	_setup_level()
	_setup_ui()
	_setup_spawners()
	_prewarm_particles()
	
	$BlueSpawner.entity_slashed.connect(_on_entity_slashed)
	$BlueSpawner.entity_smashed.connect(_on_entity_smashed)

	$RedSpawner.entity_slashed.connect(_on_entity_slashed)
	$RedSpawner.entity_smashed.connect(_on_entity_smashed)
	
	$GreenSpawner.entity_killed.connect(_on_entity_killed)
	$GreenSpawner.entity_despawned.connect(_on_entity_despawned)
	_on_level_start()

# override - show hud
func _setup_ui() -> void:
	pause_screen.hide()
	gameover_screen.hide()
	win_screen.hide()
	hud.show()

# override hook
func _on_level_start() -> void:
	start_step()

func next_step():
	current_step = (current_step + 1) as TutorialStep
	start_step()

# =========================================================
# ENTITY SIGNALS
# =========================================================
# override - forgive the user from missing
func _on_entity_despawned(entity_type: String) -> void:
	if current_step == TutorialStep.AVOID and entity_type == "green":
		print("Tutorial complete!")
		hud.hide()
		win_screen.show()

func _on_entity_slashed(entity_type: String) -> void:
	super(entity_type)
	
	blue_entities_slashed += 1
	
	if current_step == TutorialStep.SLASH:
		next_step()
	else:
		return

func _on_entity_smashed(entity_type: String) -> void:
	super(entity_type)
	
	red_entities_smashed += 1
	
	if current_step == TutorialStep.SMASH:
		next_step()
	else:
		return

func _on_entity_killed(entity_type: String) -> void:
	if entity_type == "green":
		print("Green entity killed")
# STEPS
func start_step():
	match current_step:
		TutorialStep.SLASH:
			_handle_tutorial_slash()
		TutorialStep.SMASH:
			_handle_tutorial_smash()
		TutorialStep.AVOID:
			_handle_tutorial_avoid()

func _handle_tutorial_slash():
	var blue_spawner := $BlueSpawner
	
	blue_spawner.spawn_entity(1)

func _handle_tutorial_smash():
	var red_spawner := $RedSpawner
	
	red_spawner.spawn_entity(1)

func _handle_tutorial_avoid():
	var green_spawner := $GreenSpawner
	
	green_spawner.spawn_entity(1)
