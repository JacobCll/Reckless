extends BaseLevel

enum TutStep { PAUSE, HEARTS, WAVE_LABEL, PROGRESS_BAR, BLUE, RED, GREEN, NONE }

const ENTITY_HIGHLIGHT_SIZE := Vector2(160, 160)
const EXPLANATION_BOX_SIZE := Vector2(360, 140)
const BOX_MARGIN := 16.0
const ENTITY_RISE_DELAY := 0.45

signal tutorial_click_advanced

var tutorial_active := false
var current_tut_step := TutStep.NONE
var _click_to_advance := false

var _tutorial_overlay: Control
var _dim_rect: ColorRect
var _dim_material: ShaderMaterial
var _mask_top: ColorRect
var _mask_bottom: ColorRect
var _mask_left: ColorRect
var _mask_right: ColorRect
var _explanation_panel: Panel
var _explanation_label: Label

func show_tutorial():
	LoadingScreen.transition_to(get_tree(), "res://scenes/levels/tutorial_level/tutorial_level.tscn")
	GameManager.from_level = 1

# =========================================================
# OVERRIDE HOOKS
# =========================================================
func _begin_intro() -> void:
	tutorial_active = GameManager.level_1_step_tutorial_enabled
	if not tutorial_active:
		start_countdown()
		return

	_build_tutorial_overlay_nodes()
	hud.show()

	await _show_tutorial_step(TutStep.PAUSE, pause_button.get_global_rect(), "This is the Pause button. Tap it anytime to pause the game.", true)
	await _show_tutorial_step(TutStep.HEARTS, hearts_container.get_global_rect(), "These are your lives. Lose them all and it's game over!", true)
	await _show_tutorial_step(TutStep.WAVE_LABEL, $CanvasLayer/HUD/CurrentWaveLabel.get_global_rect(), "This shows which wave you're currently on.", true)
	await _show_tutorial_step(TutStep.PROGRESS_BAR, level_progress_bar.get_global_rect(), "This tracks your progress through the current wave.", true)

	start_countdown()

func _start_wave_spawning() -> void:
	if not tutorial_active:
		super()
		return

	match wave_manager.current_wave:
		0:
			await _run_entity_step("blue", TutStep.BLUE, "Swipe across blue items to slash them!")
		1:
			await _run_entity_step("red", TutStep.RED, "Click red items to smash them!")
		2:
			await _run_avoid_step()
		_:
			super()
			return

	super()

func _pause_game() -> void:
	super()
	if tutorial_active and current_tut_step != TutStep.NONE:
		_tutorial_overlay.hide()

func _resume_game() -> void:
	super()
	if tutorial_active and current_tut_step != TutStep.NONE:
		_tutorial_overlay.show()

# =========================================================
# ENTITY STEPS
# =========================================================
func _run_entity_step(type: String, step: TutStep, text: String) -> void:
	current_tut_step = step
	_set_mask_full_block()
	_show_overlay_blank()

	var spawner := _get_wave_spawner(wave_manager.current_wave)
	# untyped: BlueEntityBase/RedEntityBase declare `slashed`/`smashed` themselves,
	# not RigidBody2D, so a static type here would break member access below
	var entity = spawner.spawn_specific(type)
	# blue/green detect slashes by polling Input directly in _process(), which the
	# input-blocking mask can't intercept (it only stops real Godot input events) —
	# disabling _process() is what actually prevents an early slash/smash here
	entity.set_process(false)

	# let it rise into view under its normal throw impulse before holding it in place;
	# clicks are fully blocked the whole time so it can't be slashed/smashed early
	await get_tree().create_timer(ENTITY_RISE_DELAY, false).timeout

	_hold_entity_in_place(entity)

	var wait_signal: Signal = entity.slashed if type == "blue" else entity.smashed
	await _show_tutorial_step(step, _entity_screen_rect(entity), text, false, wait_signal)

func _run_avoid_step() -> void:
	current_tut_step = TutStep.GREEN
	_set_mask_full_block()
	_show_overlay_blank()

	var spawner := _get_wave_spawner(wave_manager.current_wave)
	var entity = spawner.spawn_specific("green")
	var original_gravity_scale: float = entity.gravity_scale
	entity.set_process(false)

	await get_tree().create_timer(ENTITY_RISE_DELAY, false).timeout

	_hold_entity_in_place(entity)

	await _show_tutorial_step(TutStep.GREEN, _entity_screen_rect(entity), "Avoid green items — don't slash or smash them!", true)

	entity.gravity_scale = original_gravity_scale

# shows the overlay with the dim active but no highlight cutout or text box yet,
# so the previous step's spotlight/text can't flash while a new target is pending
func _show_overlay_blank() -> void:
	_dim_material.set_shader_parameter("highlight_enabled", 0.0)
	_explanation_panel.hide()
	_tutorial_overlay.show()

# holds a RigidBody2D still without touching its `freeze` property/method
# (BlueEntityBase defines its own freeze()/unfreeze() methods that shadow it),
# then re-enables _process() so slash/smash detection resumes now that it's safe
func _hold_entity_in_place(entity: RigidBody2D) -> void:
	entity.gravity_scale = 0.0
	entity.linear_velocity = Vector2.ZERO
	entity.angular_velocity = 0.0
	entity.set_process(true)

func _get_wave_spawner(wave_index: int) -> EntitySpawner:
	for child in wave_manager.waves[wave_index].get_children():
		if child is EntitySpawner:
			return child
	return null

func _entity_screen_rect(entity: Node2D) -> Rect2:
	var screen_pos: Vector2 = get_viewport().canvas_transform * entity.global_position
	return Rect2(screen_pos - ENTITY_HIGHLIGHT_SIZE / 2.0, ENTITY_HIGHLIGHT_SIZE)

# =========================================================
# STEP DRIVER
# =========================================================
func _show_tutorial_step(step: TutStep, target_rect: Rect2, text: String, click_anywhere: bool, wait_signal: Signal = Signal()) -> void:
	current_tut_step = step
	_position_overlay(target_rect, text)
	_tutorial_overlay.show()

	if click_anywhere:
		_set_mask_full_block()
		_click_to_advance = true
		await tutorial_click_advanced
		_click_to_advance = false
	else:
		_set_mask_gap(target_rect)
		await wait_signal

	_tutorial_overlay.hide()
	current_tut_step = TutStep.NONE

# =========================================================
# OVERLAY CONSTRUCTION
# =========================================================
func _build_tutorial_overlay_nodes() -> void:
	_tutorial_overlay = Control.new()
	_tutorial_overlay.name = "TutorialOverlay"
	_tutorial_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tutorial_overlay.hide()
	$CanvasLayer.add_child(_tutorial_overlay)

	_dim_rect = ColorRect.new()
	_dim_rect.name = "DimRect"
	_dim_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim_material = ShaderMaterial.new()
	_dim_material.shader = load("res://scenes/levels/levels/level_1/level_1_tutorial_spotlight.gdshader")
	_dim_rect.material = _dim_material
	_tutorial_overlay.add_child(_dim_rect)

	_mask_top = _make_mask_panel("MaskTop")
	_mask_bottom = _make_mask_panel("MaskBottom")
	_mask_left = _make_mask_panel("MaskLeft")
	_mask_right = _make_mask_panel("MaskRight")

	_explanation_panel = Panel.new()
	_explanation_panel.name = "ExplanationPanel"
	_explanation_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tutorial_overlay.add_child(_explanation_panel)

	_explanation_label = Label.new()
	_explanation_label.name = "ExplanationLabel"
	_explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_explanation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_explanation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_explanation_label.add_theme_font_size_override("font_size", 22)
	_explanation_label.add_theme_color_override("font_color", Color.WHITE)
	_explanation_label.add_theme_font_override("font", preload("res://fonts/Movery.ttf"))
	_explanation_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_explanation_label.offset_left = 16
	_explanation_label.offset_top = 12
	_explanation_label.offset_right = -16
	_explanation_label.offset_bottom = -12
	_explanation_panel.add_child(_explanation_label)

func _make_mask_panel(panel_name: String) -> ColorRect:
	var panel := ColorRect.new()
	panel.name = panel_name
	panel.color = Color(0, 0, 0, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_mask_gui_input)
	_tutorial_overlay.add_child(panel)
	return panel

func _on_mask_gui_input(event: InputEvent) -> void:
	if not _click_to_advance:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tutorial_click_advanced.emit()

# =========================================================
# OVERLAY POSITIONING
# =========================================================
func _set_mask_full_block() -> void:
	var vp := get_viewport().get_visible_rect().size
	_mask_top.position = Vector2.ZERO
	_mask_top.size = vp
	_mask_bottom.size = Vector2.ZERO
	_mask_left.size = Vector2.ZERO
	_mask_right.size = Vector2.ZERO

func _set_mask_gap(gap: Rect2) -> void:
	var vp := get_viewport().get_visible_rect().size

	_mask_top.position = Vector2.ZERO
	_mask_top.size = Vector2(vp.x, max(gap.position.y, 0.0))

	var bottom_y: float = gap.position.y + gap.size.y
	_mask_bottom.position = Vector2(0, bottom_y)
	_mask_bottom.size = Vector2(vp.x, max(vp.y - bottom_y, 0.0))

	_mask_left.position = Vector2(0, gap.position.y)
	_mask_left.size = Vector2(max(gap.position.x, 0.0), gap.size.y)

	var right_x: float = gap.position.x + gap.size.x
	_mask_right.position = Vector2(right_x, gap.position.y)
	_mask_right.size = Vector2(max(vp.x - right_x, 0.0), gap.size.y)

func _position_overlay(target_rect: Rect2, text: String) -> void:
	var vp := get_viewport().get_visible_rect().size

	var center_uv: Vector2 = (target_rect.position + target_rect.size / 2.0) / vp
	var size_uv: Vector2 = target_rect.size / vp
	_dim_material.set_shader_parameter("highlight_center", center_uv)
	_dim_material.set_shader_parameter("highlight_size", size_uv)
	_dim_material.set_shader_parameter("highlight_enabled", 1.0)

	_explanation_label.text = text
	_explanation_panel.size = EXPLANATION_BOX_SIZE
	_explanation_panel.show()

	var target_center_y: float = target_rect.position.y + target_rect.size.y / 2.0
	var box_pos := Vector2(target_rect.position.x + target_rect.size.x / 2.0 - EXPLANATION_BOX_SIZE.x / 2.0, 0)
	if target_center_y < vp.y / 2.0:
		box_pos.y = target_rect.position.y + target_rect.size.y + BOX_MARGIN
	else:
		box_pos.y = target_rect.position.y - EXPLANATION_BOX_SIZE.y - BOX_MARGIN

	box_pos.x = clamp(box_pos.x, BOX_MARGIN, vp.x - EXPLANATION_BOX_SIZE.x - BOX_MARGIN)
	box_pos.y = clamp(box_pos.y, BOX_MARGIN, vp.y - EXPLANATION_BOX_SIZE.y - BOX_MARGIN)

	_explanation_panel.position = box_pos
