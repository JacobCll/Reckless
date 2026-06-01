extends CanvasLayer

@onready var mouse_trail_effect = $MouseTrail

func hide_mouse_trail():
	mouse_trail_effect.hide()
