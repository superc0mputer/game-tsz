class_name OptionPanel
extends PanelContainer
## One of the two answer panels beside the card. Clickable as an accessible alternative to swiping.

signal pressed

const ARROW_LEFT: Texture2D = preload("res://assets/sprites/icons/arrow_left.svg")
const ARROW_RIGHT: Texture2D = preload("res://assets/sprites/icons/arrow_right.svg")
const IDLE_ALPHA: float = 0.6

## -1 = left (answer A), +1 = right (answer B)
@export var side: int = -1

@onready var _hint_row: HBoxContainer = %HintRow
@onready var _arrow: TextureRect = %Arrow
@onready var _hint_label: Label = %HintLabel
@onready var _option_label: Label = %OptionLabel

var _highlight: float = 0.0
var _hovered: bool = false
var _enabled: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_arrow.texture = ARROW_LEFT if side < 0 else ARROW_RIGHT
	_hint_label.text = "Nach links ziehen" if side < 0 else "Nach rechts ziehen"
	if side > 0:
		_hint_row.move_child(_arrow, _hint_row.get_child_count() - 1)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_apply_visuals()


func set_option(text: String) -> void:
	_option_label.text = text


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
	_apply_visuals()


func set_highlight(amount: float) -> void:
	_highlight = clampf(amount, 0.0, 1.0)
	_apply_visuals()


func _apply_visuals() -> void:
	var base: float = IDLE_ALPHA
	if _hovered and _enabled:
		base = 0.85
	if not _enabled:
		base = 0.45
	modulate = Color(1.0, 1.0, 1.0, lerpf(base, 1.0, _highlight))


func _gui_input(event: InputEvent) -> void:
	if not _enabled:
		return
	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event
		if button_event.button_index == MOUSE_BUTTON_LEFT and not button_event.pressed:
			accept_event()
			pressed.emit()


func _on_mouse_entered() -> void:
	_hovered = true
	_apply_visuals()


func _on_mouse_exited() -> void:
	_hovered = false
	_apply_visuals()
