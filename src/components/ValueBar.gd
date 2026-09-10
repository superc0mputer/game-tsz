class_name ValueBar
extends PanelContainer
## One of the four value displays at the bottom of the game screen.
## Listens to the EventBus so nothing has to push values into it.

@export var value_id: StringName = &""

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _value_label: Label = %ValueLabel
@onready var _delta_label: Label = %DeltaLabel
@onready var _bar: SegmentBar = %Bar

var _definition: ValueDefinition
var _current: int = 0


func _ready() -> void:
	_definition = ScenarioLibrary.get_value_definition(value_id)
	if _definition != null:
		_icon.texture = _definition.icon
		_icon.modulate = _definition.color
		_name_label.text = _definition.display_name
		_bar.fill_color = _definition.color
	if ScenarioLibrary.config != null:
		_bar.segment_count = ScenarioLibrary.config.max_value
	_delta_label.text = ""
	EventBus.values_reset.connect(_on_values_reset)
	EventBus.value_changed.connect(_on_value_changed)
	EventBus.preview_requested.connect(_on_preview_requested)
	EventBus.preview_cleared.connect(_on_preview_cleared)
	_set_current(GameState.get_value(value_id))


func _set_current(value: int) -> void:
	_current = value
	_bar.set_value(value)
	_value_label.text = str(value)


func _on_values_reset(values: Dictionary) -> void:
	_set_current(int(values.get(value_id, 0)))
	_on_preview_cleared()


func _on_value_changed(changed_id: StringName, _old_value: int, new_value: int) -> void:
	if changed_id != value_id:
		return
	_set_current(new_value)
	_on_preview_cleared()
	var tween: Tween = create_tween()
	tween.tween_property(_value_label, "scale", Vector2(1.35, 1.35), 0.12).set_ease(Tween.EASE_OUT)
	tween.tween_property(_value_label, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_IN_OUT)
	_value_label.pivot_offset = _value_label.size / 2.0


func _on_preview_requested(delta: ValueDelta) -> void:
	if delta == null:
		_on_preview_cleared()
		return
	var change: int = delta.get_delta(value_id)
	var max_value: int = ScenarioLibrary.config.max_value if ScenarioLibrary.config != null else 10
	var effective: int = clampi(_current + change, 0, max_value) - _current
	_bar.set_preview(effective)
	if effective == 0:
		_delta_label.text = ""
	else:
		_delta_label.text = ("+%d" % effective) if effective > 0 else str(effective)
		_delta_label.add_theme_color_override("font_color", SegmentBar.GAIN_COLOR if effective > 0 else SegmentBar.LOSS_COLOR)


func _on_preview_cleared() -> void:
	_bar.clear_preview()
	_delta_label.text = ""
