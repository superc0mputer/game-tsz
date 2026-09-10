class_name CharacterData
extends Resource
## A person from the player's surroundings who brings scenarios to the table.

@export var id: StringName = &""
@export var display_name: String = ""
@export var tagline: String = ""
@export var age_text: String = ""
@export var role_text: String = ""
@export_multiline var description: String = ""
@export_multiline var strengths: String = ""
@export_multiline var weaknesses: String = ""
@export var portrait: Texture2D
@export var accent_color: Color = Color.WHITE
## True when the character addresses the player formally ("Sie").
@export var formal_address: bool = false
