extends RefCounted

func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://resources/room_catalogue.tres"):
		h.check(false, "US5.production_catalogue_exists")
		return
	var catalogue: RoomCatalogue = load("res://resources/room_catalogue.tres")
	h.check(catalogue.rooms.size() == 6, "US5.exactly_six_authored_rooms")
	for number in range(1, 7):
		var definition := catalogue.find("room_%02d" % number)
		h.check(definition != null and definition.scene.resource_path == "res://scenes/rooms/room_%02d.tscn" % number, "US5.production_scene.%d" % number)
	h.check(catalogue.valid_sequence() and catalogue.find("../fixture") == null, "US5.authored_links_and_path_rejection")
	var invalid := RoomCatalogue.new()
	invalid.production = true
	invalid.rooms.assign(catalogue.rooms)
	invalid.rooms[0] = catalogue.rooms[0].duplicate()
	invalid.rooms[0].scene = load("res://tests/scenes/recovery_room.tscn")
	h.check(not invalid.valid_sequence() and invalid.find("room_01") == null, "US5.production_rejects_fixture_scene")
	invalid.rooms[0] = catalogue.rooms[0].duplicate()
	invalid.rooms[0].next_room_id = "room_06"
	h.check(not invalid.valid_sequence(), "US5.production_rejects_skipped_link")
	for trial in range(10):
		for number in range(1, 7):
			var game: GameSession = load("res://scenes/main.tscn").instantiate()
			game.store = SaveStore.new(SavePaths.get_root().path_join("authored_reset_%d_%d" % [trial, number]))
			h.root.add_child(game)
			var identity := "room_%02d" % number
			h.check(game.request_activation(identity) == "ACCEPTED", "US5.authored_activation_request")
			await h.frames(3)
			if game.active_room == null:
				h.check(false, "US5.authored_activation_succeeded")
				game.queue_free()
				await h.frames(2)
				continue
			var old := game.active_room
			var epoch := old.state.epoch
			old.request_death(epoch, old.state.subject_id, "reset_probe", old.player.global_transform)
			await h.frames(2)
			h.check(game.request_restart(epoch) == "ACCEPTED", "US5.authored_restart_during_feedback")
			await h.frames(45)
			var fresh := game.active_room
			h.check(fresh != old and fresh.state.epoch > epoch and fresh.state.subject_id == 1 and fresh.player.alive and fresh.state.registry.count() == 0 and fresh.state.held_body_id.is_empty() and fresh.definition.matches_room(fresh), "US5.authored_reset_fresh_equivalence")
			h.check(game.room_host.get_child_count() == 1 and game.store.read_progress().room_id == identity and game.request_restart(epoch) == "IGNORED_STALE", "US5.authored_reset_keeps_save_rejects_stale")
			for plate in fresh.plates:
				h.check(plate.weight() == 0, "US5.authored_reset_empty_plate")
			for saw in fresh.saws:
				h.check(not saw.jammed(), "US5.authored_reset_active_saw")
			for door in fresh.doors:
				h.check(door.is_open == door.linked_plate_id.is_empty(), "US5.authored_reset_initial_door")
			game.queue_free()
			await h.frames(2)
