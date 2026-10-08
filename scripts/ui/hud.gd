extends CanvasLayer
var _deaths: int = 0
var _prompts: InputPrompts
var _last_snapshot: Dictionary = {}

func _ready() -> void:
	var room := get_parent() as RoomController
	var ancestor: Node = room
	while ancestor != null and not ancestor is GameSession:
		ancestor = ancestor.get_parent()
	if ancestor is GameSession:
		_prompts = ancestor.prompts
	else:
		_prompts = InputPrompts.new()
		add_child(_prompts)
	_prompts.method_changed.connect(_method_changed)
	room.room_snapshot_changed.connect(_snapshot)
	room.death_committed.connect(_death)
	room.placement_preview_changed.connect(_preview)
	_snapshot(room.state.snapshot())

func _method_changed(_method: String) -> void:
	if not _last_snapshot.is_empty():
		_snapshot(_last_snapshot)

func _snapshot(snapshot: Dictionary) -> void:
	_last_snapshot = snapshot.duplicate(true)
	var controller := _prompts.method == "controller"
	var controls := "Move: Left stick   Jump: South   Restart: North" if controller else "Move: WASD / arrows   Jump: Space   Restart: R"
	var interact := "West" if controller else "E"
	$Panel/Status.text = "Bodies: %d/5   Oldest: %s   Subject #%d\n%s\n%s: pick up or place   Carrying: %s" % [
		snapshot.body_count, "—" if snapshot.oldest_id.is_empty() else snapshot.oldest_id,
		snapshot.subject_id, controls, interact, "none" if snapshot.held_body_id.is_empty() else snapshot.held_body_id + (" (NEXT TO GO)" if snapshot.held_body_id == snapshot.oldest_id else "")]

	if snapshot.held_body_id.is_empty():
		$PlacementState.text = ""

func _death(event: Dictionary) -> void:
	_deaths += 1
	$Caption.text = "Subject #%d: A pointed argument.  Deaths: %d" % [event.subject_id, _deaths]

func _preview(result: Dictionary) -> void:
	var reasons := {"OUT_OF_REACH": "Too far away", "BLOCKED_PATH": "Path blocked",
		"NO_SUPPORT": "No supporting surface", "UNSTABLE_SUPPORT": "Needs a flat, supported footprint",
		"PLAYER_OVERLAP": "Overlaps you", "BODY_OVERLAP": "Body space occupied",
		"WORLD_OVERLAP": "Blocked or reserved space", "STALE_REQUEST": "Body no longer available"}
	$PlacementState.text = "✓ %s: PLACE" % ("West" if _prompts.method == "controller" else "E") if result.valid else "✕ KEEP HOLDING — " + reasons.get(result.reason, result.reason)
