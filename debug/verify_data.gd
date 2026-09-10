extends SceneTree
## Headless data integrity check. Run:  godot --headless --path . --script debug/verify_data.gd
## Does not rely on autoloads.

const CATALOG_PATH: String = "res://src/resources/data/game_catalog.tres"
const EXPECTED_SCENARIOS: int = 50
const EXPECTED_CHARACTERS: int = 8
const DECK_TRIALS: int = 300

var _failures: int = 0


func _init() -> void:
	var catalog: GameCatalog = load(CATALOG_PATH) as GameCatalog
	_check(catalog != null, "catalog loads")
	if catalog == null:
		_finish()
		return
	_check(catalog.config != null, "config present")
	_check(catalog.values.size() == 4, "4 value definitions (got %d)" % catalog.values.size())
	_check(catalog.characters.size() == EXPECTED_CHARACTERS, "%d characters (got %d)" % [EXPECTED_CHARACTERS, catalog.characters.size()])
	_check(catalog.scenarios.size() == EXPECTED_SCENARIOS, "%d scenarios (got %d)" % [EXPECTED_SCENARIOS, catalog.scenarios.size()])

	for definition: ValueDefinition in catalog.values:
		_check(definition.icon != null, "value %s has icon" % definition.id)
		for score: int in range(0, 11):
			_check(definition.tier_for(score) != null, "value %s tier covers score %d" % [definition.id, score])

	var per_character: Dictionary = {}
	var ids: Dictionary = {}
	for character: CharacterData in catalog.characters:
		_check(character.portrait != null, "character %s has portrait" % character.id)
		_check(character.display_name != "", "character %s has name" % character.id)
	for scenario: ScenarioData in catalog.scenarios:
		_check(not ids.has(scenario.id), "scenario id unique: %s" % scenario.id)
		ids[scenario.id] = true
		_check(scenario.character != null, "scenario %s has character" % scenario.id)
		_check(scenario.body_text.length() > 20, "scenario %s has body" % scenario.id)
		for choice: ChoiceData in [scenario.choice_a, scenario.choice_b]:
			_check(choice != null and choice.label != "" and choice.outcome_text != "", "scenario %s choice complete" % scenario.id)
			_check(choice != null and choice.delta != null and not choice.delta.is_empty(), "scenario %s choice has a value change" % scenario.id)
		if scenario.character != null:
			per_character[scenario.character.id] = int(per_character.get(scenario.character.id, 0)) + 1
	for scenario: ScenarioData in catalog.scenarios:
		if scenario.follows != &"":
			_check(ids.has(scenario.follows), "scenario %s follows existing %s" % [scenario.id, scenario.follows])
	print("scenarios per character: %s" % per_character)

	# Deck builder: right size, unique, no consecutive repeats, prerequisites respected, broad spread.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 12345
	var min_distinct: int = 99
	var consecutive_failures: int = 0
	var follow_failures: int = 0
	var by_id: Dictionary = {}
	for scenario: ScenarioData in catalog.scenarios:
		by_id[scenario.id] = scenario
	for trial: int in DECK_TRIALS:
		var deck: Array[StringName] = DeckBuilder.build(catalog.scenarios, catalog.config.max_rounds, true, rng)
		_check(deck.size() == catalog.config.max_rounds, "deck size %d" % deck.size())
		var seen: Dictionary = {}
		var characters: Dictionary = {}
		var last: StringName = &""
		for scenario_id: StringName in deck:
			_check(not seen.has(scenario_id), "deck has no duplicate %s" % scenario_id)
			var scenario: ScenarioData = by_id[scenario_id]
			if scenario.follows != &"" and not seen.has(scenario.follows):
				follow_failures += 1
			seen[scenario_id] = true
			if scenario.character.id == last:
				consecutive_failures += 1
			last = scenario.character.id
			characters[scenario.character.id] = true
		min_distinct = mini(min_distinct, characters.size())
	_check(consecutive_failures == 0, "no consecutive same-character rounds (%d violations in %d decks)" % [consecutive_failures, DECK_TRIALS])
	_check(follow_failures == 0, "follow-up scenarios only after their prerequisite (%d violations)" % follow_failures)
	_check(min_distinct >= 8, "every deck contains all 8 characters (min %d)" % min_distinct)
	_finish()


func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures += 1
		print("FAIL: %s" % label)


func _finish() -> void:
	if _failures == 0:
		print("VERIFY_OK")
	else:
		print("VERIFY_FAILED (%d failures)" % _failures)
	quit()
