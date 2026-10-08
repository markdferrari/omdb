class_name SavePaths
extends RefCounted
## No save access may precede root injection in a validation context.
# SceneTree owns session configuration; no retained GDScript static-variable storage.
static func get_root() -> String:
	return Engine.get_main_loop().get_meta("omdb_save_root", "user://")

static func is_test_mode() -> bool:
	return Engine.get_main_loop().get_meta("omdb_test_mode", false)

static func inject_test_root(candidate: String) -> Error:
	if not candidate.is_absolute_path() or candidate.begins_with("user://"):
		return ERR_INVALID_PARAMETER
	var clean := candidate.simplify_path().trim_suffix("/")
	var production := OS.get_user_data_dir().simplify_path().trim_suffix("/")
	if clean == production or clean.begins_with(production + "/") or production.begins_with(clean + "/"):
		return ERR_UNAUTHORIZED
	var temporary := OS.get_environment("TMPDIR")
	if temporary.is_empty():
		temporary = OS.get_environment("TEMP") if OS.has_feature("windows") else "/tmp"
	temporary = temporary.simplify_path().trim_suffix("/")
	if not clean.begins_with(temporary + "/"):
		return ERR_UNAUTHORIZED
	# Reject symlink ancestors before creating or opening anything.
	var cursor := clean
	while cursor != cursor.get_base_dir():
		var directory := DirAccess.open(cursor.get_base_dir())
		if directory != null and directory.is_link(cursor.get_file()):
			return ERR_UNAUTHORIZED
		cursor = cursor.get_base_dir()
	Engine.get_main_loop().set_meta("omdb_save_root", clean)
	Engine.get_main_loop().set_meta("omdb_test_mode", true)
	return OK

static func file_path(filename: String) -> String:
	assert(filename == filename.get_file(), "Save names must be leaf names")
	return get_root().path_join(filename)
