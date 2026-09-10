extends State
## Applies the chosen answer to the values and flies the card off screen.

var _ctx: GameContext
var _active: bool = false


func setup(new_context: Object) -> void:
	super(new_context)
	_ctx = new_context as GameContext


func enter(data: Dictionary = {}) -> void:
	_active = true
	var is_a: bool = bool(data.get("is_a", true))
	var result: Dictionary = GameState.apply_choice(is_a)
	_ctx.option_a.set_highlight(1.0 if is_a else 0.0)
	_ctx.option_b.set_highlight(0.0 if is_a else 1.0)
	AudioManager.play(&"swipe")
	_resolve(is_a, result)


func exit() -> void:
	_active = false


func _resolve(is_a: bool, result: Dictionary) -> void:
	await _ctx.card.fly_out(-1 if is_a else 1)
	if _active:
		request_transition(&"Outcome", result)
