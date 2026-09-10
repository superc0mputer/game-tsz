extends State
## Waits for the player's answer: swipe, click on an option panel, or keyboard.

const PREVIEW_DEADZONE: float = 0.1

var _ctx: GameContext
var _preview_side: int = 0


func setup(new_context: Object) -> void:
	super(new_context)
	_ctx = new_context as GameContext


func enter(_data: Dictionary = {}) -> void:
	GameState.save_game()
	_preview_side = 0
	_ctx.card.set_interactive(true)
	_ctx.option_a.set_enabled(true)
	_ctx.option_b.set_enabled(true)
	_ctx.card.drag_ratio_changed.connect(_on_drag_ratio_changed)
	_ctx.card.choice_committed.connect(_on_choice_committed)
	_ctx.option_a.pressed.connect(_on_option_a_pressed)
	_ctx.option_b.pressed.connect(_on_option_b_pressed)


func exit() -> void:
	_ctx.card.drag_ratio_changed.disconnect(_on_drag_ratio_changed)
	_ctx.card.choice_committed.disconnect(_on_choice_committed)
	_ctx.option_a.pressed.disconnect(_on_option_a_pressed)
	_ctx.option_b.pressed.disconnect(_on_option_b_pressed)
	_ctx.card.set_interactive(false)
	_ctx.option_a.set_enabled(false)
	_ctx.option_b.set_enabled(false)
	_clear_preview()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("choose_left"):
		_commit(true, false)
	elif event.is_action_pressed("choose_right"):
		_commit(false, false)


func _on_drag_ratio_changed(ratio: float) -> void:
	if absf(ratio) < PREVIEW_DEADZONE:
		_clear_preview()
		return
	var side: int = -1 if ratio < 0.0 else 1
	if side != _preview_side:
		_preview_side = side
		EventBus.preview_requested.emit(GameState.preview_delta(side < 0))
	_ctx.option_a.set_highlight(absf(ratio) if side < 0 else 0.0)
	_ctx.option_b.set_highlight(absf(ratio) if side > 0 else 0.0)


func _clear_preview() -> void:
	if _preview_side != 0:
		_preview_side = 0
		EventBus.preview_cleared.emit()
	_ctx.option_a.set_highlight(0.0)
	_ctx.option_b.set_highlight(0.0)


func _on_choice_committed(is_a: bool) -> void:
	_commit(is_a, true)


func _on_option_a_pressed() -> void:
	_commit(true, false)


func _on_option_b_pressed() -> void:
	_commit(false, false)


func _commit(is_a: bool, swiped: bool) -> void:
	if not swiped:
		AudioManager.play(&"click")
	request_transition(&"Resolve", {"is_a": is_a})
