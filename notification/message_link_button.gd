class_name MessageLinkButton
extends LinkButton

@export var subject_title: String
@export var date: String
@export var time: String

@export var border_color := Color(0.5803922, 0.90588236, 0.50980395, 1)
@export var border_width := 2

var _border_style := StyleBoxFlat.new()

func _ready() -> void:
	# LinkButton ignores normal/hover styleboxes, so draw the border ourselves
	_border_style.draw_center = false
	_border_style.border_color = border_color
	_border_style.set_border_width_all(border_width)
	_border_style.set_corner_radius_all(6)
	_border_style.expand_margin_left = 8.0
	_border_style.expand_margin_right = 8.0
	_border_style.expand_margin_top = 4.0
	_border_style.expand_margin_bottom = 4.0
	queue_redraw()

func _draw() -> void:
	draw_style_box(_border_style, Rect2(Vector2.ZERO, size))
