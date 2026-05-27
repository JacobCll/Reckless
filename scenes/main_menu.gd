class_name MainMenu
extends TextureRect

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu/level_menu.tscn")
