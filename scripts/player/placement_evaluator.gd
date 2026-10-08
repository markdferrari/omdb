class_name PlacementEvaluator
extends RefCounted
## The preview and the release command use the same physics-step evaluator.
static func evaluate(room: RoomController, body_id: String, target: Vector3 = Vector3.INF) -> Dictionary:
	if not room.state.is_live(room.state.epoch, room.state.subject_id) or room.state.held_body_id != body_id or not room.bodies.has(body_id):
		return _evaluate_at(room, body_id, Vector3.ZERO)
	var point := room.player.global_position + room.player.facing.normalized() * room.tuning.preview_distance if target == Vector3.INF else target
	var result := _evaluate_at(room, body_id, point)
	if target != Vector3.INF or result.valid or result.reason not in ["NO_SUPPORT", "UNSTABLE_SUPPORT", "BODY_OVERLAP"]:
		return result
	for candidate in _assisted_points(room, body_id, point):
		var adjusted := _evaluate_at(room, body_id, candidate)
		if adjusted.valid:
			return adjusted
	return result

static func _assisted_points(room: RoomController, body_id: String, point: Vector3) -> Array[Vector3]:
	var candidates: Array[Vector3] = []
	var tuning := room.tuning
	var radius := tuning.placement_assist_distance
	var yaw := atan2(-room.player.facing.z, room.player.facing.x)
	var basis := Basis(Vector3.UP, yaw)
	var query := PhysicsShapeQueryParameters3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(tuning.corpse_size.x + radius * 2, tuning.player_height + 2, tuning.corpse_size.x + radius * 2)
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, point)
	query.collision_mask = 5
	query.exclude = [room.bodies[body_id].get_rid()]
	for hit in room.get_world_3d().direct_space_state.intersect_shape(query, 32):
		for child in hit.collider.get_children():
			if not child is CollisionShape3D or child.disabled or not child.shape is BoxShape3D:
				continue
			var support: CollisionShape3D = child
			if support.global_basis.y.normalized().dot(Vector3.UP) < tuning.support_normal:
				continue
			var extent: Vector3 = support.shape.size * 0.5
			var top := support.global_transform * Vector3(0, extent.y, 0)
			if top.y > room.player.global_position.y + tuning.player_height or top.y < room.player.global_position.y - 1:
				continue
			var footprint := Vector2.ZERO
			for x in [-1, 1]:
				for z in [-1, 1]:
					var corner: Vector3 = support.global_basis.inverse() * basis * Vector3(tuning.corpse_size.x * x * 0.5, 0, tuning.corpse_size.z * z * 0.5)
					footprint.x = maxf(footprint.x, absf(corner.x))
					footprint.y = maxf(footprint.y, absf(corner.z))
			var available := Vector2(extent.x, extent.z) - footprint
			if available.x < -0.001 or available.y < -0.001:
				continue
			available = available.max(Vector2.ZERO)
			var local := support.global_transform.affine_inverse() * point
			var nearest := Vector2(clampf(local.x, -available.x, available.x), clampf(local.z, -available.y, available.y))
			# Project onto the usable support rectangle, including nearby alternatives
			# for occupied/reserved spots. Every candidate retains continuous facing yaw.
			var xs: Array[float] = [nearest.x, -available.x, available.x, clampf(nearest.x - radius * 0.5, -available.x, available.x), clampf(nearest.x + radius * 0.5, -available.x, available.x)]
			var zs: Array[float] = [nearest.y, -available.y, available.y, clampf(nearest.y - radius * 0.5, -available.y, available.y), clampf(nearest.y + radius * 0.5, -available.y, available.y)]
			for x in xs:
				for z in zs:
					var candidate := support.global_transform * Vector3(x, extent.y, z)
					candidate.y = point.y
					if candidate.distance_to(point) <= radius + 0.001 and not candidates.has(candidate):
						candidates.append(candidate)
	candidates.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.distance_squared_to(point) < b.distance_squared_to(point))
	return candidates

static func _evaluate_at(room: RoomController, body_id: String, point: Vector3) -> Dictionary:
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
		if heights.is_empty():
			pose.origin.y = hit.position.y + half.y + tuning.surface_clearance
			result.candidate_transform = pose
		heights.append(hit.position.y)
		result.support_ids.append(hit.collider.get_instance_id())
	if heights.max() - heights.min() > tuning.support_height_tolerance:
		return _reject(result, "UNSTABLE_SUPPORT")
	pose.origin.y = heights.max() + half.y + tuning.surface_clearance
	result.candidate_transform = pose
	if pose.origin.distance_to(actor.global_position) > tuning.placement_reach:
		return _reject(result, "OUT_OF_REACH")
	# Lift from the carry anchor, traverse above the surface, then lower into place.
	# Actor exclusion applies only to transport; endpoint still checks its full volume.
	var carry := actor.global_position + Vector3.UP * 1.2
	var lift_y := maxf(carry.y, pose.origin.y + half.y + tuning.surface_clearance)
	var route: Array[Vector3] = [carry, Vector3(carry.x, lift_y, carry.z), Vector3(pose.origin.x, lift_y, pose.origin.z), pose.origin]
	for index in range(route.size() - 1):
		if route[index].distance_squared_to(route[index + 1]) < 0.000001:
			continue
		var path := PhysicsRayQueryParameters3D.create(route[index], route[index + 1], 7, [held.get_rid(), actor.get_rid()])
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
