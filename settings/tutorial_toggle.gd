extends CheckButton

# CheckButton has no hover icons, so swap in hover versions of the switch while the
# mouse is over it, like the other settings buttons' hover textures
@export var checked_hover_icon: Texture2D
@export var unchecked_hover_icon: Texture2D

var _checked_icon: Texture2D
var _unchecked_icon: Texture2D

func _ready() -> void:
	_checked_icon = get_theme_icon("checked")
	_unchecked_icon = get_theme_icon("unchecked")

	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))

func _set_hovered(hovered: bool) -> void:
	add_theme_icon_override("checked", checked_hover_icon if hovered else _checked_icon)
	add_theme_icon_override("unchecked", unchecked_hover_icon if hovered else _unchecked_icon)
