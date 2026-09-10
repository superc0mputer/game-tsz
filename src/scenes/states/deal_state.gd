extends State
## Draws the next scenario, fills the UI and animates the card in.

var _ctx: GameContext
var _active: bool = false


func setup(new_context: Object) -> void:
	super(new_context)
	_ctx = new_context as GameContext


func enter(_data: Dictionary = {}) -> void:
	_active = true
	_ctx.outcome_panel.hide_panel()
	var scenario: ScenarioData = GameState.current_or_draw()
	if scenario == null:
		request_transition(&"End", {"completed": true})
		return
	_ctx.round_label.text = "Runde %d von %d" % [GameState.round_index + 1, GameState.rounds_total()]
	_ctx.bubble.show_scenario(scenario)
	_ctx.card.show_scenario(scenario)
	_ctx.option_a.set_option(scenario.choice_a.label)
	_ctx.option_b.set_option(scenario.choice_b.label)
	_ctx.option_a.set_highlight(0.0)
	_ctx.option_b.set_highlight(0.0)
	_ctx.option_a.set_enabled(false)
	_ctx.option_b.set_enabled(false)
	EventBus.round_started.emit(GameState.round_index, scenario)
	AudioManager.play(&"deal")
	_deal()


func exit() -> void:
	_active = false


func _deal() -> void:
	await _ctx.card.deal_in()
	if _active:
		request_transition(&"Decide")
