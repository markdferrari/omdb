extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		var game: GameSession = load("res://scenes/main.tscn").instantiate()
		game.auto_start = false
		game.catalogue = load("res://tests/scenes/recovery_catalogue.tres")
		game.store = SaveStore.new(SavePaths.get_root().path_join("activation_%d" % trial))
		h.root.add_child(game)
		game.request_activation("room_03")
		await h.frames(3)
		var old := game.active_room
		var definition := RoomDefinition.new()
		definition.room_id = "room_05"
		var packed := PackedScene.new()
		var invalid := Node3D.new()
		packed.pack(invalid)
		invalid.free()
		definition.scene = packed
		h.check(game.activate_room(definition) == ERR_INVALID_DATA and game.active_room == old and old.player.alive and game.current_room_id == "room_03" and game.store.read_progress().room_id == "room_03", "EC10.failed_activation_preserves_room_progress")
		h.check(game.request_activation("../bad_scene") == "INVALID_STATE", "EC11.catalogue_rejects_arbitrary_path")
		var duplicate := RoomCatalogue.new()
		duplicate.rooms = [game.catalogue.rooms[0], game.catalogue.rooms[0]]
		h.check(duplicate.find("room_01") == null, "US4.duplicate_catalogue_rejected")
		game.queue_free()
		await h.frames(2)
