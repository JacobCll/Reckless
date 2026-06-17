extends Node

const SAVE_FILE := "user://game_manager_state.dat"

var current_scene := "main_menu"
var user_orbs := 0
var highest_unlocked_level := 1
var max_unlockable_level := 2
var level_1_tutorial_seen := false

var inventory := {
	"powerup_shields": 0,
	"powerup_no_green": 0,
	"powerup_double_orbs": 0
}

func _ready():
	load_data()
	reset()

# for debugging
func reset():
	user_orbs = 0
	highest_unlocked_level = 1
	inventory = {
		"powerup_shields": 0,
		"powerup_no_green": 0,
		"powerup_double_orbs": 0
	}
	save_data()

func is_level_unlocked(level: int) -> bool:
	return level <= highest_unlocked_level

func unlock_level(level_completed: int) -> void:
	var next_level := level_completed + 1

	if next_level > highest_unlocked_level and next_level <= max_unlockable_level:
		highest_unlocked_level = next_level
		save_data()

func save_data() -> void:
	var data := {
		"highest_unlocked_level": highest_unlocked_level,
		"user_orbs": user_orbs,
		"inventory": inventory,
		"level_1_tutorial_seen": level_1_tutorial_seen
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
		"health_potion": 0,
		"damage_boost": 0,
		"shield": 0
	})
	level_1_tutorial_seen = saved_data.get("level_1_tutorial_seen", false)
