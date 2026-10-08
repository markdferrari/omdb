extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		var prompts := InputPrompts.new()
		var noise := InputEventJoypadMotion.new()
		noise.axis_value = 0.1
		prompts.observe(noise)
		h.check(prompts.method == "keyboard", "US6.ignore_stick_noise")
		noise.axis_value = 0.7
		prompts.observe(noise)
		h.check(prompts.method == "controller", "US6.active_controller_prompts")
		var key := InputEventKey.new()
		key.physical_keycode = KEY_E
		key.pressed = true
		prompts.observe(key)
		h.check(prompts.method == "keyboard", "US6.keyboard_prompt_switch")
		prompts.free()
		var game: GameSession = load("res://scenes/main.tscn").instantiate()
		game.auto_start = false
		game.catalogue = load("res://tests/scenes/recovery_catalogue.tres")
		game.store = SaveStore.new(SavePaths.get_root().path_join("flow_%d" % trial))
		h.root.add_child(game)
		await h.frames(2)
		h.check(game.menu != null, "US6.title_menu_focus")
		game.continue_game()
		await h.frames(3)
		if game.active_room == null:
			h.check(false, "US6.continue_activates_room")
			game.queue_free()
			await h.frames(2)
			continue
		h.check(game.mode == GameSession.Mode.PLAYING and not h.paused, "US6.playing_state")
		game.active_room.request_death(game.active_room.state.epoch, game.active_room.state.subject_id, "fixture", game.active_room.player.global_transform)
		await h.frames(2)
		var pause_event := InputEventKey.new()
		pause_event.physical_keycode = KEY_ESCAPE
		pause_event.pressed = true
		Input.parse_input_event(pause_event)
		await h.frames(2)
		pause_event.pressed = false
		Input.parse_input_event(pause_event)
		var remaining := game.active_room._feedback_remaining
		var position_before := game.active_room.player.position
		Input.action_press("move_right")
		Input.action_press("jump")
		await h.frames(80)
		Input.action_release("move_right")
		Input.action_release("jump")
		h.check(game.active_room.player.position == position_before, "US6.pause_blocks_gameplay")
		h.check(game.mode == GameSession.Mode.PAUSED and is_equal_approx(game.active_room._feedback_remaining, remaining) and game.active_room.state.subject_id == 1, "US6.pause_freezes_feedback")
		h.check(h.root.get_viewport().gui_get_focus_owner() != null and h.root.get_viewport().gui_get_focus_owner().name == "Resume", "US6.pause_initial_focus")
		var settings_button: Button = game.menu._views.pause.get_node("Panel/Items/Settings")
		settings_button.grab_focus()
		game.menu.open_settings("pause")
		await h.frames(2)
		h.check(h.root.get_viewport().gui_get_focus_owner().name == "Music", "US6.settings_initial_focus")
		game.menu.close_settings()
		await h.frames(2)
		h.check(h.root.get_viewport().gui_get_focus_owner().name == "Settings", "US6.restore_pause_focus")
		game.resume_game()
		await h.frames(45)
		h.check(game.active_room.player.alive and game.active_room.state.subject_id == 2, "US6.resume_feedback")
		var controller := InputEventJoypadButton.new()
		controller.button_index = 6
		controller.device = 42
		controller.pressed = true
		h.check(controller.is_action_pressed("pause"), "FR031.any_controller_pause_binding")
		Input.parse_input_event(controller)
		await h.frames(2)
		controller.pressed = false
		Input.parse_input_event(controller)
		h.check(game.mode == GameSession.Mode.PAUSED and game.prompts.method == "controller", "US6.controller_pause_consumed")
		game.resume_game()
		game.prompts.connection_changed(42, false)
		await h.frames(2)
		h.check(game.mode == GameSession.Mode.PAUSED, "US6.active_controller_disconnect_pauses")
		game.prompts.connection_changed(42, true)
		await h.frames(2)
		h.check(h.root.get_viewport().gui_get_focus_owner() != null, "US6.reconnect_retains_focus")
		game.resume_game()
		game.prompts._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		h.check(game.mode == GameSession.Mode.PAUSED, "US6.focus_loss_pauses")
		game.resume_game()
		game.quit_to_title()
		game.continue_game()
		await h.frames(3)
		h.check(game.active_room.state.registry.count() == 0, "US6.continue_fresh_after_title")
		game.prompts.observe(key)
		h.check(game.active_room.get_node("HUD/Panel/Status").text.contains("WASD"), "US6.fresh_hud_prompt_subscription")
		game.queue_free()
		h.paused = false
		await h.frames(2)
