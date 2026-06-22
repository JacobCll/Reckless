class_name PowerupCard
extends Panel

@onready var powerup_name_label := $Name

signal selected(card)
var is_selected = false

var item_id: String
var powerup_name: String
var quantity_owned: int

func _ready() -> void:
	update_labels()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	update_visual()

func update_visual() -> void:
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat

	if is_selected:
		style.bg_color = Color(1.0, 1.0, 0.0, 0.15) # faint yellow
	else:
		style.bg_color = Color.TRANSPARENT

	add_theme_stylebox_override("panel", style)

func set_selected(value: bool) -> void:
	print("hello")
	is_selected = value
	update_visual()

func update_labels():
	powerup_name_label.text = powerup_name + "  x" + str(quantity_owned)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		selected.emit(self)

func _on_mouse_entered():
	scale = Vector2(1.05, 1.05)
	
func _on_mouse_exited():
	scale = Vector2.ONE
