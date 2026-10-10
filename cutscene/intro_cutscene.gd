class_name IntroCutscene
extends Control

# Boot scene: plays the intro video, then moves on to the main menu.
# The video must be Ogg Theora (.ogv), the only format Godot plays natively.
# Until a file exists at VIDEO_PATH, or while the intro is turned off in the
# settings, the game boots straight to the main menu.
const SCENE_PATH := "res://cutscene/intro_cutscene.tscn"
const VIDEO_PATH := "res://cutscene/intro.ogv"
const NEXT_SCENE_PATH := "res://scenes/main_menu.tscn"

@export var fade_out_duration := 0.6
@export var fade_in_duration := 0.8 # black to main menu, after the cutscene

@onready var video_frame: AspectRatioContainer = $VideoFrame
@onready var video_player: VideoStreamPlayer = $VideoFrame/VideoStreamPlayer
@onready var skip_button: TextureButton = $SkipButton
@onready var fade: ColorRect = $Fade

static var _replaying := false

var _finished := false

# Replays the cutscene on request (e.g. from the settings menu), even while the
# intro is turned off. Afterwards the game continues to the main menu as usual.
static func watch(tree: SceneTree) -> void:
	_replaying = true
	tree.paused = false
	tree.change_scene_to_file(SCENE_PATH)

func _ready() -> void:
	var replaying := _replaying
	_replaying = false

	# stream the main menu in while the video plays so the switch is instant
	ResourceLoader.load_threaded_request(NEXT_SCENE_PATH)

	if not ResourceLoader.exists(VIDEO_PATH) or not (replaying or Settings.intro_cutscene_enabled):
		_go_to_next_scene.call_deferred()
		return

	AudioManager.stop_music()
	MouseManager.hide_mouse_trail()
	video_player.stream = load(VIDEO_PATH)
	_play()

func _input(event: InputEvent) -> void:
	if _finished or not event.is_pressed() or event.is_echo():
		return

	if event.is_action("ui_cancel") or event.is_action("ui_accept") or event.is_action("Pause"):
		get_viewport().set_input_as_handled()
		_finish()

func _play() -> void:
	video_player.play()
	skip_button.show()

	# keep the video's own aspect ratio, letterboxed inside the 4:3 window
	var texture := video_player.get_video_texture()
	if texture and texture.get_height() > 0:
		video_frame.ratio = float(texture.get_width()) / texture.get_height()

func _finish() -> void:
	if _finished:
		return
	_finished = true
	skip_button.disabled = true

	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, fade_out_duration)
	tween.parallel().tween_property(video_player, "volume", 0.0, fade_out_duration)
	tween.tween_callback(video_player.stop)
	tween.tween_callback(_go_to_next_scene)

func _go_to_next_scene() -> void:
	var tree := get_tree()
	var next_scene: PackedScene = ResourceLoader.load_threaded_get(NEXT_SCENE_PATH)

	# the screen is black at this point, so cover the scene change with a black
	# overlay that lives on the root (outlives this scene) and fade it away once
	# the main menu is in place
	var overlay := CanvasLayer.new()
	overlay.layer = 128
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(black)
	tree.root.add_child(overlay)

	# start the main menu's music silent so it fades in with the picture
	var music_volume_db: float = AudioManager.music_player.volume_db
	AudioManager.music_player.volume_db = -40.0

	tree.scene_changed.connect(IntroCutscene._fade_in_next_scene.bind(overlay, black, music_volume_db, fade_in_duration), CONNECT_ONE_SHOT)
	tree.change_scene_to_packed(next_scene)

# static: this scene is freed by the time the next one is ready
static func _fade_in_next_scene(overlay: CanvasLayer, black: ColorRect, music_volume_db: float, duration: float) -> void:
	var music_player: AudioStreamPlayer = AudioManager.music_player
	var tween := overlay.create_tween().set_parallel()
	tween.tween_property(black, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(music_player, "volume_db", music_volume_db, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(overlay.queue_free)

func _on_video_stream_player_finished() -> void:
	_finish()

func _on_skip_button_pressed() -> void:
	_finish()
