extends Node
## Dev-only visual verification harness: runs through menu, intro, game, preview, outcome and end screen,
## saving one PNG per state into user://, then quits. Run windowed (not headless).

const MENU_SCENE: PackedScene = preload("res://src/scenes/main_menu.tscn")
const INTRO_SCENE: PackedScene = preload("res://src/scenes/intro.tscn")
const GAME_SCENE: PackedScene = preload("res://src/scenes/game.tscn")

var _shots: Array[String] = []


func _ready() -> void:
	await _run()
	print("CAPTURE_DONE %s" % ", ".join(_shots))
	get_tree().quit()


func _run() -> void:
	# 1. Main menu
	var menu: Node = MENU_SCENE.instantiate()
	add_child(menu)
	await _settle(4)
	await _shoot("capture_menu.png")
	menu.queue_free()

	# 2. Intro (page with the four values)
	GameState.start_new_game()
	var intro: Node = INTRO_SCENE.instantiate()
	add_child(intro)
	await _settle(2)
	intro.call("_show_page", 1)
	await _settle(2)
	await _shoot("capture_intro.png")
	intro.queue_free()

	# 3. Game: fresh round, card dealt in
	GameState.start_new_game()
	GameState.deck.push_front(&"hildegard_05")
	var game: Node = GAME_SCENE.instantiate()
	add_child(game)
	await _wait_seconds(1.0)
	await _shoot("capture_game.png")

	# 4. Preview while "dragging" towards answer A
	var card: ScenarioCard = game.get_node("%ScenarioCard")
	card.drag_ratio_changed.emit(-0.9)
	card.get_node("%Body").position = Vector2(-140, 0)
	card.get_node("%Body").rotation_degrees = -7.0
	await _settle(2)
	await _shoot("capture_preview.png")
	card.drag_ratio_changed.emit(0.9)
	card.get_node("%Body").position = Vector2(140, 0)
	card.get_node("%Body").rotation_degrees = 7.0
	await _settle(2)
	await _shoot("capture_preview_right.png")
	card.drag_ratio_changed.emit(0.0)
	print("CARD_SIZES card=%s body=%s role_min=%s" % [card.size, card.get_node("%Body").size, card.get_node("%RoleLabel").get_combined_minimum_size()])

	# 5. Choose A via the option panel → outcome panel
	var option_a: OptionPanel = game.get_node("%OptionA")
	option_a.pressed.emit()
	await _wait_seconds(1.1)
	await _shoot("capture_outcome.png")

	# 6. Continue → next round dealt
	var outcome_panel: OutcomePanel = game.get_node("%OutcomePanel")
	outcome_panel.continue_pressed.emit()
	await _wait_seconds(1.0)
	await _shoot("capture_round2.png")

	# 7. Pause menu
	game.call("_open_pause")
	await _settle(2)
	await _shoot("capture_pause.png")
	game.call("_close_pause")
	await _settle(1)

	# 8. End screen (forced values for a readable evaluation)
	var end_screen: EndScreen = game.get_node("%EndScreen")
	var values: Dictionary = {&"selbststaendigkeit": 7, &"sicherheit": 3, &"verbundenheit": 6, &"entlastung": 4}
	end_screen.show_results(values, true, &"", 10)
	await _wait_seconds(0.6)
	await _shoot("capture_end.png")
	game.queue_free()
	await _settle(1)


func _settle(frames: int) -> void:
	for i: int in frames:
		await get_tree().process_frame


func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _shoot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var path: String = "user://" + file_name
	var err: Error = image.save_png(path)
	if err != OK:
		push_error("capture: could not save %s (%s)" % [path, error_string(err)])
	else:
		_shots.append(file_name)
