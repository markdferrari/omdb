extends RefCounted
func document(root: String, leaf: String, version: Variant, section: String, fields: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(root)
	var config := ConfigFile.new()
	config.set_value("meta", "schema_version", version)
	for key in fields:
		config.set_value(section, key, fields[key])
	config.save(root.path_join(leaf))
func run(h: SceneTree) -> void:
	for trial in range(10):
		var root := SavePaths.get_root().path_join("save_store_%d_%d" % [Time.get_ticks_usec(), trial])
		var store := SaveStore.new(root)
		h.check(store.read_progress().room_id == "room_01" and not store.read_progress().valid, "US4.missing_progress")
		h.check(store.read_settings().music_volume == 0.7 and store.read_settings().sfx_volume == 0.9, "US4.default_settings")
		for id in SaveStore.ROOM_IDS:
			h.check(store.write_progress(id) == OK and store.read_progress().room_id == id and store.read_progress().valid, "US4.valid_room.%s.%d" % [id, trial])
		for bad in ["room_07", "../scene", 4, true]:
			document(root, "progress.cfg", 1, "progress", {"current_room": bad})
			h.check(store.read_progress().room_id == "room_01" and not store.read_progress().valid, "EC11.invalid_room")
		for schema in [2, "1", true]:
			document(root, "progress.cfg", schema, "progress", {"current_room": "room_04"})
			h.check(not store.read_progress().valid, "EC11.unsupported_schema")
		document(root, "progress.cfg", 1, "progress", {"current_room": "room_04", "unknown": "ignored"})
		h.check(store.read_progress().room_id == "room_04", "EC11.unknown_fields")
		for invalid in [true, "0.2", NAN, INF, -INF]:
			document(root, "settings.cfg", 1, "audio", {"music_volume": invalid, "sfx_volume": 0.25})
			var values := store.read_settings()
			h.check(values.music_volume == 0.7 and values.sfx_volume == 0.25 and store.read_progress().room_id == "room_04", "US4.independent_field_default")
		document(root, "settings.cfg", 1, "audio", {"music_volume": -2, "sfx_volume": 5})
		h.check(store.read_settings().music_volume == 0.0 and store.read_settings().sfx_volume == 1.0, "US4.numeric_clamp")
		h.check(store.write_settings(0.15, 0.85) == OK and store.read_settings().music_volume == 0.15, "US4.settings_write")
		for schema in [2, true, "1"]:
			document(root, "settings.cfg", schema, "audio", {"music_volume": 0.2, "sfx_volume": 0.3})
			h.check(store.read_settings().music_volume == 0.7 and store.read_progress().room_id == "room_04", "EC11.unsupported_settings_independent_progress")
		document(root, "settings.cfg", 1, "audio", {"sfx_volume": 0.4})
		h.check(store.read_settings().music_volume == 0.7 and store.read_settings().sfx_volume == 0.4, "EC11.partial_settings")
		DirAccess.remove_absolute(root.path_join("settings.cfg"))
		DirAccess.make_dir_absolute(root.path_join("settings.cfg"))
		h.check(store.read_settings().music_volume == 0.7, "EC11.unreadable_settings")
		DirAccess.remove_absolute(root.path_join("settings.cfg"))
		store.write_settings(0.15, 0.85)
		var malformed := FileAccess.open(root.path_join("progress.cfg"), FileAccess.WRITE)
		malformed.store_string("[meta]\nschema_version=1\n[progress]\ncurrent_room=\"unterminated")
		malformed.close()
		h.check(not store.read_progress().valid and store.read_settings().music_volume == 0.15, "EC11.corrupt_progress_independent_settings")
		h.check(FileAccess.get_file_as_string(root.path_join("progress.cfg")) == "[meta]\nschema_version=1\n[progress]\ncurrent_room=\"unterminated", "EC11.no_eager_overwrite")
		var failure_root := root.path_join("not_a_directory")
		var blocker := FileAccess.open(failure_root, FileAccess.WRITE)
		blocker.store_string("block")
		blocker.close()
		var blocked := SaveStore.new(failure_root)
		h.check(blocked.write_progress("room_02") != OK, "EC12.real_write_failure")
		h.check(store.root == root and root.begins_with(SavePaths.get_root()), "US4.injected_root_no_fallback")
