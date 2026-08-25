extends TextureButton

@export var texture_on_normal: Texture2D
@export var texture_on_hover: Texture2D
@export var texture_on_pressed: Texture2D
@export var texture_off_normal: Texture2D
@export var texture_off_hover: Texture2D
@export var texture_off_pressed: Texture2D

func _ready() -> void:
	_update_textures()

	pressed.connect(_on_pressed)
	Settings.main_menu_music_muted_changed.connect(_on_muted_changed_elsewhere)

func _on_pressed() -> void:
	Settings.set_main_menu_music_muted(not Settings.main_menu_music_muted)

func _on_muted_changed_elsewhere(_muted: bool) -> void:
	_update_textures()

func _update_textures() -> void:
	if Settings.main_menu_music_muted:
		texture_normal = texture_off_normal
		texture_hover = texture_off_hover
		texture_pressed = texture_off_pressed
	else:
		texture_normal = texture_on_normal
		texture_hover = texture_on_hover
		texture_pressed = texture_on_pressed
