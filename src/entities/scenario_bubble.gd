class_name ScenarioBubble
extends PanelContainer
## Speech bubble showing who is talking, the scenario title and the spoken text.

@onready var _sender_label: Label = %SenderLabel
@onready var _title_label: Label = %TitleLabel
@onready var _body_label: Label = %BodyLabel


func show_scenario(scenario: ScenarioData) -> void:
	_sender_label.text = _heading_for(scenario)
	_title_label.text = scenario.title
	_body_label.text = scenario.body_text
	var base_style: StyleBoxFlat = get_theme_stylebox("panel", "BubblePanel") as StyleBoxFlat
	if base_style != null and scenario.character != null:
		var style: StyleBoxFlat = base_style.duplicate() as StyleBoxFlat
		style.border_color = scenario.character.accent_color
		add_theme_stylebox_override("panel", style)
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.35).set_ease(Tween.EASE_OUT)


func _heading_for(scenario: ScenarioData) -> String:
	if scenario.sender_label != "":
		return scenario.sender_label
	var name: String = scenario.character.display_name if scenario.character != null else "Jemand"
	match scenario.channel:
		ScenarioData.Channel.SMS:
			return "SMS von %s" % name
		ScenarioData.Channel.CALL:
			return "Anruf von %s" % name
		ScenarioData.Channel.EMAIL:
			return "E-Mail von %s" % name
	return "%s sagt:" % name
