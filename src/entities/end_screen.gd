class_name EndScreen
extends Control
## Final evaluation: one summary card per value plus restart / menu buttons.

signal restart_pressed
signal menu_pressed

const VALUE_SUMMARY_SCENE: PackedScene = preload("res://src/entities/value_summary.tscn")

@onready var _title_label: Label = %TitleLabel
@onready var _subtitle_label: Label = %SubtitleLabel
@onready var _grid: GridContainer = %Grid
@onready var _restart_button: Button = %RestartButton
@onready var _menu_button: Button = %MenuButton


func _ready() -> void:
	hide()
	_restart_button.pressed.connect(func() -> void: restart_pressed.emit())
	_menu_button.pressed.connect(func() -> void: menu_pressed.emit())


func show_results(values: Dictionary, completed: bool, extreme_value: StringName, rounds_played: int) -> void:
	var config: GameConfig = ScenarioLibrary.config
	if completed:
		_title_label.text = "Geschafft!"
		_subtitle_label.text = "Nach %d Runden sieht dein digitaler Alltag so aus:" % rounds_played
	else:
		var definition: ValueDefinition = ScenarioLibrary.get_value_definition(extreme_value)
		var name: String = definition.display_name if definition != null else String(extreme_value)
		_title_label.text = "Das Spiel endet vorzeitig"
		_subtitle_label.text = "Dein Wert „%s“ hat %d erreicht. So sieht dein digitaler Alltag nach %d Runden aus:" % [name, int(values.get(extreme_value, 0)), rounds_played]
	for child: Node in _grid.get_children():
		child.queue_free()
	for definition: ValueDefinition in ScenarioLibrary.value_definitions:
		var summary: ValueSummary = VALUE_SUMMARY_SCENE.instantiate() as ValueSummary
		_grid.add_child(summary)
		var score: int = int(values.get(definition.id, 0))
		summary.setup(definition, score, config.max_value, definition.id == extreme_value)
	show()
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.4).set_ease(Tween.EASE_OUT)
	_restart_button.grab_focus()
