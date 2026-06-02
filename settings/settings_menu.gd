extends CanvasLayer

@onready var music_slider = $Control/MusicSlider

func _ready():
	music_slider.value = Settings.music_volume
	_apply_audio()
	
	hide()

func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _apply_audio():
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(Settings.music_volume)
	)

func _on_back_button_pressed() -> void:
	MouseManager.show_mouse_trail()
	hide()
