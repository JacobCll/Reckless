extends CanvasLayer

@onready var mouse_trail_effect = $MouseTrail

func _ready() -> void:
	mouse_trail_effect.show()

func hide_mouse_trail():
	mouse_trail_effect.hide()
	MouseSfx.enabled = false
	
func show_mouse_trail():
	mouse_trail_effect.show()
	MouseSfx.enabled = true
