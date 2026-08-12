# LEVEL 1
extends BaseLevel

func _ready() -> void:
	super()

func show_tutorial():
	LoadingScreen.transition_to(get_tree(), "res://scenes/levels/tutorial_level/tutorial_level.tscn")
	GameManager.from_level = 1
