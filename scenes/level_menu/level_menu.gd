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
		btn.level_path = "res://scenes/levels/level_" + str(i+1) + "/level_" + str(i+1) + ".tscn"
		
		btn.level_selected.connect(_on_level_selected)
		
		grid.add_child(btn)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_level_selected(path) -> void:
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
