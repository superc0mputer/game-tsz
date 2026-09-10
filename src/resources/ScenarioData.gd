class_name ScenarioData
extends Resource
## A single decision card: who speaks, what they say, and the two possible answers.

enum Channel { TALK, SMS, CALL, EMAIL }

@export var id: StringName = &""
@export var character: CharacterData
@export var title: String = ""
@export_multiline var body_text: String = ""
@export var channel: Channel = Channel.TALK
## Optional heading override, e.g. "Anruf von der 110". Empty = derived from character and channel.
@export var sender_label: String = ""
@export var choice_a: ChoiceData
@export var choice_b: ChoiceData
## Optional: id of a scenario that must have been played before this one.
@export var follows: StringName = &""


func get_choice(is_a: bool) -> ChoiceData:
	return choice_a if is_a else choice_b
