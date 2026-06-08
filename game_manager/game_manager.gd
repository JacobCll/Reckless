extends Node

const SAVE_FILE := "user://save.dat"

var current_scene := "main_menu"
var user_orbs := 0
var highest_unlocked_level := 1

func _ready():
	load_data()

func is_level_unlocked(level: int) -> bool:
	return level <= highest_unlocked_level

func unlock_level() -> void:
	highest_unlocked_level += 1
	save_data()

func save_data() -> void:
	var data := {
		"highest_unlocked_level": highest_unlocked_level,
		"user_orbs": user_orbs
	}

	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(data)

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return

	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	var saved_data = file.get_var()

	highest_unlocked_level = saved_data.get("highest_unlocked_level", 1)
	user_orbs = saved_data.get("user_orbs", 0)
