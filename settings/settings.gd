extends Node

var music_volume := 1.0
var sfx_volume := 1.0

func _ready():
	load_settings()

func save():
	var data = {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	

func load_settings():
	if not FileAccess.file_exists("user://settings.json"):
		return
		
	var file = FileAccess.open("user://settings.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	if data:
		music_volume = data.get("music_volume", 1.0)
		sfx_volume = data.get("sfx_volume", 1.0)
