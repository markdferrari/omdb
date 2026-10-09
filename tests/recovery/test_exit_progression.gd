extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var game: GameSession = load("res://scenes/main.tscn").instantiate()
		game.auto_start = false
		game.catalogue = load("res://resources/room_catalogue.tres")
		game.store = SaveStore.new(SavePaths.get_root().path_join("exit_flow_%d" % trial))
		h.root.add_child(game)
		game.request_activation("room_01")
		await h.frames(3)
		game.settings.music_volume = 0.25
		game.settings.sfx_volume = 0.65
		game.persist_settings()
		for number in range(1, 7):
			var room := game.active_room
			var door := room.doors[0]
			door.linked_plate_id = ""
			room._sync_contacts()
			room.player.global_position = door.to_global(Vector3(-0.4, 0, 0))
			door._physics_process(0)
			room.player.global_position = door.to_global(Vector3(0.4, 0, 0))
			door._physics_process(0)
			await h.frames(4)
			if number < 6:
				h.check(game.current_room_id == "room_%02d" % (number + 1) and game.active_room.state.registry.count() == 0 and game.room_host.get_child_count() == 1, "US5.crossing_activates_fresh_next_room")
			else:
				h.check(game.completed and game.mode == GameSession.Mode.COMPLETE and game.menu.current_screen == "completion" and game.store.read_progress().room_id == "room_06", "US5.sixth_crossing_completion_keeps_six")
		game.request_activation("room_06")
		await h.frames(3)
		h.check(not game.completed and game.active_room.player.alive and game.active_room.state.registry.count() == 0, "US5.completed_resume_fresh_six")
		game.menu._views.completion.get_node("Panel/Items/Replay").pressed.emit()
		await h.frames(3)
		h.check(game.store.read_progress().room_id == "room_01" and game.settings.music_volume == 0.25 and game.settings.sfx_volume == 0.65, "US5.replay_saves_one_keeps_volumes")
		var old := game.active_room
		var door := old.doors[0]
		door.linked_plate_id = ""
		old._sync_contacts()
		old.player.global_position = door.to_global(Vector3(-0.4, 0, 0))
		door._physics_process(0)
		old.player.global_position = door.to_global(Vector3(0.4, 0, 0))
		door._physics_process(0)
		game.request_restart(old.state.epoch)
		await h.frames(4)
		h.check(game.current_room_id == "room_01" and not game.active_room.state.exit_consumed and game.active_room.state.subject_id == 1, "EC10.restart_cancels_queued_crossing")
		game.queue_free()
		await h.frames(2)
