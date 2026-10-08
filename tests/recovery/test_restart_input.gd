extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		for controller in [false, true]:
			var game: GameSession = load("res://tests/scenes/recovery_validation.tscn").instantiate()
			game.store = SaveStore.new(SavePaths.get_root().path_join("restart_input_%d_%s" % [trial, controller]))
			h.root.add_child(game)
			var epoch := game.active_room.state.epoch
			game.active_room.request_death(epoch, game.active_room.state.subject_id, "fixture", game.active_room.player.global_transform)
			await h.frames(2)
			var event: InputEvent
			if controller:
				var joy := InputEventJoypadButton.new()
				joy.device = 42
				joy.button_index = 3
				joy.pressed = true
				event = joy
			else:
				var key := InputEventKey.new()
				key.physical_keycode = KEY_R
				key.pressed = true
				event = key
			Input.parse_input_event(event)
			await h.frames(3)
			h.check(game.active_room.state.epoch > epoch and game.active_room.state.subject_id == 1 and game.active_room.state.registry.count() == 0 and game._notice.text == "Room restarted.", "FR026.restart_during_feedback.%s.%d" % [controller, trial])
			event.pressed = false
			Input.parse_input_event(event)
			game.queue_free()
			h.paused = false
			await h.frames(2)
