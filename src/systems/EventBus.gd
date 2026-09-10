extends Node
## Global signal hub for cross-branch communication. Autoload: EventBus.

signal game_started
signal round_started(round_index: int, scenario: ScenarioData)
signal value_changed(value_id: StringName, old_value: int, new_value: int)
signal values_reset(values: Dictionary)
signal preview_requested(delta: ValueDelta)
signal preview_cleared
signal choice_applied(scenario: ScenarioData, is_a: bool, old_values: Dictionary, new_values: Dictionary)
signal game_ended(completed: bool, values: Dictionary)
