class_name State
extends Node
## Base class for a state inside a StateMachine. States never touch their parent;
## they ask for transitions through a signal and act on injected collaborators.

signal transition_requested(next_state: StringName, data: Dictionary)

var context: Object


func setup(new_context: Object) -> void:
	context = new_context


func enter(_data: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func request_transition(next_state: StringName, data: Dictionary = {}) -> void:
	transition_requested.emit(next_state, data)
