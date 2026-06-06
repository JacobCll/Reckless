extends CanvasLayer

@onready var music_slider = $Control/MusicSlider
@onready var sfx_slider = $Control/SfxSlider

func _ready():
	# 1. Temporarily disconnect the signal
	music_slider.value_changed.disconnect(_on_music_slider_value_changed)
	sfx_slider.value_changed.disconnect(_on_sfx_slider_value_changed)

	# 2. Update the value (this won't fire the signal anymore)
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume

	# 3. Reconnect the signal for future user interaction
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	
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
