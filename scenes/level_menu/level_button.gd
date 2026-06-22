extends Button

signal level_selected(path)

@export var level_path: String
@export var level_number: int
@export var unlocked: bool = true

func _pressed():
	if level_path != "":
		emit_signal("level_selected", level_path)
