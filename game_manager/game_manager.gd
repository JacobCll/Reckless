extends Node

const SAVE_FILE := "user://game_manager_state.dat"

# SAVE TO FILE
var current_scene := "main_menu"
var user_orbs := 0 # user currency
var highest_unlocked_level := 1 # highest level the player has unlocked
var MAX_UNLOCKABLE_LEVEL := 2 # max level that can be unlocked
var level_1_tutorial_seen := false
var level_1_step_tutorial_enabled := true

# DO NOT SAVE TO FILE
var from_level := 0 # 0 is default (none)
var selected_powerup := ""
var selected_notification := ""
var show_cutscene := true

# dictionary of {item_id: amount owned}
var inventory := {
	"powerup_shields": 0,
	"powerup_no_green": 0,
	"powerup_double_orbs": 0
}

# dictionary of all item information, access with item_id
var item_info := {
	"powerup_shields": {
		"display_name": "Shields",
		"cost": 15,
		"description": "Adds +2 shields at the start of the run",
		"texture": "res://buttons/powerups-buttons/powerup_shield.png"
	},
	"powerup_double_orbs": {
		"display_name": "Double Orbs",
		"cost": 50,
		"description": "Higher chance of double orb drops",
		"texture": "res://buttons/powerups-buttons/poweup_double_orbs.png"
	},
	"powerup_no_green": {
		"display_name": "No Green!",
		"cost": 1000,
		"description": "Eliminate the chance of green entities spawning",
		"texture": "res://buttons/powerups-buttons/powerup_ nogreen.png"
	}
}

func _ready():
	load_data()
	#reset()

# for debugging
func reset():
	user_orbs = 0
	highest_unlocked_level = 1
	inventory = {
		"powerup_shields": 0,
		"powerup_no_green": 0,
		"powerup_double_orbs": 0
	}
	level_1_tutorial_seen = false
	level_1_step_tutorial_enabled = true
	save_data()

func is_level_unlocked(level: int) -> bool:
	return level <= highest_unlocked_level

func unlock_level(level_completed: int) -> void:
	var next_level := level_completed + 1

	if next_level > highest_unlocked_level and next_level <= MAX_UNLOCKABLE_LEVEL:
		highest_unlocked_level = next_level
		save_data()

func save_data() -> void:
	var data := {
		"highest_unlocked_level": highest_unlocked_level,
		"user_orbs": user_orbs,
		"inventory": inventory,
		"level_1_tutorial_seen": level_1_tutorial_seen,
		"level_1_step_tutorial_enabled": level_1_step_tutorial_enabled
	}

	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(data)

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return

	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	var saved_data = file.get_var()
	
	if typeof(saved_data) != TYPE_DICTIONARY:
		return

	highest_unlocked_level = saved_data.get("highest_unlocked_level", 1)
	user_orbs = saved_data.get("user_orbs", 0)
	inventory = saved_data.get("inventory", {
		"powerup_shields": 0,
		"powerup_no_green": 0,
		"powerup_double_orbs": 0
	})
	level_1_tutorial_seen = saved_data.get("level_1_tutorial_seen", false)
	level_1_step_tutorial_enabled = saved_data.get("level_1_step_tutorial_enabled", true)
