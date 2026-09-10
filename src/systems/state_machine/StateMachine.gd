class_name StateMachine
extends Node
## Finite state machine. Child State nodes register themselves by node name.

signal state_changed(previous_state: StringName, next_state: StringName)

@export var initial_state: StringName = &""

var current_state: State
var _states: Dictionary = {}
var _running: bool = false


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			_states[StringName(child.name)] = child
			(child as State).transition_requested.connect(_on_transition_requested)


func start(context: Object) -> void:
	for state: State in _states.values():
		state.setup(context)
	_running = true
	transition_to(initial_state)


func stop() -> void:
	if current_state != null:
		current_state.exit()
		current_state = null
	_running = false


func transition_to(state_name: StringName, data: Dictionary = {}) -> void:
	if not _running:
		return
	if not _states.has(state_name):
		push_error("StateMachine: unknown state '%s'" % state_name)
		return
	var previous_name: StringName = current_state.name if current_state != null else &""
	if current_state != null:
		current_state.exit()
	current_state = _states[state_name]
	current_state.enter(data)
	state_changed.emit(previous_name, state_name)


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)


func _on_transition_requested(next_state: StringName, data: Dictionary) -> void:
	transition_to(next_state, data)
