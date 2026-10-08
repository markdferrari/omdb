extends RefCounted

func run(h: SceneTree) -> void:
	var injected := SavePaths.get_root()
	h.check(SavePaths.is_test_mode() and injected.is_absolute_path(), "foundation.root_injected")
	h.check(SavePaths.file_path("progress.cfg") == injected.path_join("progress.cfg"), "foundation.no_production_fallback")
	for invalid in ["user://", OS.get_user_data_dir(), OS.get_user_data_dir().path_join("test"), "/tmp", "relative/path"]:
		h.check(SavePaths.inject_test_root(invalid) != OK and SavePaths.get_root() == injected, "foundation.unsafe_root_rejected")
	# A symlink must not provide an escape from the isolated root boundary.
	var parent := injected.get_base_dir()
	var directory := DirAccess.open(parent)
	var link := parent.path_join("omdb-root-link-" + str(OS.get_process_id()))
	if directory.create_link(parent, link) == OK:
		h.check(SavePaths.inject_test_root(link.path_join("child")) != OK, "foundation.symlink_root_rejected")
		directory.remove(link)
	else:
		h.check(false, "foundation.symlink_fixture_unavailable")
