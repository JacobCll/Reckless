extends CanvasLayer

@onready var master_slider = $Control/MasterSlider
@onready var music_slider = $Control/MusicSlider
@onready var sfx_slider = $Control/SfxSlider

var HELP_MANUAL = preload("res://settings/helpmanual.tscn")

func _ready():
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume

	Settings.apply_settings()
	
	#hide()

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

func _on_help_button_pressed() -> void:
	var help_manual_scene = HELP_MANUAL.instantiate()
	get_tree().current_scene.add_child(help_manual_scene)
