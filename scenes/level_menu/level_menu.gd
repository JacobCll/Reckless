class_name LevelMenu
extends TextureRect

@export var level_button: PackedScene

var levels = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grid = $LevelGrid
	grid.columns = 5
	
	for i in range(levels):
		var btn = level_button.instantiate()
		
		btn.level_number = i + 1
		btn.text = str(i + 1)
		
		if i == 0:
			btn.level_path = "res://scenes/levels/test_level/test_level.tscn"
			btn.text = "Test Level"
		else:
			btn.level_path = "res://scenes/levels/level_" + str(i+1) + "/level_" + str(i+1) + ".tscn"
		
		btn.level_selected.connect(_on_level_selected)
		
		# disable if not unlocked 
		if not GameManager.is_level_unlocked(i + 1):
			btn.disabled = true
			btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
		
		grid.add_child(btn)

func _on_level_selected(path) -> void:
	var loading = preload("res://loading_screen/loading_screen.tscn").instantiate()
	loading.next_scene_path = path
	get_tree().root.add_child(loading)
	get_tree().current_scene.queue_free()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
