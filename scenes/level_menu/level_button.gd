@tool
extends TextureButton

signal level_selected()

@export var level_num: int = 1
@export var locked: bool = true:
	set(value):
		locked = value
		level_locked() if locked else level_unlocked()
		
func level_locked() -> void:
	level_state(true)
	
func level_unlocked() -> void:
	level_state(false)
	
func level_state(value: bool) -> void:
	disabled = value
	$Label.visible = not value
	
func _on_pressed() -> void:
	level_selected.emit(level_num)
