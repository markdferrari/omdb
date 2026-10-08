extends RefCounted

func add_body(room: RoomController, point: Vector3) -> Corpse:
	var result := room.state.create_corpse(Transform3D(Basis.IDENTITY, point))
	var body: Corpse = room.CORPSE_SCENE.instantiate()
	body.body_id = result.body_id
	body.epoch = room.state.epoch
	body.position = point
	room.bodies[body.body_id] = body
	room.add_child(body)
	return body

func wall(room: RoomController, point: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = point
	body.collision_layer = 1
	body.collision_mask = 6
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	collision.shape = box
	body.add_child(collision)
	room.add_child(body)
	return body

func fixture(h: SceneTree) -> RoomController:
	var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
	room.spawn_player = true
	h.root.add_child(room)
	room.player.facing = Vector3.RIGHT
	add_body(room, Vector3(-3.7, 0.245, 0))
	await h.frames(40)
	room.request_interact(room.state.epoch, room.state.subject_id)
	await h.frames(2)
	h.check(room.last_interaction_result == "ACCEPTED" and room.state.registry.count() == 1 and not room.state.held_body_id.is_empty(), "US2.scene_pickup")
	return room

func dispose(h: SceneTree, room: RoomController) -> void:
	room.retire()
	room.queue_free()
	await h.frames(2)

func run(h: SceneTree) -> void:
	for trial in range(10):
		for surface in ["floor", "body", "spikes"]:
			var room := await fixture(h)
			var identity := room.state.held_body_id
			if surface == "body":
				add_body(room, Vector3(-3.4, 0.245, 0))
			elif surface == "spikes":
				var spikes: SpikeBed = load("res://scenes/hazards/spike_bed.tscn").instantiate()
				spikes.position = Vector3(-3.4, 0.1, 0)
				for path in ["Bed/Shape", "Lethal/Shape"]:
					var shape: BoxShape3D = spikes.get_node(path).shape.duplicate()
					shape.size.x = 1.9
					shape.size.z = 2
					spikes.get_node(path).shape = shape
				room.add_child(spikes)
			await h.frames(45)
			var result := PlacementEvaluator.evaluate(room, identity)
			h.check(result.valid, "SC006.valid.%s.%d" % [surface, trial])
			if surface == "floor":
				var nominal := room.player.global_position + room.player.facing * room.tuning.preview_distance
				h.check(Vector2(result.candidate_transform.origin.x - nominal.x, result.candidate_transform.origin.z - nominal.z).length() < 0.001, "DEV004.valid_aim_unchanged")
			var held: Corpse = room.bodies[identity]
			h.check(held.freeze and held.collision_layer == 0 and held.collision_mask == 0 and held.get_node("Shape").disabled, "US2.held_has_no_physics")
			room.request_interact(room.state.epoch, room.state.subject_id)
			await h.frames(2)
			h.check(room.last_interaction_result == "ACCEPTED" and room.state.held_body_id.is_empty(), "US2.valid_release")
			h.check(held.collision_layer == 4 and held.collision_mask == 7 and not held.freeze and not held.get_node("Shape").disabled, "US2.restore_collision")
			h.check(Vector2(held.position.x - result.candidate_transform.origin.x, held.position.z - result.candidate_transform.origin.z).length() < 0.03, "SC006.preview_matches_commit")
			await h.frames(45)
			h.check(absf(held.position.y - (result.candidate_transform.origin.y - room.tuning.surface_clearance)) < 0.04 and held.linear_velocity.length() < 0.1, "SC006.stable_release")
			await dispose(h, room)
		var room := await fixture(h)
		var identity := room.state.held_body_id
		var held: Corpse = room.bodies[identity]
		var snapshot := room.state.snapshot()
		h.check(PlacementEvaluator.evaluate(room, identity, Vector3(-2, 0, 0)).reason == "OUT_OF_REACH", "SC006.reject_reach")
		h.check(PlacementEvaluator.evaluate(room, identity, room.player.global_position).reason == "PLAYER_OVERLAP", "SC006.reject_player")
		h.check(PlacementEvaluator.overlap_reason(room, Transform3D(Basis.IDENTITY, Vector3(-3.4, -0.1, 0)), held.get_rid()) == "WORLD_OVERLAP", "SC006.reject_world_volume")
		var support := add_body(room, Vector3(-3.4, 0.245, 0))
		await h.frames(40)
		h.check(PlacementEvaluator.overlap_reason(room, support.global_transform, held.get_rid()) == "BODY_OVERLAP", "SC006.reject_body_volume")
		support.linear_velocity = Vector3(0.2, 0, 0)
		h.check(PlacementEvaluator.evaluate(room, identity).reason == "UNSTABLE_SUPPORT", "SC006.reject_moving_support")
		h.check(room.state.held_body_id == identity and held.freeze, "SC006.moving_support_keeps_held")
		room.state.remove_body(support.body_id)
		room._remove_prop(support.body_id)
		await h.frames(2)
		var valid := PlacementEvaluator.evaluate(room, identity)
		h.check(valid.valid, "SC006.preview_initially_valid")
		wall(room, Vector3(-4.2, 1.5, 0), Vector3(0.1, 3, 0.9))
		await h.frames(2)
		h.check(PlacementEvaluator.evaluate(room, identity).reason == "BLOCKED_PATH", "SC006.reject_blocked_path")
		room.request_interact(room.state.epoch, room.state.subject_id)
		await h.frames(2)
		h.check(room.last_interaction_result == "BLOCKED_PATH" and room.state.held_body_id == identity and held.freeze and held.collision_layer == 0 and room.state.registry.oldest_id() == snapshot.oldest_id, "SC006.stale_preview_keeps_held")
		await dispose(h, room)
		room = await fixture(h)
		identity = room.state.held_body_id
		var floor_node := room.get_node("Floor") as StaticBody3D
		var floor_shape: BoxShape3D = floor_node.get_node("Shape").shape.duplicate()
		floor_shape.size.x = 1
		floor_node.get_node("Shape").shape = floor_shape
		floor_node.position.x = -5
		await h.frames(2)
		var missing_result := PlacementEvaluator.evaluate(room, identity)
		h.check(missing_result.reason == "NO_SUPPORT", "SC006.reject_missing_support")
		wall(room, Vector3(-3.4, 0.05, 0), Vector3(0.3, 0.1, 0.3))
		await h.frames(2)
		h.check(PlacementEvaluator.evaluate(room, identity).reason == "UNSTABLE_SUPPORT", "SC006.reject_incomplete_footprint")
		room.request_interact(room.state.epoch, room.state.subject_id)
		await h.frames(2)
		h.check(room.state.held_body_id == identity and room.state.registry.count() == 1, "SC006.invalid_support_keeps_held")
		await dispose(h, room)
