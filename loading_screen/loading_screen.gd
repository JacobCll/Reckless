extends CanvasLayer

@export var next_scene_path := ""

@onready var progress_bar = $ProgressBar
@onready var label = $Label

func _ready():
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(
		next_scene_path,
		progress
	)

	if progress.size() > 0:
		progress_bar.value = progress[0] * 100

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
		get_parent().remove_child(self)
		queue_free()
