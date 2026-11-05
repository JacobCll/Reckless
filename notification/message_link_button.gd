class_name MessageLinkButton
extends LinkButton

@export var subject_title: String
@export var date: String
@export var time: String

@export var border_color := Color(0.5803922, 0.90588236, 0.50980395, 1)
@export var border_width := 2
@export var hover_text_color := Color(0.1, 0.16, 0.11, 1)

var _border_style := StyleBoxFlat.new()
var _hover_style: StyleBoxFlat
var _background := Panel.new()

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

	# filled version of the border, shown while hovered
	_hover_style = _border_style.duplicate() as StyleBoxFlat
	_hover_style.draw_center = true
	_hover_style.bg_color = border_color

	# _draw() runs after the text is drawn, so the fill lives on a child drawn behind the button
	_background.show_behind_parent = true
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.add_theme_stylebox_override("panel", _border_style)
	add_child(_background)

	# hollow text on hover: match the dark screen color so the letters look cut out of the green
	add_theme_color_override("font_hover_color", hover_text_color)
	add_theme_color_override("font_hover_pressed_color", hover_text_color)

	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))

func _set_hovered(hovered: bool) -> void:
	_background.add_theme_stylebox_override("panel", _hover_style if hovered else _border_style)
