extends State
## Shows the outcome panel and waits for "Weiter".

var _ctx: GameContext


func setup(new_context: Object) -> void:
	super(new_context)
	_ctx = new_context as GameContext


func enter(data: Dictionary = {}) -> void:
	var scenario: ScenarioData = data.get("scenario") as ScenarioData
	var is_a: bool = bool(data.get("is_a", true))
	var old_values: Dictionary = data.get("old", {})
	var new_values: Dictionary = data.get("new", {})
	var net: int = 0
	for value_id: Variant in new_values.keys():
		net += int(new_values[value_id]) - int(old_values.get(value_id, new_values[value_id]))
	AudioManager.play(&"positive" if net >= 0 else &"negative")
	_ctx.outcome_panel.continue_pressed.connect(_on_continue_pressed)
	_ctx.outcome_panel.show_outcome(scenario, is_a, old_values, new_values)


func exit() -> void:
	if _ctx.outcome_panel.continue_pressed.is_connected(_on_continue_pressed):
		_ctx.outcome_panel.continue_pressed.disconnect(_on_continue_pressed)


func _on_continue_pressed() -> void:
	AudioManager.play(&"click")
	match GameState.finish_round():
		GameState.RoundResult.CONTINUE:
			request_transition(&"Deal")
		GameState.RoundResult.COMPLETED:
			request_transition(&"End", {"completed": true})
		GameState.RoundResult.EXTREME_REACHED:
			request_transition(&"End", {"completed": false})
