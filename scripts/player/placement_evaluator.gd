class_name PlacementEvaluator
extends RefCounted
## The preview and the release command use the same physics-step evaluator.
static func evaluate(room: RoomController, body_id: String, target: Vector3 = Vector3.INF) -> Dictionary:
	var result := {"epoch": room.state.epoch, "subject_id": room.state.subject_id,
		"body_id": body_id, "valid": false, "reason": "STALE_REQUEST",
		"candidate_transform": Transform3D.IDENTITY, "support_ids": [],
		"sampled_physics_tick": Engine.get_physics_frames()}
	if not room.state.is_live(room.state.epoch, room.state.subject_id) or room.state.held_body_id != body_id or not room.bodies.has(body_id):
		return result
	var actor := room.player
	var tuning := room.tuning
	var facing := actor.facing.normalized()
	var yaw := atan2(-facing.z, facing.x)
	var basis := Basis(Vector3.UP, yaw)
	var point := actor.global_position + facing * tuning.preview_distance if target == Vector3.INF else target
	var pose := Transform3D(basis, point)
	result.candidate_transform = pose
	if Vector2(point.x - actor.global_position.x, point.z - actor.global_position.z).length() > tuning.placement_reach:
		return _reject(result, "OUT_OF_REACH")
	var space := room.get_world_3d().direct_space_state
	var held: Corpse = room.bodies[body_id]
	var half := tuning.corpse_size * 0.5
	var offsets: Array[Vector3] = [Vector3.ZERO]
	for x in [-1, 1]:
		for z in [-1, 1]:
			offsets.append(Vector3(half.x * x * 0.8, 0, half.z * z * 0.8))
	var heights: Array[float] = []
	for offset in offsets:
		var probe := point + basis * offset
		probe.y = actor.global_position.y + tuning.player_height
		var query := PhysicsRayQueryParameters3D.create(probe, probe + Vector3.DOWN * (tuning.player_height + 1.0), 5, [held.get_rid()])
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			return _reject(result, "NO_SUPPORT" if heights.is_empty() else "UNSTABLE_SUPPORT")
		if hit.normal.dot(Vector3.UP) < tuning.support_normal:
			return _reject(result, "UNSTABLE_SUPPORT")
		if hit.collider is RigidBody3D and hit.collider.linear_velocity.length() > 0.15:
			return _reject(result, "UNSTABLE_SUPPORT")
		heights.append(hit.position.y)
		result.support_ids.append(hit.collider.get_instance_id())
	if heights.max() - heights.min() > tuning.support_height_tolerance:
		return _reject(result, "UNSTABLE_SUPPORT")
	pose.origin.y = heights.max() + half.y + tuning.surface_clearance
	result.candidate_transform = pose
	if pose.origin.distance_to(actor.global_position) > tuning.placement_reach:
		return _reject(result, "OUT_OF_REACH")
	# Start inside the actor is deliberately excluded for transport; endpoint is not.
	var path := PhysicsRayQueryParameters3D.create(actor.global_position + Vector3.UP * 0.8, pose.origin, 7, [held.get_rid(), actor.get_rid()])
	if not space.intersect_ray(path).is_empty():
		return _reject(result, "BLOCKED_PATH")
	var overlap := overlap_reason(room, pose, held.get_rid())
	if overlap != "VALID":
		return _reject(result, overlap)
	if room.is_reserved_pose(pose):
		return _reject(result, "WORLD_OVERLAP")
	result.valid = true
	result.reason = "VALID"
	return result

static func overlap_reason(room: RoomController, pose: Transform3D, excluded: RID) -> String:
	var shape := BoxShape3D.new()
	shape.size = room.tuning.corpse_size
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = pose
	query.collision_mask = 7
	query.margin = 0.0
	query.exclude = [excluded]
	var hits := room.get_world_3d().direct_space_state.intersect_shape(query, 64)
	var reason := "VALID"
	for hit in hits:
		if hit.collider is PlayerController:
			return "PLAYER_OVERLAP"
		if hit.collider is Corpse:
			reason = "BODY_OVERLAP"
		elif reason != "BODY_OVERLAP":
			reason = "WORLD_OVERLAP"
	return reason

static func _reject(result: Dictionary, reason: String) -> Dictionary:
	result.reason = reason
	return result
