class_name OutcomePanel
extends Control
## Overlay that explains what happened after a choice and shows which values moved.

signal continue_pressed

const OUTCOME_ROW_SCENE: PackedScene = preload("res://src/components/outcome_row.tscn")

@onready var _dim: ColorRect = %Dim
@onready var _panel: PanelContainer = %Panel
@onready var _portrait: TextureRect = %Portrait
@onready var _name_label: Label = %NameLabel
@onready var _choice_label: Label = %ChoiceLabel
@onready var _outcome_label: Label = %OutcomeLabel
@onready var _changes: VBoxContainer = %Changes
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	hide()
	_continue_button.pressed.connect(_on_continue_pressed)
	_panel.resized.connect(func() -> void: _panel.pivot_offset = _panel.size / 2.0)


func show_outcome(scenario: ScenarioData, is_a: bool, old_values: Dictionary, new_values: Dictionary) -> void:
	var character: CharacterData = scenario.character
	var choice: ChoiceData = scenario.get_choice(is_a)
	_portrait.texture = character.portrait if character != null else null
	_name_label.text = character.display_name if character != null else ""
	_choice_label.text = "Deine Antwort: %s" % choice.label
	_outcome_label.text = choice.outcome_text
	for child: Node in _changes.get_children():
		child.queue_free()
	var max_value: int = ScenarioLibrary.config.max_value
	var any_change: bool = false
	for definition: ValueDefinition in ScenarioLibrary.value_definitions:
		var old_value: int = int(old_values.get(definition.id, 0))
		var new_value: int = int(new_values.get(definition.id, 0))
		if old_value == new_value:
			continue
		any_change = true
		var row: OutcomeRow = OUTCOME_ROW_SCENE.instantiate() as OutcomeRow
		_changes.add_child(row)
		row.setup(definition, old_value, new_value, max_value)
	if not any_change:
		var label: Label = Label.new()
		label.text = "Deine Werte bleiben unverändert."
		label.theme_type_variation = &"Muted"
		_changes.add_child(label)
	show()
	_dim.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_panel.scale = Vector2(0.94, 0.94)
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_dim, "modulate", Color.WHITE, 0.25)
	tween.tween_property(_panel, "modulate", Color.WHITE, 0.3)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.35)
	_continue_button.grab_focus()


func hide_panel() -> void:
	hide()


func _on_continue_pressed() -> void:
	continue_pressed.emit()
