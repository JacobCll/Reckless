extends CanvasLayer

@onready var master_slider = $Control/VBoxContainer/MasterSlider
@onready var music_slider = $Control/VBoxContainer/MusicSlider
@onready var sfx_slider = $Control/VBoxContainer/SfxSlider
@onready var tutorial_toggle = $Control/VBoxContainer/TutorialToggleContainer/TutorialToggle
@onready var tutorial_button = $Control/TutorialButton

@export var show_tutorial_button := true

func _ready():
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	tutorial_toggle.button_pressed = GameManager.level_1_step_tutorial_enabled
	tutorial_button.visible = show_tutorial_button

	Settings.apply_settings()

	hide()

func _on_tutorial_toggle_toggled(pressed: bool) -> void:
	GameManager.level_1_step_tutorial_enabled = pressed
	GameManager.save_data()

func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(value))

func _on_master_slider_value_changed(value: float) -> void:
	Settings.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_back_button_pressed() -> void:
	Settings.save()
	Settings.apply_settings()
	MouseManager.show_mouse_trail()
	hide()

var tutorial_level_path := "res://scenes/levels/tutorial_level/tutorial_level.tscn"

func _on_tutorial_button_pressed() -> void:
	LoadingScreen.transition_to(get_tree(), tutorial_level_path)
