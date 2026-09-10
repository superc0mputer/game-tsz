class_name ValueDelta
extends Resource
## Change applied to the four values by a choice.

const VALUE_IDS: Array[StringName] = [&"selbststaendigkeit", &"sicherheit", &"verbundenheit", &"entlastung"]

@export var selbststaendigkeit: int = 0
@export var sicherheit: int = 0
@export var verbundenheit: int = 0
@export var entlastung: int = 0


func get_delta(value_id: StringName) -> int:
	match value_id:
		&"selbststaendigkeit":
			return selbststaendigkeit
		&"sicherheit":
			return sicherheit
		&"verbundenheit":
			return verbundenheit
		&"entlastung":
			return entlastung
	return 0


func to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	for value_id: StringName in VALUE_IDS:
		result[value_id] = get_delta(value_id)
	return result


func is_empty() -> bool:
	return selbststaendigkeit == 0 and sicherheit == 0 and verbundenheit == 0 and entlastung == 0


func net_change() -> int:
	return selbststaendigkeit + sicherheit + verbundenheit + entlastung
