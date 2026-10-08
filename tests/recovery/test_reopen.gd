extends RefCounted
const HELP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = HELP.new()
	for trial in range(10):
		for id in SaveStore.ROOM_IDS:
			var root := SavePaths.get_root().path_join("reopen_%d_%s" % [trial, id])
			var store := SaveStore.new(root)
			store.write_progress(id)
			store.write_settings(0.12, 0.88)
			var game: GameSession = load("res://tests/scenes/recovery_validation.tscn").instantiate()
			game.store = store
			h.root.add_child(game)
			await h.frames(3)
			var body := helper.add_body(game.active_room, Vector3(-3.7, 0.245, 0))
			game.active_room.state.pickup(game.active_room.state.epoch, game.active_room.state.subject_id, body.body_id)
			body.disable_prop()
			game.queue_free()
			await h.frames(2)
			var output: Array = []
			var result := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--fixed-fps", "60", "--script", "res://tests/recovery/reopen_probe.gd", "--", "--save-root", root, "--expected-room", id], output, true)
			var log_text := "\n".join(output)
			h.check(result == 0 and "OMDB_REOPEN_RESULT PASS" in log_text and not "ERROR:" in log_text, "VR005.process_reopen.%s.%d" % [id, trial])
			if result != 0 or "ERROR:" in log_text:
				print(log_text)
			h.check(store.read_progress().room_id == id and store.read_settings().music_volume == 0.12, "US4.reopen_preserves_progress_settings")
