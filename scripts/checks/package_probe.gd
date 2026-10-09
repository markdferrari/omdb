extends SceneTree
## Invoked externally against an exported PCK; excludes production save access.
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var index := args.find("--save-root")
	if index < 0 or index + 1 >= args.size() or SavePaths.inject_test_root(args[index + 1]) != OK:
		quit(2)
		return
	var game: GameSession = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(game)
	var valid: bool = game.menu.current_screen == "title" and not ResourceLoader.exists("res://tests/run_tests.gd") and not ResourceLoader.exists("res://tests/recovery/reopen_probe.gd")
	var production: bool = ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/main.tscn"
	if production:
		valid = valid and game.catalogue.production and game.catalogue.valid_sequence() and not ResourceLoader.exists("res://tests/scenes/recovery_catalogue.tres")
	game.continue_game()
	for count in range(3):
		await physics_frame
	valid = valid and game.active_room != null and game.active_room.player.alive and game.current_room_id == "room_01"
	game.pause_game()
	valid = valid and paused and game.menu.current_screen == "pause"
	game.menu.open_settings("pause")
	game.menu._views.settings.get_node("Panel/Items/Music").value = 0
	game.menu._views.settings.get_node("Panel/Items/SFX").value = 0.4
	game.menu.close_settings()
	valid = valid and game.store.read_settings().music_volume == 0 and is_equal_approx(game.store.read_settings().sfx_volume, 0.4)
	game.quit_to_title()
	game.continue_game()
	for count in range(3):
		await physics_frame
	valid = valid and game.active_room.state.registry.count() == 0 and game.active_room.player.alive
	if production:
		for number in range(1, 7):
			game.request_activation("room_%02d" % number)
			for count in range(3):
				await physics_frame
			valid = valid and game.active_room != null and game.active_room.definition.matches_room(game.active_room) and game.active_room.state.registry.count() == 0
			if game.active_room.state.registry.count() != 0:
				print("PACKAGE unexpected corpse in ", game.current_room_id, " player=", game.active_room.player.position)
		var door := game.active_room.doors[0]
		door.linked_plate_id = ""
		game.active_room._sync_contacts()
		game.active_room.player.position = door.position - Vector3(0.4, 0, 0)
		door._physics_process(0)
		game.active_room.player.position = door.position + Vector3(0.4, 0, 0)
		door._physics_process(0)
		for count in range(4):
			await physics_frame
		valid = valid and game.completed and game.menu.current_screen == "completion"
		game.menu._views.completion.get_node("Panel/Items/Replay").pressed.emit()
		for count in range(3):
			await physics_frame
		valid = valid and game.current_room_id == "room_01" and game.store.read_progress().room_id == "room_01" and game.active_room.state.registry.count() == 0
	game.queue_free()
	await process_frame
	print("OMDB_PACKAGE_RESULT ", "PASS" if valid else "FAIL")
	quit(0 if valid else 1)
