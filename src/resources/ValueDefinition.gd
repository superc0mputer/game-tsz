class_name ValueDefinition
extends Resource
## Describes one of the four player values (name, colour, icon, score tiers).

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var focus: String = ""
@export var color: Color = Color.WHITE
@export var icon: Texture2D
@export var tiers: Array[ValueTier] = []


func tier_for(score: int) -> ValueTier:
	for tier: ValueTier in tiers:
		if tier.contains(score):
			return tier
	return null
