class_name SwipeComponent
extends Node
## Turns raw pointer input (forwarded by its owner) into drag offsets and swipe decisions.

signal drag_started
signal drag_updated(offset: Vector2)
signal drag_released(offset: Vector2)
signal swipe_committed(direction: int)

@export var threshold: float = 120.0
@export var max_distance: float = 280.0
@export var enabled: bool = true

var _dragging: bool = false
var _press_position: Vector2 = Vector2.ZERO
var _offset: Vector2 = Vector2.ZERO


func handle_input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event
		if button_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if button_event.pressed:
			_begin(button_event.global_position)
		elif _dragging:
			_end()
	elif event is InputEventMouseMotion and _dragging:
		_update((event as InputEventMouseMotion).global_position)


func cancel() -> void:
	if _dragging:
		_dragging = false
		_offset = Vector2.ZERO
		drag_released.emit(Vector2.ZERO)


func is_dragging() -> bool:
	return _dragging


## Progress towards the swipe threshold, -1..1 (negative = left).
func progress_from(offset: Vector2) -> float:
	return clampf(offset.x / threshold, -1.0, 1.0)


## Visual displacement clamped to max_distance.
func clamped_offset(offset: Vector2) -> Vector2:
	return Vector2(clampf(offset.x, -max_distance, max_distance), 0.0)


func _begin(global_position: Vector2) -> void:
	_dragging = true
	_press_position = global_position
	_offset = Vector2.ZERO
	drag_started.emit()


func _update(global_position: Vector2) -> void:
	_offset = global_position - _press_position
	drag_updated.emit(_offset)


func _end() -> void:
	_dragging = false
	var final_offset: Vector2 = _offset
	_offset = Vector2.ZERO
	if final_offset.x <= -threshold:
		swipe_committed.emit(-1)
	elif final_offset.x >= threshold:
		swipe_committed.emit(1)
	else:
		drag_released.emit(final_offset)
