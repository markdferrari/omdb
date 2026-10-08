class_name SaveStore
extends RefCounted
## Independent version-1 documents; reads never write fallback values.
const ROOM_IDS := ["room_01", "room_02", "room_03", "room_04", "room_05", "room_06"]
var root: String
var _sequence: int = 0
func _init(storage_root: String = "") -> void:
	root = SavePaths.get_root() if storage_root.is_empty() else storage_root

func _read(leaf: String) -> ConfigFile:
	var file := FileAccess.open(root.path_join(leaf), FileAccess.READ)
	if file == null:
		return null
	var content := file.get_as_text()
	file.close()
	# Only this contract's scalar fields are interpreted. ConfigFile writes the documents;
	# JSON's non-logging scalar parser lets malformed user files fall back without an
	# engine diagnostic. Unknown ConfigFile values are ignored, never instantiated.
	var config := ConfigFile.new()
	var section := ""
	for raw in content.split("\n"):
		var line := _without_comment(raw).strip_edges()
		if line.is_empty() or line.begins_with(";") or line.begins_with("#"):
			continue
		if line.begins_with("["):
			if not line.ends_with("]") or line.length() < 3:
				return null
			section = line.substr(1, line.length() - 2).strip_edges()
			continue
		var delimiter := line.find("=")
		if section.is_empty() or delimiter <= 0:
			return null
		var key := line.left(delimiter).strip_edges()
		if not ((section == "meta" and key == "schema_version") or
			(section == "progress" and key == "current_room") or
			(section == "audio" and key in ["music_volume", "sfx_volume"])):
			continue
		var value_text := line.substr(delimiter + 1).strip_edges()
		var parser := JSON.new()
		var value: Variant = null
		if value_text == "nan":
			value = NAN
		elif value_text in ["inf", "-inf"]:
			value = INF if value_text == "inf" else -INF
		elif parser.parse(value_text) == OK:
			value = parser.data
			# JSON stores every number as float; distinguish integer schema syntax.
			if section == "meta" and value_text.is_valid_int():
				value = value_text.to_int()
		config.set_value(section, key, value)

	var schema: Variant = _field(config, "meta", "schema_version")
	return config if typeof(schema) == TYPE_INT and schema == 1 else null

static func _field(config: ConfigFile, section: String, key: String) -> Variant:
	return config.get_value(section, key) if config.has_section_key(section, key) else null

static func _without_comment(line: String) -> String:
	var quoted := false
	var escaped := false
	for index in range(line.length()):
		var character := line[index]
		if escaped:
			escaped = false
		elif character == "\\" and quoted:
			escaped = true
		elif character == "\"":
			quoted = not quoted
		elif not quoted and character in [";", "#"]:
			return line.left(index)
	return line

func read_progress() -> Dictionary:
	var config := _read("progress.cfg")
	var value: Variant = _field(config, "progress", "current_room") if config != null else null
	var valid: bool = typeof(value) == TYPE_STRING and value in ROOM_IDS
	return {"room_id": value if valid else "room_01", "valid": valid}

static func _volume(value: Variant, fallback: float) -> float:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
		return fallback
	return clampf(float(value), 0.0, 1.0)

func read_settings() -> Dictionary:
	var config := _read("settings.cfg")
	return {"music_volume": _volume(_field(config, "audio", "music_volume"), 0.7) if config != null else 0.7,
		"sfx_volume": _volume(_field(config, "audio", "sfx_volume"), 0.9) if config != null else 0.9,
		"valid": config != null}

func write_progress(room_id: String) -> Error:
	if room_id not in ROOM_IDS:
		return ERR_INVALID_PARAMETER
	var config := ConfigFile.new()
	config.set_value("meta", "schema_version", 1)
	config.set_value("progress", "current_room", room_id)
	return _write("progress.cfg", config)

func write_settings(music: Variant, sfx: Variant) -> Error:
	for value in [music, sfx]:
		if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
			return ERR_INVALID_PARAMETER
	var config := ConfigFile.new()
	config.set_value("meta", "schema_version", 1)
	config.set_value("audio", "music_volume", _volume(music, 0.7))
	config.set_value("audio", "sfx_volume", _volume(sfx, 0.9))
	return _write("settings.cfg", config)

func _save_temp(config: ConfigFile, path: String) -> Error:
	return config.save(path)

func _rename(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(source, destination)

func _write(leaf: String, config: ConfigFile) -> Error:
	var result := DirAccess.make_dir_recursive_absolute(root)
	if result != OK:
		return result
	_sequence += 1
	var destination := root.path_join(leaf)
	var temporary := destination + ".tmp.%d.%d.%d" % [get_instance_id(), Time.get_ticks_usec(), _sequence]
	result = _save_temp(config, temporary)
	if result == OK:
		result = _rename(temporary, destination)
	if FileAccess.file_exists(temporary):
		DirAccess.remove_absolute(temporary)
	return result
