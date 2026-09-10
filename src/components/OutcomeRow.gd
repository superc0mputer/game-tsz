class_name OutcomeRow
extends HBoxContainer
## A single "value went from X to Y" line inside the outcome panel.

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _bar: SegmentBar = %Bar
@onready var _change_label: Label = %ChangeLabel


func setup(definition: ValueDefinition, old_value: int, new_value: int, max_value: int) -> void:
	_icon.texture = definition.icon
	_icon.modulate = definition.color
	_name_label.text = definition.display_name
	_bar.fill_color = definition.color
	_bar.segment_count = max_value
	_bar.set_transition(old_value, new_value)
	var difference: int = new_value - old_value
	var sign_text: String = ("+%d" % difference) if difference > 0 else str(difference)
	_change_label.text = "von %d auf %d (%s)" % [old_value, new_value, sign_text]
	_change_label.add_theme_color_override("font_color", SegmentBar.GAIN_COLOR if difference > 0 else SegmentBar.LOSS_COLOR)
