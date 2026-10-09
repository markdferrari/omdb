class_name RoomState
extends RefCounted

enum Phase { INITIALIZING, ACTIVE, DEATH_FEEDBACK, RETIRED }
var epoch: int
var phase: Phase = Phase.INITIALIZING
var subject_id: int = 0
var held_body_id: String = ""
var death_token: Vector2i = Vector2i.ZERO
var exit_consumed: bool = false
var registry: CorpseRegistry
var pending_commands: Array[Dictionary] = []

func _init(room_epoch: int = 1) -> void:
	epoch = room_epoch
	registry = CorpseRegistry.new(epoch)

func activate() -> void:
	assert(phase == Phase.INITIALIZING)
	subject_id = 1
	phase = Phase.ACTIVE

func is_live(command_epoch: int, actor_id: int) -> bool:
	return command_epoch == epoch and actor_id == subject_id and phase == Phase.ACTIVE

func request_exit(command_epoch: int, actor_id: int) -> String:
	if command_epoch != epoch or actor_id != subject_id or phase == Phase.RETIRED:
		return "IGNORED_STALE"
	if not is_live(command_epoch, actor_id) or exit_consumed:
		return "INVALID_STATE"
	exit_consumed = true
	return "ACCEPTED"

func request_death(command_epoch: int, actor_id: int) -> String:
	if command_epoch != epoch or actor_id != subject_id or phase == Phase.RETIRED:
		return "IGNORED_STALE"
	if death_token == Vector2i(command_epoch, actor_id):
		return "IGNORED_DUPLICATE"
	if phase != Phase.ACTIVE:
		return "INVALID_STATE"
	death_token = Vector2i(epoch, subject_id)
	phase = Phase.DEATH_FEEDBACK
	return "ACCEPTED"

func replace_subject(token: Vector2i) -> bool:
	if phase != Phase.DEATH_FEEDBACK or token != death_token or token.x != epoch:
		return false
	subject_id += 1
	phase = Phase.ACTIVE
	return true

func retire() -> void:
	phase = Phase.RETIRED
	pending_commands.clear()

func snapshot() -> Dictionary:
	return {"epoch": epoch, "phase": phase, "subject_id": subject_id,
		"ordered_body_ids": registry.ordered_ids(), "held_body_id": held_body_id,
		"oldest_id": registry.oldest_id(), "body_count": registry.count()}

func pickup(command_epoch: int, actor_id: int, body_id: String) -> String:
	if command_epoch != epoch or actor_id != subject_id or phase == Phase.RETIRED:
		return "IGNORED_STALE"
	if not is_live(command_epoch, actor_id) or not held_body_id.is_empty() or not registry.eligible(body_id):
		return "INVALID_STATE"
	var result := registry.set_mode(body_id, CorpseRegistry.Mode.HELD)
	if result == "ACCEPTED":
		held_body_id = body_id
	return result

func release(command_epoch: int, actor_id: int, body_id: String) -> String:
	if command_epoch != epoch or actor_id != subject_id or phase == Phase.RETIRED:
		return "IGNORED_STALE"
	if not is_live(command_epoch, actor_id) or held_body_id.is_empty() or held_body_id != body_id:
		return "INVALID_STATE"
	var result := registry.set_mode(body_id, CorpseRegistry.Mode.RELEASED)
	if result == "ACCEPTED":
		held_body_id = ""
	return result

func release_for_death() -> String:
	if phase != Phase.DEATH_FEEDBACK:
		return ""
	var identity := held_body_id
	if not identity.is_empty():
		registry.set_mode(identity, CorpseRegistry.Mode.RELEASED)
		held_body_id = ""
	return identity

func create_corpse(origin: Transform3D) -> Dictionary:
	var result := registry.create(origin)
	if held_body_id == result.evicted_id:
		held_body_id = ""
	return result

func remove_body(body_id: String) -> String:
	var result := registry.remove(body_id)
	if result == "ACCEPTED" and held_body_id == body_id:
		held_body_id = ""
	return result
