# LEVEL 1
extends BaseLevel

func _ready() -> void:
	super()

func show_tutorial():
	get_tree().change_scene_to_file("res://scenes/levels/tutorial_level/tutorial_level.tscn")
	GameManager.from_level = 1
