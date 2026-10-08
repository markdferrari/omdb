extends RefCounted
class RejectSettings extends SaveStore:
	var rejecting: bool = false
	func write_settings(music: Variant, sfx: Variant) -> Error:
		return ERR_CANT_CREATE if rejecting else super.write_settings(music, sfx)
func run(h: SceneTree) -> void:
	for trial in range(10):
		var game: GameSession = load("res://tests/scenes/flow_validation.tscn").instantiate()
		var store := RejectSettings.new(SavePaths.get_root().path_join("menu_audio_%d" % trial))
		store.write_settings(0.7, 0.9)
		game.store = store
		h.root.add_child(game)
		game.menu.open_settings("title")
		game.menu._views.settings.get_node("Panel/Items/Music").value = 0
		game.menu._views.settings.get_node("Panel/Items/SFX").value = 0.4
		h.check(game.audio.music_volume == 0 and is_equal_approx(game.audio.sfx_volume, 0.4) and game.menu._views.settings.get_node("Panel/Items/MusicValue").text.contains("MUTED"), "SC010.live_slider_independent_mute")
		game.menu.close_settings()
		h.check(store.read_settings().music_volume == 0 and is_equal_approx(store.read_settings().sfx_volume, 0.4), "SC010.settings_back_persists")
		game.continue_game()
		await h.frames(3)
		game.request_restart(game.active_room.state.epoch)
		await h.frames(3)
		h.check(game.settings.music_volume == 0 and is_equal_approx(game.audio.sfx_volume, 0.4), "SC010.settings_retained_restart")
		game.request_activation("room_06")
		await h.frames(3)
		game.active_room.state.exit_consumed = true
		game._on_room_completed(game.active_room.state.epoch, "room_06")
		await h.frames(2)
		h.check(game.mode == GameSession.Mode.COMPLETE and store.read_progress().room_id == "room_06" and game.menu.current_screen == "completion", "US6.fixture_completion_keeps_room6")
		game.menu._views.completion.get_node("Panel/Items/Replay").pressed.emit()
		await h.frames(3)
		h.check(game.current_room_id == "room_01" and store.read_progress().room_id == "room_01" and game.active_room.state.registry.count() == 0 and game.settings.music_volume == 0, "US6.replay_fresh_saved_settings_retained")
		store.rejecting = true
		game.settings.sfx_volume = 0.6
		game.audio.apply(0, 0.6)
		h.check(game.persist_settings() != OK and is_equal_approx(store.read_settings().sfx_volume, 0.4) and game._notice.text.contains("could not be saved") and game.audio.sfx_volume == 0.6, "SC010.save_failure_keeps_live_volumes_and_old_file")
		game.quit_to_title()
		h.check(game.active_room == null and game.mode == GameSession.Mode.MENU and game.settings.music_volume == 0, "US6.quit_to_title_keeps_settings")
		game.queue_free()
		h.paused = false
		await h.frames(2)
