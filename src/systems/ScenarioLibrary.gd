extends Node
## Loads the GameCatalog once and offers typed lookups. Autoload: ScenarioLibrary.

const CATALOG_PATH: String = "res://src/resources/data/game_catalog.tres"

var catalog: GameCatalog
var config: GameConfig
var value_definitions: Array[ValueDefinition] = []
var _scenarios_by_id: Dictionary = {}
var _characters_by_id: Dictionary = {}
var _values_by_id: Dictionary = {}


func _ready() -> void:
	catalog = load(CATALOG_PATH) as GameCatalog
	if catalog == null:
		push_error("ScenarioLibrary: could not load catalog at %s" % CATALOG_PATH)
		return
	config = catalog.config
	value_definitions = catalog.values
	for definition: ValueDefinition in catalog.values:
		_values_by_id[definition.id] = definition
	for character: CharacterData in catalog.characters:
		_characters_by_id[character.id] = character
	for scenario: ScenarioData in catalog.scenarios:
		_scenarios_by_id[scenario.id] = scenario


func get_all_scenarios() -> Array[ScenarioData]:
	return catalog.scenarios


func get_scenario(scenario_id: StringName) -> ScenarioData:
	return _scenarios_by_id.get(scenario_id) as ScenarioData


func get_character(character_id: StringName) -> CharacterData:
	return _characters_by_id.get(character_id) as CharacterData


func get_value_definition(value_id: StringName) -> ValueDefinition:
	return _values_by_id.get(value_id) as ValueDefinition


func get_value_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for definition: ValueDefinition in value_definitions:
		ids.append(definition.id)
	return ids


func tier_for(value_id: StringName, score: int) -> ValueTier:
	var definition: ValueDefinition = get_value_definition(value_id)
	return definition.tier_for(score) if definition != null else null
