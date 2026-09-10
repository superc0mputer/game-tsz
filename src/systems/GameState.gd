extends Node
## Holds the state of the current run and persists it as JSON. Autoload: GameState.

enum RoundResult { CONTINUE, COMPLETED, EXTREME_REACHED }

const SAVE_PATH: String = "user://vita_save.json"
const SAVE_VERSION: int = 1

var values: Dictionary = {}
var deck: Array[StringName] = []
var history: Array[Dictionary] = []
var round_index: int = 0
var current_scenario_id: StringName = &""
var is_active: bool = false
var ended_by_extreme: StringName = &""

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func get_config() -> GameConfig:
	return ScenarioLibrary.config


func start_new_game() -> void:
	var config: GameConfig = get_config()
	values.clear()
	for value_id: StringName in ScenarioLibrary.get_value_ids():
		values[value_id] = config.start_value
	deck = DeckBuilder.build(ScenarioLibrary.get_all_scenarios(), config.max_rounds, config.avoid_consecutive_character, _rng)
	history.clear()
	round_index = 0
	current_scenario_id = &""
	ended_by_extreme = &""
	is_active = true
	EventBus.values_reset.emit(values.duplicate())
	EventBus.game_started.emit()


func has_current_scenario() -> bool:
	return current_scenario_id != &""


func get_current_scenario() -> ScenarioData:
	return ScenarioLibrary.get_scenario(current_scenario_id) if has_current_scenario() else null


## Returns the scenario for this round, drawing a new one from the deck when needed.
func current_or_draw() -> ScenarioData:
	if has_current_scenario():
		return get_current_scenario()
	if deck.is_empty():
		return null
	current_scenario_id = deck.pop_front()
	return get_current_scenario()


func get_value(value_id: StringName) -> int:
	return int(values.get(value_id, 0))


func preview_delta(is_a: bool) -> ValueDelta:
	var scenario: ScenarioData = get_current_scenario()
	if scenario == null:
		return null
	return scenario.get_choice(is_a).delta


## Applies the chosen answer. Returns {"old": Dictionary, "new": Dictionary, "is_a": bool, "scenario": ScenarioData}.
func apply_choice(is_a: bool) -> Dictionary:
	var scenario: ScenarioData = get_current_scenario()
	assert(scenario != null, "apply_choice called without a current scenario")
	var config: GameConfig = get_config()
	var choice: ChoiceData = scenario.get_choice(is_a)
	var old_values: Dictionary = values.duplicate()
	for value_id: StringName in values.keys():
		var old_value: int = values[value_id]
		var new_value: int = clampi(old_value + choice.delta.get_delta(value_id), config.min_value, config.max_value)
		values[value_id] = new_value
		if new_value != old_value:
			EventBus.value_changed.emit(value_id, old_value, new_value)
	history.append({"scenario_id": String(scenario.id), "is_a": is_a})
	EventBus.choice_applied.emit(scenario, is_a, old_values, values.duplicate())
	return {"old": old_values, "new": values.duplicate(), "is_a": is_a, "scenario": scenario}


## Closes the current round and reports whether the run continues.
func finish_round() -> RoundResult:
	var config: GameConfig = get_config()
	current_scenario_id = &""
	round_index += 1
	if config.end_on_extreme:
		for value_id: StringName in values.keys():
			var value: int = values[value_id]
			if value <= config.min_value or value >= config.max_value:
				ended_by_extreme = value_id
				is_active = false
				EventBus.game_ended.emit(false, values.duplicate())
				return RoundResult.EXTREME_REACHED
	if round_index >= config.max_rounds or deck.is_empty():
		is_active = false
		EventBus.game_ended.emit(true, values.duplicate())
		return RoundResult.COMPLETED
	return RoundResult.CONTINUE


func rounds_total() -> int:
	return get_config().max_rounds


# ---------------------------------------------------------------- persistence

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


func save_game() -> void:
	if not is_active:
		return
	var deck_strings: Array[String] = []
	for scenario_id: StringName in deck:
		deck_strings.append(String(scenario_id))
	var values_strings: Dictionary = {}
	for value_id: StringName in values.keys():
		values_strings[String(value_id)] = values[value_id]
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"values": values_strings,
		"deck": deck_strings,
		"history": history,
		"round_index": round_index,
		"current_scenario_id": String(current_scenario_id),
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: cannot write save file (%s)" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_game() -> bool:
	if not has_save():
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return false
	var data: Dictionary = parsed
	if int(data.get("version", 0)) != SAVE_VERSION:
		return false
	values.clear()
	var saved_values: Dictionary = data.get("values", {})
	for value_id: StringName in ScenarioLibrary.get_value_ids():
		values[value_id] = int(saved_values.get(String(value_id), get_config().start_value))
	deck.clear()
	for scenario_id: Variant in data.get("deck", []):
		if ScenarioLibrary.get_scenario(StringName(String(scenario_id))) != null:
			deck.append(StringName(String(scenario_id)))
	history.clear()
	for entry: Variant in data.get("history", []):
		if entry is Dictionary:
			history.append(entry)
	round_index = int(data.get("round_index", 0))
	var saved_current: String = String(data.get("current_scenario_id", ""))
	current_scenario_id = StringName(saved_current) if ScenarioLibrary.get_scenario(StringName(saved_current)) != null else &""
	ended_by_extreme = &""
	is_active = true
	EventBus.values_reset.emit(values.duplicate())
	return true
