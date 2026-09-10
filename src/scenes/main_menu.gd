extends Control
## Title screen: new game, continue (when a save exists), delete save, quit.

const INTRO_SCENE: String = "res://src/scenes/intro.tscn"
const GAME_SCENE: String = "res://src/scenes/game.tscn"

@onready var _play_button: Button = %PlayButton
@onready var _continue_button: Button = %ContinueButton
@onready var _reset_button: Button = %ResetButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	get_tree().paused = false
	_play_button.pressed.connect(_on_play_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_reset_button.pressed.connect(_on_reset_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_quit_button.visible = not OS.has_feature("web")
	_refresh()


func _refresh() -> void:
	var has_save: bool = GameState.has_save()
	_continue_button.visible = has_save
	_reset_button.disabled = not has_save
	if has_save:
		_continue_button.grab_focus()
	else:
		_play_button.grab_focus()


func _on_play_pressed() -> void:
	AudioManager.play(&"click")
	GameState.delete_save()
	GameState.start_new_game()
	get_tree().change_scene_to_file(INTRO_SCENE)


func _on_continue_pressed() -> void:
	AudioManager.play(&"click")
	if GameState.load_game():
		get_tree().change_scene_to_file(GAME_SCENE)
	else:
		GameState.delete_save()
		_refresh()


func _on_reset_pressed() -> void:
	AudioManager.play(&"click")
	GameState.delete_save()
	_refresh()


func _on_quit_pressed() -> void:
	get_tree().quit()
