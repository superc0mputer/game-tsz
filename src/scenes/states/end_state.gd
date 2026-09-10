extends State
## Shows the final evaluation and handles restart / back to menu.

const MAIN_MENU_SCENE: String = "res://src/scenes/main_menu.tscn"

var _ctx: GameContext


func setup(new_context: Object) -> void:
	super(new_context)
	_ctx = new_context as GameContext


func enter(data: Dictionary = {}) -> void:
	var completed: bool = bool(data.get("completed", true))
	GameState.is_active = false
	GameState.delete_save()
	_ctx.outcome_panel.hide_panel()
	_ctx.card.set_interactive(false)
	AudioManager.play(&"finish" if completed else &"fail")
	_ctx.end_screen.restart_pressed.connect(_on_restart_pressed)
	_ctx.end_screen.menu_pressed.connect(_on_menu_pressed)
	_ctx.end_screen.show_results(GameState.values, completed, GameState.ended_by_extreme, GameState.round_index)


func exit() -> void:
	if _ctx.end_screen.restart_pressed.is_connected(_on_restart_pressed):
		_ctx.end_screen.restart_pressed.disconnect(_on_restart_pressed)
	if _ctx.end_screen.menu_pressed.is_connected(_on_menu_pressed):
		_ctx.end_screen.menu_pressed.disconnect(_on_menu_pressed)


func _on_restart_pressed() -> void:
	AudioManager.play(&"click")
	GameState.start_new_game()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	AudioManager.play(&"click")
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
