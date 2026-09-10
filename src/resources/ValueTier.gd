class_name ValueTier
extends Resource
## One score band of a value (e.g. 4–6 = "Wachsam mit Augenmaß").

@export var min_score: int = 0
@export var max_score: int = 0
@export var state_name: String = ""
@export_multiline var description: String = ""


func contains(score: int) -> bool:
	return score >= min_score and score <= max_score
