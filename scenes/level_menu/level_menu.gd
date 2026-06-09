class_name LevelMenu
extends TextureRect

@export var level_menu_music: AudioStream


func _ready() -> void:
	AudioManager.play_music(level_menu_music)
	GameManager.current_scene = "level_menu"

	var buttons: Array = get_children()

	for i in range(buttons.size()):
		var btn = buttons[i]

		if btn is LevelButton:
			var level_num := i + 1

			btn.level_number = level_num
			btn.level_path = "res://scenes/levels/levels/level_%d/level_%d.tscn" % [level_num, level_num]

			if not btn.level_selected.is_connected(_on_level_selected):
				btn.level_selected.connect(_on_level_selected)

			var unlocked: bool = GameManager.is_level_unlocked(level_num)

			btn.unlocked = unlocked
			btn.disabled = not unlocked

			btn.mouse_default_cursor_shape = (
				Control.CURSOR_POINTING_HAND
				if unlocked
				else Control.CURSOR_ARROW
			)

func _on_level_selected(path: String) -> void:
	var loading = preload("res://loading_screen/loading_screen.tscn").instantiate()
	loading.next_scene_path = path

	get_tree().root.add_child(loading)
	get_tree().current_scene.queue_free()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
