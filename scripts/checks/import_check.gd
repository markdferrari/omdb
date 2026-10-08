extends SceneTree
## Compile/load all project code and resources, including currently unused components.
var checked: int = 0
var failures: int = 0

func _initialize() -> void:
	for directory in ["res://scripts", "res://tests", "res://scenes", "res://resources"]:
		_scan(directory)
	print("OMDB_IMPORT_RESULT checked=", checked, " failed=", failures)
	quit(0 if failures == 0 and checked > 0 else 1)

func _scan(directory: String) -> void:
	for file in DirAccess.get_files_at(directory):
		if file.get_extension() not in ["gd", "tscn", "tres"]:
			continue
		var path := directory.path_join(file)
		if path == "res://scripts/checks/import_check.gd":
			continue
		checked += 1
		var resource := load(path)
		if resource == null or (resource is Script and not resource.can_instantiate()):
			failures += 1
			push_error("Cannot compile/load " + path)
	for child in DirAccess.get_directories_at(directory):
		_scan(directory.path_join(child))
