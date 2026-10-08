class_name CorpseRegistry
extends RefCounted
## Pure state. All decisions are called only by the owning RoomController.
enum Mode { RELEASED, HELD, REMOVED }
const CAPACITY := 5
var epoch: int
var _next_sequence: int = 1
var _records: Array[Dictionary] = []

func _init(room_epoch: int = 1) -> void:
	epoch = room_epoch

func ordered_ids() -> Array[String]:
	var result: Array[String] = []
	for record in _records:
		result.append(record.body_id)
	return result

func count() -> int:
	return _records.size()

func oldest_id() -> String:
	return "" if _records.is_empty() else _records[0].body_id

func record_for(body_id: String) -> Dictionary:
	for record in _records:
		if record.body_id == body_id:
			return record.duplicate(true)
	return {}

func create(death_origin: Transform3D) -> Dictionary:
	var evicted := ""
	if count() == CAPACITY:
		evicted = oldest_id()
		remove(evicted)
	var identity := "%d:%d" % [epoch, _next_sequence]
	_records.append({"body_id": identity, "creation_index": _next_sequence,
		"mode": Mode.RELEASED, "death_origin": death_origin})
	_next_sequence += 1
	return {"result": "ACCEPTED", "body_id": identity, "evicted_id": evicted}

func remove(body_id: String) -> String:
	for index in range(_records.size()):
		if _records[index].body_id == body_id:
			_records[index].mode = Mode.REMOVED
			_records.remove_at(index)
			return "ACCEPTED"
	return "INVALID_STATE"

func set_mode(body_id: String, mode: Mode) -> String:
	if mode not in [Mode.HELD, Mode.RELEASED]:
		return "INVALID_STATE"
	if mode == Mode.HELD:
		for record in _records:
			if record.mode == Mode.HELD:
				return "INVALID_STATE"
	for record in _records:
		if record.body_id == body_id and record.mode != mode:
			record.mode = mode
			return "ACCEPTED"
	return "INVALID_STATE"

func eligible(body_id: String) -> bool:
	var record := record_for(body_id)
	return not record.is_empty() and record.mode == Mode.RELEASED
