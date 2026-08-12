class_name LoadingScreen
extends CanvasLayer

@export var next_scene_path := ""

@onready var progress_bar = $ProgressBar
@onready var label = $Label

static var _scene: PackedScene

# Swaps in the loading screen, which streams target_scene_path in the background
# and switches to it once loaded. Use this instead of change_scene_to_file/
# change_scene_to_packed wherever a scene change should show a loading screen.
static func transition_to(tree: SceneTree, target_scene_path: String) -> void:
	if _scene == null:
		_scene = load("res://loading_screen/loading_screen.tscn")

	var loading = _scene.instantiate()
	loading.next_scene_path = target_scene_path

	tree.root.add_child(loading)
	tree.current_scene.queue_free()

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
