class_name RoomController
extends Node3D
## Sole room mutation boundary. Sensors enqueue observations; never free actors.
signal restart_requested(epoch: int)
signal room_snapshot_changed(snapshot: Dictionary)
signal placement_preview_changed(result: Dictionary)
signal puzzle_state_changed(component_id: String, snapshot: Dictionary)
signal death_committed(event: Dictionary)
signal presentation_cue(cue: String)
signal room_completed(epoch: int, room_id: String)

@export var spawn_player: bool = false
@export var tuning: GameplayTuning = preload("res://resources/gameplay_tuning.tres")
var state: RoomState
var definition: RoomDefinition
var _commands: Array[Dictionary] = []
var _commit_pending: bool = false
var player: PlayerController
var bodies: Dictionary = {}
var _feedback_remaining: float = 0.0
var _death_has_committed: bool = false
var plates: Array[PressurePlate] = []
var doors: Array[ExitDoor] = []
var saws: Array[Buzzsaw] = []
var placement_preview: Dictionary = {}
var last_interaction_result: String = ""
var _carry_visual: Node3D
var _ghost: Node3D
var _ghost_material: StandardMaterial3D
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const DEATH_FEEDBACK := preload("res://scenes/effects/death_feedback.tscn")
const EVICTION_BURST := preload("res://scenes/effects/eviction_burst.tscn")
const CORPSE_SCENE := preload("res://scenes/corpses/corpse.tscn")

func initialize(room_epoch: int, room_definition: RoomDefinition) -> void:
	assert(state == null, "Room can only initialize once")
	definition = room_definition
	state = RoomState.new(room_epoch)
	state.activate()

func _enter_tree() -> void:
	if state == null:
		initialize(1, RoomDefinition.new())

func _ready() -> void:
	if spawn_player:
		_spawn_subject()
		_build_ghost()
	_sync_contacts()
	_publish_snapshot()
	# Room commits precede the later actor movement priority.
	process_physics_priority = -100

func enqueue(command: Dictionary) -> String:
	if int(command.get("epoch", -1)) != state.epoch or state.phase == RoomState.Phase.RETIRED:
		return "IGNORED_STALE"
	_commands.append(command.duplicate(true))
	return "ACCEPTED"

func _physics_process(delta: float) -> void:
	# Input intents commit at this safe boundary before any player movement.
	if not _commands.is_empty():
		_commit_commands()
	_sync_contacts()
	if not state.held_body_id.is_empty() and is_instance_valid(player) and player.alive:
		placement_preview = PlacementEvaluator.evaluate(self, state.held_body_id)
		placement_preview_changed.emit(placement_preview.duplicate(true))
		_show_preview(placement_preview)
	elif _ghost != null:
		_ghost.visible = false
	if state.phase == RoomState.Phase.DEATH_FEEDBACK and _death_has_committed:
		_feedback_remaining -= delta
		if _feedback_remaining <= 0:
			_replace_subject.call_deferred(state.death_token)
	if not _commands.is_empty() and not _commit_pending:
		_commit_pending = true
		_commit_commands.call_deferred()

func _commit_commands() -> void:
	_commit_pending = false
	if state.phase == RoomState.Phase.RETIRED:
		_commands.clear()
		return
	var commands := _commands
	_commands = []
	for command in commands:
		if int(command.epoch) != state.epoch or state.phase == RoomState.Phase.RETIRED:
			continue
		if command.kind == "death":
			_commit_death(command)
		elif command.kind == "interact" and state.is_live(command.epoch, command.subject_id):
			last_interaction_result = _pickup_nearest(command.get("body_id", "")) if state.held_body_id.is_empty() else _place_held()
	_sync_contacts()
	_publish_snapshot()

func retire() -> void:
	state.retire()
	if is_instance_valid(player):
		player.alive = false
	_commands.clear()
	set_physics_process(false)

func request_death(command_epoch: int, subject: int, hazard: String, observed: Transform3D) -> String:
	var result := state.request_death(command_epoch, subject)
	if result != "ACCEPTED":
		return result
	if player != null:
		# Logical ineligibility happens during contact dispatch; physical change is deferred.
		player.alive = false
	_commands.append({"kind": "death", "epoch": command_epoch, "subject_id": subject,
		"hazard_id": hazard, "transform": observed})
	if not _commit_pending:
		_commit_pending = true
		_commit_commands.call_deferred()
	return result

func _commit_death(command: Dictionary) -> void:
	if _death_has_committed or state.death_token != Vector2i(command.epoch, command.subject_id):
		return
	if player != null:
		player.disable_actor()
	# Reserve the new corpse volume before restoring held-body simulation.
	if not state.held_body_id.is_empty():
		_release_on_death(command.transform)
	var result := state.create_corpse(command.transform)
	if not result.evicted_id.is_empty():
		_remove_prop(result.evicted_id)
	var corpse: Corpse = CORPSE_SCENE.instantiate()
	corpse.body_id = result.body_id
	corpse.epoch = state.epoch
	# Player origin is its feet. Corpse origin is box centre, at the observed death site.
	corpse.position = command.transform.origin + Vector3.UP * (tuning.corpse_size.y * 0.5 + tuning.surface_clearance)
	bodies[result.body_id] = corpse
	add_child(corpse)
	_feedback_remaining = tuning.respawn_seconds
	_death_has_committed = true
	_spawn_feedback("death", corpse.global_position)
	var hazard_kind := _hazard_kind(command.hazard_id)
	# The anvil emits its impact cue once before lethal contact is committed.
	if hazard_kind != "anvil":
		presentation_cue.emit("saw_hit" if hazard_kind == "saw" else "spike_hit")
	death_committed.emit({"epoch": state.epoch, "subject_id": command.subject_id,
		"hazard_id": command.hazard_id, "hazard_kind": hazard_kind, "body_id": result.body_id, "evicted_id": result.evicted_id})

func _hazard_kind(identity: String) -> String:
	for child in get_children():
		if child is SpikeBed and child.hazard_id == identity:
			return "spikes"
		if child is Buzzsaw and child.hazard_id == identity:
			return "saw"
		if child is FallingAnvil and child.hazard_id == identity:
			return "anvil"
	return identity

func _replace_subject(token: Vector2i) -> void:
	if not state.replace_subject(token):
		return
	if is_instance_valid(player):
		remove_child(player)
		player.queue_free()
	_death_has_committed = false
	_spawn_subject()
	_publish_snapshot()

func _spawn_subject() -> void:
	player = PLAYER_SCENE.instantiate()
	player.epoch = state.epoch
	player.subject_id = state.subject_id
	player.position = $Spawn.position
	player.lethal_contact.connect(request_death)
	player.interact_requested.connect(request_interact)
	player.restart_requested.connect(func(command_epoch: int):
		if command_epoch == state.epoch and state.phase != RoomState.Phase.RETIRED:
			restart_requested.emit(command_epoch))
	add_child(player)

func _remove_prop(body_id: String) -> void:
	if not bodies.has(body_id):
		return
	var prop: Corpse = bodies[body_id]
	var origin: Vector3 = player.get_node("CarryAnchor").global_position if prop.freeze and is_instance_valid(player) else prop.global_position
	_spawn_feedback("eviction", origin)
	presentation_cue.emit("body_pop")
	prop.disable_prop()
	bodies.erase(body_id)
	_update_carry_visual()
	for other in bodies.values():
		other.sleeping = false
	prop.queue_free()

func _spawn_feedback(kind: String, origin: Vector3) -> void:
	if state.phase == RoomState.Phase.RETIRED or tuning.effect_instance_budget <= 0:
		return
	var count := mini(8, tuning.effect_instance_budget)
	var active: Array[Node] = []
	var used := 0
	for child in get_children():
		if child.is_in_group("cosmetic_feedback"):
			active.append(child)
			used += child.get_child_count()
	while used + count > tuning.effect_instance_budget and not active.is_empty():
		var oldest: Node = active.pop_front()
		used -= oldest.get_child_count()
		remove_child(oldest)
		oldest.queue_free()
	var effect = (DEATH_FEEDBACK if kind == "death" else EVICTION_BURST).instantiate()
	effect.fragment_count = count
	add_child(effect)
	effect.global_position = origin

func _publish_snapshot() -> void:
	_update_carry_visual()
	for identity in bodies:
		bodies[identity].mark_oldest(identity == state.registry.oldest_id())
	room_snapshot_changed.emit(state.snapshot())

func request_interact(command_epoch: int, subject: int, body_id: String = "") -> void:
	if state.is_live(command_epoch, subject):
		_commands.append({"kind": "interact", "epoch": command_epoch, "subject_id": subject, "body_id": body_id})

func _pickup_nearest(requested_id: String = "") -> String:
	if not state.is_live(state.epoch, state.subject_id) or not state.held_body_id.is_empty():
		return "INVALID_STATE"
	var nearest := ""
	var distance := INF
	var found_in_reach := false
	for identity in state.registry.ordered_ids():
		if not state.registry.eligible(identity) or not bodies.has(identity) or (not requested_id.is_empty() and requested_id != identity):
			continue
		var prop: Corpse = bodies[identity]
		var separation := player.global_position.distance_to(prop.global_position)
		if separation > tuning.pickup_reach:
			continue
		found_in_reach = true
		var ray := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP * 0.75, prop.global_position, 7, [player.get_rid(), prop.get_rid()])
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		if separation < distance:
			distance = separation
			nearest = identity
	if nearest.is_empty():
		return "BLOCKED_PATH" if found_in_reach else "OUT_OF_REACH"
	var result := state.pickup(state.epoch, state.subject_id, nearest)
	if result == "ACCEPTED":
		bodies[nearest].disable_prop()
		_wake_bodies()
	return result

func _place_held() -> String:
	var identity := state.held_body_id
	var evaluation := PlacementEvaluator.evaluate(self, identity)
	placement_preview = evaluation
	placement_preview_changed.emit(evaluation.duplicate(true))
	if not evaluation.valid:
		return evaluation.reason
	var result := state.release(state.epoch, state.subject_id, identity)
	if result == "ACCEPTED":
		bodies[identity].release_at(evaluation.candidate_transform)
	return result

func _release_on_death(death_transform: Transform3D) -> void:
	var identity := state.held_body_id
	var prop: Corpse = bodies[identity]
	var new_pose := Transform3D(Basis.IDENTITY, death_transform.origin + Vector3.UP * (tuning.corpse_size.y * 0.5 + tuning.surface_clearance))
	var anchor: Vector3 = player.get_node("CarryAnchor").global_position
	var chosen := Transform3D.IDENTITY
	var found := false
	# A nearby expanding column preserves age and avoids the reserved new-corpse box.
	for height in range(12):
		for direction in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			var candidate := Transform3D(Basis.IDENTITY, anchor + direction * 1.4 + Vector3.UP * height * tuning.corpse_size.y)
			var reserved_overlap := absf(candidate.origin.x - new_pose.origin.x) < tuning.corpse_size.x and absf(candidate.origin.y - new_pose.origin.y) < tuning.corpse_size.y and absf(candidate.origin.z - new_pose.origin.z) < tuning.corpse_size.z
			if not reserved_overlap and PlacementEvaluator.overlap_reason(self, candidate, prop.get_rid()) == "VALID" and not is_reserved_pose(candidate):
				chosen = candidate
				found = true
				break
		if found:
			break
	if not found:
		# Do not discard or silently retain a held body on malformed geometry.
		push_error("No nonpenetrating death release space; room acceptance failure")
		chosen = Transform3D(Basis.IDENTITY, anchor + Vector3.UP * 6.0)
	state.release_for_death()
	prop.release_at(chosen)

func _wake_bodies() -> void:
	for prop in bodies.values():
		if state.registry.eligible(prop.body_id):
			prop.sleeping = false

func _sync_contacts() -> void:
	if state.phase == RoomState.Phase.RETIRED:
		return
	for saw in saws:
		saw.reconcile(self)
		puzzle_state_changed.emit(saw.hazard_id, {"jammed": saw.jammed(), "contributors": saw.contributors.keys()})
	for plate in plates:
		plate.reconcile(self)
		puzzle_state_changed.emit(plate.plate_id, {"weight": plate.weight(), "required": plate.required_weight, "active": plate.active()})
	for door in doors:
		var opened := door.linked_plate_id.is_empty()
		for plate in plates:
			if plate.plate_id == door.linked_plate_id:
				opened = plate.active()
		door.set_open(opened, player)

func is_reserved_pose(pose: Transform3D) -> bool:
	var half := tuning.corpse_size * 0.5
	# Conservative radius protects hatch and entry-side retreat regardless of body yaw.
	var radius := Vector2(half.x, half.z).length() + tuning.player_radius + 0.1
	var anchors: Array[Vector3] = [$Spawn.global_position]
	for door in doors:
		anchors.append(door.get_node("Retreat").global_position)
	for anchor in anchors:
		if Vector2(pose.origin.x - anchor.x, pose.origin.z - anchor.z).length() < radius and absf(pose.origin.y - anchor.y) < 2.0:
			return true
	return false

func _build_ghost() -> void:
	_ghost = Node3D.new()
	_ghost.name = "PlacementGhost"
	add_child(_ghost)
	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var box := BoxMesh.new()
	box.size = tuning.corpse_size
	mesh.mesh = box
	_ghost_material = StandardMaterial3D.new()
	_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = _ghost_material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ghost.add_child(mesh)
	var label := Label3D.new()
	label.name = "Label"
	label.position.y = tuning.corpse_size.y * 0.5 + 0.3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 36
	label.outline_size = 10
	_ghost.add_child(label)
	_ghost.visible = false

func _show_preview(result: Dictionary) -> void:
	if _ghost == null:
		return
	_ghost.visible = true
	_ghost.global_transform = result.candidate_transform
	_ghost_material.albedo_color = Color(0.1, 1, 0.7, 0.4) if result.valid else Color(1, 0.1, 0.4, 0.4)
	_ghost.get_node("Label").text = "✓ PLACE" if result.valid else "✕ BLOCKED"

func _update_carry_visual() -> void:
	if not is_instance_valid(player):
		return
	player.is_carrying_visual = not state.held_body_id.is_empty()
	var anchor: Node3D = player.get_node("CarryAnchor")
	var marker := anchor.get_node_or_null("OldestHeldMarker") as Label3D
	if marker == null:
		marker = Label3D.new()
		marker.name = "OldestHeldMarker"
		marker.position.y = 0.5
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.font_size = 40
		marker.text = "NEXT TO GO"
		marker.modulate = Color(1, 0.85, 0.05)
		anchor.add_child(marker)
	marker.visible = not state.held_body_id.is_empty() and state.held_body_id == state.registry.oldest_id()
	if state.held_body_id.is_empty():
		if is_instance_valid(_carry_visual):
			_carry_visual.queue_free()
		_carry_visual = null
		return
	if not is_instance_valid(_carry_visual):
		_carry_visual = bodies[state.held_body_id].get_node("Visual").duplicate()
		_carry_visual.name = "HeldVisual"
		player.get_node("CarryAnchor").add_child(_carry_visual)
