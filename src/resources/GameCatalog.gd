class_name GameCatalog
extends Resource
## Single entry point to all game data so nothing has to be discovered by scanning directories.

@export var config: GameConfig
@export var values: Array[ValueDefinition] = []
@export var characters: Array[CharacterData] = []
@export var scenarios: Array[ScenarioData] = []
