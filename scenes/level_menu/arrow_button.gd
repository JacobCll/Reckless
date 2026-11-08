class_name ArrowButton
extends Button

# simple triangle button drawn in code, used to page through the level menu

@export var points_left := false
@export var normal_color := Color(1, 1, 1, 0.85)
@export var hover_color := Color(1, 0.85, 0.3, 1)
@export var pressed_color := Color(0.8, 0.65, 0.2, 1)
@export var shadow_color := Color(0, 0, 0, 0.6)
@export var shadow_offset := Vector2(4, 4)

func _ready() -> void:
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)

func _draw() -> void:
	var points := _triangle_points()
	draw_colored_polygon(_offset_points(points, shadow_offset), shadow_color)
	draw_colored_polygon(points, _current_color())

func _triangle_points() -> PackedVector2Array:
	if points_left:
		return PackedVector2Array([Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(0, size.y / 2.0)])
	return PackedVector2Array([Vector2(0, 0), Vector2(0, size.y), Vector2(size.x, size.y / 2.0)])

func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	for p in points:
		result.append(p + offset)
	return result

func _current_color() -> Color:
	match get_draw_mode():
		DRAW_PRESSED, DRAW_HOVER_PRESSED:
			return pressed_color
		DRAW_HOVER:
			return hover_color
		_:
			return normal_color
