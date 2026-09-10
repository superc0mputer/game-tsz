class_name ValueSummary
extends PanelContainer
## End-screen card for one value: score, tier name and its description.

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _bar: SegmentBar = %Bar
@onready var _state_label: Label = %StateLabel
@onready var _description_label: Label = %DescriptionLabel


func setup(definition: ValueDefinition, score: int, max_value: int, is_extreme: bool) -> void:
	_icon.texture = definition.icon
	_icon.modulate = definition.color
	_name_label.text = definition.display_name
	_score_label.text = "%d / %d" % [score, max_value]
	_bar.fill_color = definition.color
	_bar.segment_count = max_value
	_bar.set_value(score)
	var tier: ValueTier = definition.tier_for(score)
	_state_label.text = tier.state_name if tier != null else ""
	_state_label.add_theme_color_override("font_color", SegmentBar.LOSS_COLOR if is_extreme else definition.color)
	_description_label.text = tier.description if tier != null else ""
