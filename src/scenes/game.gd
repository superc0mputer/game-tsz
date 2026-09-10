extends Control
## Game screen: wires the UI into a GameContext and hands it to the game-loop state machine.

const MAIN_MENU_SCENE: String = "res://src/scenes/main_menu.tscn"

@onready var _card: ScenarioCard = %ScenarioCard
@onready var _bubble: ScenarioBubble = %ScenarioBubble
@onready var _option_a: OptionPanel = %OptionA
@onready var _option_b: OptionPanel = %OptionB
@onready var _outcome_panel: OutcomePanel = %OutcomePanel
@onready var _end_screen: EndScreen = %EndScreen
@onready var _pause_menu: PauseMenu = %PauseMenu
@onready var _round_label: Label = %RoundIndicator
@onready var _menu_button: Button = %MenuButton
@onready var _game_loop: StateMachine = $GameLoop


func _ready() -> void:
	if not GameState.is_active:
		GameState.start_new_game()
	var context: GameContext = GameContext.new()
	context.card = _card
	context.bubble = _bubble
	context.option_a = _option_a
	context.option_b = _option_b
	context.outcome_panel = _outcome_panel
	context.end_screen = _end_screen
	context.round_label = _round_label
	_menu_button.pressed.connect(_open_pause)
	_pause_menu.resume_pressed.connect(_close_pause)
	_pause_menu.save_quit_pressed.connect(_on_save_quit)
	_pause_menu.restart_pressed.connect(_on_restart)
	_game_loop.start(context)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameState.is_active:
		if _pause_menu.visible:
			_close_pause()
		else:
			_open_pause()
		get_viewport().set_input_as_handled()


func _open_pause() -> void:
	if not GameState.is_active or _pause_menu.visible:
		return
	AudioManager.play(&"click")
	get_tree().paused = true
	_pause_menu.open()


func _close_pause() -> void:
	AudioManager.play(&"click")
	_pause_menu.close()
	get_tree().paused = false


func _on_save_quit() -> void:
	AudioManager.play(&"click")
	GameState.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_restart() -> void:
	AudioManager.play(&"click")
	get_tree().paused = false
	GameState.delete_save()
	GameState.start_new_game()
	get_tree().reload_current_scene()
