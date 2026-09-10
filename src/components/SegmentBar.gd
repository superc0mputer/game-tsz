class_name SegmentBar
extends Control
## Draws a 0..N segment bar. Supports a live preview (green gain with "+", red loss with "-")
## and an old→new transition display used on the outcome panel.

const GAIN_COLOR: Color = Color(0.18, 0.62, 0.36, 1.0)
const LOSS_COLOR: Color = Color(0.83, 0.25, 0.22, 1.0)
const EMPTY_ALPHA: float = 0.16
const GLYPH_COLOR: Color = Color(1.0, 1.0, 1.0, 0.95)

@export var segment_count: int = 10
@export var fill_color: Color = Color(0.3, 0.5, 0.8, 1.0)
@export var gap: float = 4.0
@export var corner_radius: int = 4

var _current: int = 0
var _preview_delta: int = 0
var _transition_from: int = -1
var _style: StyleBoxFlat = StyleBoxFlat.new()


func _ready() -> void:
	if custom_minimum_size.y < 12.0:
		custom_minimum_size.y = 16.0
	_style.set_corner_radius_all(corner_radius)
	resized.connect(queue_redraw)


func set_value(value: int) -> void:
	_current = value
	_transition_from = -1
	queue_redraw()


func get_value() -> int:
	return _current


func set_preview(delta: int) -> void:
	_preview_delta = delta
	queue_redraw()


func clear_preview() -> void:
	set_preview(0)


func set_transition(old_value: int, new_value: int) -> void:
	_transition_from = old_value
	_current = new_value
	_preview_delta = 0
	queue_redraw()


func _draw() -> void:
	var count: int = maxi(segment_count, 1)
	var segment_width: float = (size.x - gap * (count - 1)) / count
	for i: int in count:
		var index: int = i + 1
		var change: int = _change_for_segment(index)
		var rect: Rect2 = Rect2(i * (segment_width + gap), 0.0, segment_width, size.y)
		_style.bg_color = _color_for_segment(index, change)
		_style.draw(get_canvas_item(), rect)
		if change > 0:
			_draw_plus(rect)
		elif change < 0:
			_draw_minus(rect)


## +1 for a segment that would be / was gained, -1 for one that would be / was lost, 0 otherwise.
func _change_for_segment(index: int) -> int:
	if _transition_from >= 0:
		var low: int = mini(_transition_from, _current)
		var high: int = maxi(_transition_from, _current)
		if index > low and index <= high:
			return 1 if _current > _transition_from else -1
		return 0
	var target: int = clampi(_current + _preview_delta, 0, maxi(segment_count, 1))
	if _preview_delta > 0 and index > _current and index <= target:
		return 1
	if _preview_delta < 0 and index > target and index <= _current:
		return -1
	return 0


func _color_for_segment(index: int, change: int) -> Color:
	if change > 0:
		return GAIN_COLOR
	if change < 0:
		return LOSS_COLOR
	var filled: int = mini(_transition_from, _current) if _transition_from >= 0 else _current
	if index <= filled:
		return fill_color
	return Color(fill_color.r, fill_color.g, fill_color.b, EMPTY_ALPHA)


func _draw_plus(rect: Rect2) -> void:
	var center: Vector2 = rect.get_center()
	var arm: float = minf(rect.size.x, rect.size.y) * 0.28
	var thickness: float = maxf(2.0, rect.size.y * 0.14)
	draw_rect(Rect2(center.x - arm, center.y - thickness / 2.0, arm * 2.0, thickness), GLYPH_COLOR)
	draw_rect(Rect2(center.x - thickness / 2.0, center.y - arm, thickness, arm * 2.0), GLYPH_COLOR)


func _draw_minus(rect: Rect2) -> void:
	var center: Vector2 = rect.get_center()
	var arm: float = minf(rect.size.x, rect.size.y) * 0.28
	var thickness: float = maxf(2.0, rect.size.y * 0.14)
	draw_rect(Rect2(center.x - arm, center.y - thickness / 2.0, arm * 2.0, thickness), GLYPH_COLOR)
