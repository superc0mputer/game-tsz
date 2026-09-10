extends Control
## Short text introduction (replaces the reference game's intro video).

const GAME_SCENE: String = "res://src/scenes/game.tscn"
const PAGES: Array[Dictionary] = [
	{
		"title": "Willkommen bei VITA",
		"body": "Du lebst selbstständig in deiner Wohnung. Dein Alltag wird immer digitaler: Nachrichten, Termine, Bankgeschäfte, Pakete.\n\nMenschen aus deinem Umfeld kommen mit Fragen, Angeboten und Bitten auf dich zu – deine Tochter Silke, dein Mann Gerhard, dein Enkel Noah, deine Freundin Hildegard, deine Alltagsbegleitung Jana, der Postbote, der Polizist und die Bankmitarbeiterin.\n\nManchmal meldet sich auch jemand, der nur so tut, als wäre er einer von ihnen.",
		"values": false,
	},
	{
		"title": "Vier Werte begleiten dich",
		"body": "Jede Entscheidung verschiebt deine Werte ein wenig. Es gibt selten eine perfekte Antwort – meistens gewinnst du auf der einen Seite etwas und gibst auf der anderen etwas ab.",
		"values": true,
	},
	{
		"title": "So spielst du",
		"body": "Ziehe die Karte nach links oder rechts, um dich für eine Antwort zu entscheiden. Du kannst auch direkt auf eine Antwort tippen oder die Pfeiltasten benutzen.\n\nWährend du ziehst, siehst du unten, wie sich deine Werte verändern würden. Alle Werte starten bei 5. Erreicht ein Wert 0 oder 10, endet das Spiel vorzeitig. Nach %d Runden bekommst du eine Auswertung.\n\nDein Fortschritt wird automatisch gespeichert.",
		"values": false,
	},
]

@onready var _title_label: Label = %TitleLabel
@onready var _body_label: Label = %BodyLabel
@onready var _value_list: VBoxContainer = %ValueList
@onready var _back_button: Button = %BackButton
@onready var _skip_button: Button = %SkipButton
@onready var _next_button: Button = %NextButton

var _page: int = 0


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_skip_button.pressed.connect(_start_game)
	_next_button.pressed.connect(_on_next_pressed)
	_build_value_list()
	_show_page(0)


func _build_value_list() -> void:
	for definition: ValueDefinition in ScenarioLibrary.value_definitions:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		var icon: TextureRect = TextureRect.new()
		icon.texture = definition.icon
		icon.modulate = definition.color
		icon.custom_minimum_size = Vector2(36, 36)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon)
		var column: VBoxContainer = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label: Label = Label.new()
		name_label.text = definition.display_name
		name_label.theme_type_variation = &"SubtitleLabel"
		name_label.add_theme_color_override("font_color", definition.color)
		column.add_child(name_label)
		var focus_label: Label = Label.new()
		focus_label.text = definition.focus
		focus_label.theme_type_variation = &"SmallText"
		focus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(focus_label)
		row.add_child(column)
		_value_list.add_child(row)


func _show_page(index: int) -> void:
	_page = clampi(index, 0, PAGES.size() - 1)
	var page: Dictionary = PAGES[_page]
	_title_label.text = page["title"]
	var body: String = page["body"]
	if body.contains("%d"):
		body = body % ScenarioLibrary.config.max_rounds
	_body_label.text = body
	_value_list.visible = bool(page["values"])
	_back_button.visible = _page > 0
	_next_button.text = "Los geht's" if _page == PAGES.size() - 1 else "Weiter"
	_skip_button.visible = _page < PAGES.size() - 1
	_next_button.grab_focus()


func _on_back_pressed() -> void:
	AudioManager.play(&"click")
	_show_page(_page - 1)


func _on_next_pressed() -> void:
	AudioManager.play(&"click")
	if _page == PAGES.size() - 1:
		_start_game()
	else:
		_show_page(_page + 1)


func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
