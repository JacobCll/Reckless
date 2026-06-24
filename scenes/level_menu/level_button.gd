extends TextureButton

signal level_selected(path)

@export_file("*.tscn") var level_path: String
@export var level_number: int

func _pressed():
	if level_path != "" or level_path != null:
		emit_signal("level_selected", level_path)
