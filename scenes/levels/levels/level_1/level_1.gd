# LEVEL 1
extends BaseLevel

func _ready() -> void:
	super()
	
	if not GameManager.level_1_tutorial_seen:
		show_tutorial()

func show_tutorial():
	get_tree().change_scene_to_file("res://scenes/levels/tutorial_level/tutorial_level.tscn")
