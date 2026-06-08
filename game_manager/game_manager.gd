extends Node

var current_scene := "main_menu"
var user_orbs := 0
var highest_unlocked_level := 1

func _ready():
	highest_unlocked_level = 1

func is_level_unlocked(level: int) -> bool:
	return level <= highest_unlocked_level

func unlock_level() -> void:
	highest_unlocked_level += 1
