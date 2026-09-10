class_name ScenarioCard
extends Control
## The draggable character card. Forwards input to its SwipeComponent and animates its Body.

signal drag_ratio_changed(ratio: float)
signal choice_committed(is_a: bool)

const CHANNEL_ICONS: Dictionary = {
	ScenarioData.Channel.TALK: preload("res://assets/sprites/icons/channel_talk.svg"),
	ScenarioData.Channel.SMS: preload("res://assets/sprites/icons/channel_sms.svg"),
	ScenarioData.Channel.CALL: preload("res://assets/sprites/icons/channel_call.svg"),
	ScenarioData.Channel.EMAIL: preload("res://assets/sprites/icons/channel_mail.svg"),
}
const CHANNEL_LABELS: Dictionary = {
	ScenarioData.Channel.TALK: "Im Gespräch",
	ScenarioData.Channel.SMS: "SMS",
	ScenarioData.Channel.CALL: "Anruf",
	ScenarioData.Channel.EMAIL: "E-Mail",
}
const ROTATION_PER_PIXEL: float = 0.05
const FLY_DISTANCE: float = 900.0

@onready var _swipe: SwipeComponent = $SwipeComponent
@onready var _body: PanelContainer = %Body
@onready var _portrait: TextureRect = %Portrait
@onready var _name_label: Label = %NameLabel
@onready var _role_label: Label = %RoleLabel
@onready var _chip: PanelContainer = %Chip
@onready var _channel_icon: TextureRect = %ChannelIcon
@onready var _channel_label: Label = %ChannelLabel

var _rest_position: Vector2 = Vector2.ZERO
var _interactive: bool = false
var _animating: bool = false
var _snap_tween: Tween


func _ready() -> void:
	_body.resized.connect(_on_body_resized)
	resized.connect(_sync_body_size)
	_sync_body_size()
	_swipe.drag_updated.connect(_on_drag_updated)
	_swipe.drag_released.connect(_on_drag_released)
	_swipe.swipe_committed.connect(_on_swipe_committed)
	set_interactive(false)


func show_scenario(scenario: ScenarioData) -> void:
	var character: CharacterData = scenario.character
	_portrait.texture = character.portrait
	_name_label.text = character.display_name
	_role_label.text = character.tagline
	_channel_icon.texture = CHANNEL_ICONS.get(scenario.channel)
	_channel_label.text = CHANNEL_LABELS.get(scenario.channel, "")
	_apply_accent(character.accent_color)
	_reset_transform()
	# Labels may report a temporary oversized minimum before their first layout pass; re-sync after it.
	_sync_body_size.call_deferred()


func set_interactive(enabled: bool) -> void:
	_interactive = enabled
	_swipe.enabled = enabled
	if not enabled:
		_swipe.cancel()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW


## Animates the card into view. Awaitable.
func deal_in() -> void:
	_sync_body_size()
	_animating = true
	_kill_snap()
	_body.position = _rest_position + Vector2(0.0, 70.0)
	_body.rotation_degrees = 0.0
	_body.scale = Vector2(0.9, 0.9)
	_body.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_body, "position", _rest_position, 0.45)
	tween.tween_property(_body, "scale", Vector2.ONE, 0.45)
	tween.tween_property(_body, "modulate", Color.WHITE, 0.3)
	await tween.finished
	_animating = false


## Animates the card off screen towards direction (-1 left, +1 right). Awaitable.
func fly_out(direction: int) -> void:
	_animating = true
	_kill_snap()
	var target: Vector2 = _rest_position + Vector2(direction * FLY_DISTANCE, -40.0)
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_body, "position", target, 0.4)
	tween.tween_property(_body, "rotation_degrees", direction * 28.0, 0.4)
	tween.tween_property(_body, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.35)
	await tween.finished
	_animating = false


func _gui_input(event: InputEvent) -> void:
	if _interactive and not _animating:
		_swipe.handle_input(event)


func _on_drag_updated(offset: Vector2) -> void:
	_kill_snap()
	var clamped: Vector2 = _swipe.clamped_offset(offset)
	_body.position = _rest_position + clamped
	_body.rotation_degrees = clamped.x * ROTATION_PER_PIXEL
	drag_ratio_changed.emit(_swipe.progress_from(offset))


func _on_drag_released(_offset: Vector2) -> void:
	_kill_snap()
	_snap_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_snap_tween.tween_property(_body, "position", _rest_position, 0.3)
	_snap_tween.tween_property(_body, "rotation_degrees", 0.0, 0.3)
	drag_ratio_changed.emit(0.0)


func _on_swipe_committed(direction: int) -> void:
	drag_ratio_changed.emit(float(direction))
	choice_committed.emit(direction < 0)


func _apply_accent(accent: Color) -> void:
	var base_style: StyleBoxFlat = get_theme_stylebox("panel", "CardPanel") as StyleBoxFlat
	if base_style != null:
		var style: StyleBoxFlat = base_style.duplicate() as StyleBoxFlat
		style.border_color = accent
		style.shadow_color = Color(accent.r, accent.g, accent.b, 0.28)
		_body.add_theme_stylebox_override("panel", style)
	var chip_base: StyleBoxFlat = get_theme_stylebox("panel", "ChipPanel") as StyleBoxFlat
	if chip_base != null:
		var chip_style: StyleBoxFlat = chip_base.duplicate() as StyleBoxFlat
		chip_style.bg_color = accent
		_chip.add_theme_stylebox_override("panel", chip_style)


func _reset_transform() -> void:
	_kill_snap()
	_body.position = _rest_position
	_body.rotation_degrees = 0.0
	_body.scale = Vector2.ONE
	_body.modulate = Color.WHITE


func _kill_snap() -> void:
	if _snap_tween != null and _snap_tween.is_valid():
		_snap_tween.kill()
	_snap_tween = null


func _on_body_resized() -> void:
	_body.pivot_offset = _body.size / 2.0


## The Body is deliberately unanchored (position is animated), so its size follows the card explicitly.
func _sync_body_size() -> void:
	_body.size = size
	if not _animating and not _swipe.is_dragging():
		_body.position = _rest_position
