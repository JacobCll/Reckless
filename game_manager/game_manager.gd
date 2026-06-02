extends Node

var current_scene := "main_menu"
var unlocked_levels := [1]

func is_level_unlocked(level: int) -> bool:
	return level in unlocked_levels

func unlock_level(level: int) -> void:
	unlocked_levels[level] = true
