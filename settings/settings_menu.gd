extends CanvasLayer

@onready var music_slider = $Control/MusicSlider
@onready var sfx_slider = $Control/SfxSlider

func _ready():
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	
	_apply_audio()
	
	hide()

func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	Settings.save()

func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(value))
	Settings.save()
	
func _apply_audio():
	# apply music
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(Settings.music_volume)
	)
	# apply sfx
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Sfx"),
		linear_to_db(Settings.sfx_volume)
	)

func _on_back_button_pressed() -> void:
	MouseManager.show_mouse_trail()
	hide()
