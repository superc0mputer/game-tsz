class_name GameConfig
extends Resource
## Tunable rules of a run.

@export_range(1, 50) var max_rounds: int = 10
@export_range(0, 10) var start_value: int = 5
@export var min_value: int = 0
@export var max_value: int = 10
## End the run early as soon as any value reaches min_value or max_value (like the reference game).
@export var end_on_extreme: bool = true
## Try not to show the same character in two consecutive rounds.
@export var avoid_consecutive_character: bool = true
