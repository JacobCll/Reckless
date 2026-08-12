class_name TutorialLevel
extends BaseLevel

enum TutorialStep {
	SLASH,
	SMASH,
	AVOID,
	ALL,
	COMPLETE
}
var current_step := TutorialStep.SLASH

var slashed_count := 0
var smashed_count := 0
var despawned_count := 0

@onready var blue_spawner := $BlueSpawner
@onready var red_spawner := $RedSpawner
@onready var green_spawner := $GreenSpawner
@onready var all_spawner := $AllSpawner

var current_page := 0
@onready var tutorial_modal := $CanvasLayer/TutorialModal
@onready var main_modal := $CanvasLayer/TutorialModal/MainModal
@onready var tutorial_body_text := $CanvasLayer/TutorialModal/MainModal/TutorialBodyText
@onready var tutorial_button := $CanvasLayer/TutorialModal/MainModal/TutorialButton
@onready var text_modal := $CanvasLayer/TutorialModal/TextModal
@onready var text_modal_text := $CanvasLayer/TutorialModal/TextModal/Text
@onready var continue_button := $CanvasLayer/TutorialModal/ContinueButton

var pages := [
	{
		"body": "Welcome to the tutorial!"
	},
	{
		"body": "Make sure that you have a keyboard and mouse/trackpad for a better gaming experience."
	},
	{
		"body": "Let's try it!"
	}
]

# override - remove countdown
func _ready() -> void:
	_setup_level()
	_setup_ui()
	_prewarm_particles()
	
	blue_spawner.entity_slashed.connect(_on_entity_slashed)
	blue_spawner.entity_smashed.connect(_on_entity_smashed)
	
	red_spawner.entity_slashed.connect(_on_entity_slashed)
	red_spawner.entity_smashed.connect(_on_entity_smashed)
	
	green_spawner.entity_killed.connect(_on_entity_killed)
	green_spawner.entity_despawned.connect(_on_entity_despawned)
	
	all_spawner.entity_killed.connect(_on_entity_killed)
	all_spawner.entity_slashed.connect(_on_entity_slashed)
	all_spawner.entity_smashed.connect(_on_entity_smashed)
	
	_on_level_start()

# override - show hud
func _setup_ui() -> void:
	progress_bar.hide()
	pause_screen.hide()
	gameover_screen.hide()
	win_screen.hide()
	hud.show()
	
	tutorial_modal.show()
	main_modal.show()
	text_modal.hide()
	continue_button.hide()
	
	_update_hearts_ui()
	_update_shields_ui()

func show_page():
	tutorial_body_text.text = pages[current_page].body
	tutorial_modal.show()

func _on_tutorial_button_pressed():
	if current_step == TutorialStep.COMPLETE:
		# if this is the first time level 1 has been opened and tutorial is not yet completed
		if not GameManager.level_1_tutorial_seen and GameManager.from_level == 1:
			GameManager.level_1_tutorial_seen = true
			GameManager.from_level = 0
			GameManager.save_data()
			get_tree().change_scene_to_file("res://scenes/levels/levels/level_1/level_1.tscn")
		else:
			LoadingScreen.transition_to(get_tree(), "res://scenes/main_menu.tscn")
		return
	
	current_page += 1
	
	if current_page >= pages.size():
		main_modal.hide()
		start_step()
		return

	show_page()

# override hook
func _on_level_start() -> void:
	show_page()

func next_step():
	slashed_count = 0
	smashed_count = 0

	current_step = (current_step + 1) as TutorialStep
	start_step()

func _on_continue_button_pressed() -> void:
	text_modal.hide()
	next_step()

# STEPS
func start_step():
	match current_step:
		TutorialStep.SLASH:
			_handle_tutorial_slash()
		TutorialStep.SMASH:
			_handle_tutorial_smash()
		TutorialStep.AVOID:
			_handle_tutorial_avoid()
		TutorialStep.ALL:
			_handle_tutorial_all()
		TutorialStep.COMPLETE:
			_handle_tutorial_complete()

# =========================================================
# ENTITY SIGNALS
# =========================================================
# override - forgive the user from missing
func _on_entity_despawned(entity_type: String) -> void:
	if current_step == TutorialStep.AVOID and entity_type == "green":
		despawned_count += 1
		
		if despawned_count >= 3:
			continue_button.show()

func _on_entity_slashed(entity_type: String) -> void:
	super(entity_type)
	
	slashed_count += 1
	
	if slashed_count >= 5:
		continue_button.show()

# overriden, no entity drops in tutorial
func _entity_drop(entity_type: String):
	return

# overriden to not let user lose hearts because there is no hearts in the tutorial
func _default_score_logic(entity_type: String, action: String) -> void:
	return

func _on_entity_smashed(entity_type: String) -> void:
	super(entity_type)
	
	smashed_count += 1
	
	if smashed_count >= 5:
		continue_button.show()

func _on_entity_killed(entity_type: String) -> void:
	if current_step == TutorialStep.ALL:
		if slashed_count >= 5 and smashed_count >= 5:
			continue_button.show()
	
	if entity_type == "green":
		CombatAudioSystem.play_despawned()

func _handle_tutorial_slash():
	continue_button.hide()
	text_modal.show()
	text_modal_text.text = "Hold LMB + slide your mouse across the blue objects to slash"
	
	red_spawner.stop()
	green_spawner.stop()
	
	blue_spawner.start()
	blue_spawner.start_spawn_loop()
	

func _handle_tutorial_smash():
	continue_button.hide()
	text_modal.show()
	text_modal_text.text = "Click the red objects to smash"
	
	blue_spawner.stop()
	green_spawner.stop()
	
	red_spawner.start()
	red_spawner.start_spawn_loop()
	

func _handle_tutorial_avoid():
	continue_button.hide()
	text_modal.show()
	text_modal_text.text = "Avoid green objects, just ignore them!"
	
	blue_spawner.stop()
	red_spawner.stop()
	
	green_spawner.start()
	green_spawner.start_spawn_loop()
	

func _handle_tutorial_all():
	continue_button.hide()
	text_modal.show()
	text_modal_text.text = "Now try them all!"
	
	blue_spawner.stop()
	red_spawner.stop()
	green_spawner.stop()
	
	await get_tree().create_timer(1, false).timeout
	
	all_spawner.start()
	all_spawner.start_spawn_loop()
	
func _handle_tutorial_complete():
	continue_button.hide()
	tutorial_modal.show()
	main_modal.show()
	
	blue_spawner.stop()
	red_spawner.stop()
	green_spawner.stop()
	all_spawner.stop()
	
	tutorial_body_text.text = "Congratulations! You have completed the tutorial level!"
	
	tutorial_button.text = "Main Menu"
	
	if GameManager.from_level == 1:
		tutorial_button.text = "Continue to Level 1"
		GameManager.from_level = 0
