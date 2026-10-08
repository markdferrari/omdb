extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var root_index := args.find("--save-root")
	var room_index := args.find("--expected-room")
	if root_index < 0 or room_index < 0 or root_index + 1 >= args.size() or room_index + 1 >= args.size() or SavePaths.inject_test_root(args[root_index + 1]) != OK:
		quit(2)
		return
	var game: GameSession = load("res://tests/scenes/recovery_validation.tscn").instantiate()
	root.add_child(game)
	for index in range(3):
		await physics_frame
	var room := game.active_room
	var valid: bool = game.current_room_id == args[room_index + 1] and room != null and room.player.alive and room.state.registry.count() == 0 and room.state.subject_id == 1 and room.state.held_body_id.is_empty() and game.room_host.get_child_count() == 1 and not room.saws[0].jammed() and room.plates[0].weight() == 0 and not room.doors[0].is_open and is_equal_approx(game.settings.music_volume, 0.12) and is_equal_approx(game.settings.sfx_volume, 0.88)
	game.queue_free()
	await process_frame
	print("OMDB_REOPEN_RESULT ", "PASS" if valid else "FAIL")
	quit(0 if valid else 1)
