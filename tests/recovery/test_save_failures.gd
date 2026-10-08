extends RefCounted
class FailedRename extends SaveStore:
	var fail_rename: bool = false
	func _rename(source: String, destination: String) -> Error:
		return ERR_CANT_CREATE if fail_rename else super._rename(source, destination)
class FailedTemporaryWrite extends SaveStore:
	var fail_write: bool = false
	func _save_temp(config: ConfigFile, path: String) -> Error:
		return ERR_CANT_CREATE if fail_write else super._save_temp(config, path)
func run(h: SceneTree) -> void:
	for trial in range(10):
		for failure in [FailedRename, FailedTemporaryWrite]:
			var root := SavePaths.get_root().path_join("fail_%d_%s" % [trial, "rename" if failure == FailedRename else "write"])
			var store: SaveStore = failure.new(root)
			h.check(store.write_progress("room_03") == OK and store.write_settings(0.2, 0.8) == OK, "EC12.previous_valid_saves")
			var previous := FileAccess.get_file_as_string(root.path_join("progress.cfg"))
			if store is FailedRename:
				store.fail_rename = true
			else:
				store.fail_write = true
			h.check(store.write_progress("room_05") != OK and store.read_progress().room_id == "room_03" and FileAccess.get_file_as_string(root.path_join("progress.cfg")) == previous, "EC12.destination_preserved")
			h.check(store.read_settings().music_volume == 0.2, "EC12.independent_settings_retained")
			var leftovers := false
			for leaf in DirAccess.get_files_at(root):
				leftovers = leftovers or ".tmp." in leaf
			h.check(not leftovers, "EC12.owned_temp_cleanup")
