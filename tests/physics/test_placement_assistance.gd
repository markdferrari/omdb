extends RefCounted
const HELP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = HELP.new()
	for trial in range(10):
		for scenario in ["table_edge", "diagonal_edge", "raised_table", "second_body", "wall", "small_surface", "stale_preview"]:
			var room: RoomController = await helper.fixture(h)
			var identity := room.state.held_body_id
			var held: Corpse = room.bodies[identity]
			var plate: PressurePlate
			if scenario == "raised_table":
				helper.wall(room, Vector3(-3.4, 0.5, 0), Vector3(2.2, 1, 2.2))
			elif scenario == "small_surface":
				helper.wall(room, Vector3(-3.4, 0.05, 0), Vector3(0.3, 0.1, 0.3))
			else:
				plate = load("res://scenes/puzzle/pressure_plate.tscn").instantiate()
				plate.position = Vector3(-3.4, 0, 0.8)
				plate.required_weight = 2
				room.add_child(plate)
				if scenario == "diagonal_edge":
					room.player.facing = Vector3(1, 0, 1).normalized()
				elif scenario == "second_body":
					plate.position = Vector3(0, 0, -3)
					helper.add_body(room, Vector3(-0.95, 0.345, -3))
					room.remove_child(room.player)
					room.player.queue_free()
					room._spawn_subject()
					room.player.position = Vector3(2.25, 0.02, -3)
					room.player.facing = Vector3.LEFT
					room._publish_snapshot()
				elif scenario == "wall":
					helper.wall(room, Vector3(-4.2, 1.5, 0), Vector3(0.1, 3, 3))
			await h.frames(40)
			var nominal := room.player.global_position + room.player.facing * room.tuning.preview_distance
			var result := PlacementEvaluator.evaluate(room, identity)
			if scenario in ["wall", "small_surface"]:
				h.check(not result.valid, "DEV004.real_obstruction.%s.%d" % [scenario, trial])
			else:
				h.check(result.valid, "DEV004.intuitive_table.%s.%d" % [scenario, trial])
				h.check(Vector2(result.candidate_transform.origin.x - nominal.x, result.candidate_transform.origin.z - nominal.z).length() <= 0.601, "DEV004.bounded_adjustment")
				var forward: Vector3 = result.candidate_transform.basis.x
				h.check(forward.dot(room.player.facing) > 0.999, "DEV004.continuous_facing_yaw")
			if scenario == "stale_preview":
				helper.wall(room, result.candidate_transform.origin + Vector3.UP * 0.5, Vector3(2.5, 2, 2.5))
				await h.frames(2)
			room.request_interact(room.state.epoch, room.state.subject_id)
			await h.frames(2)
			if scenario in ["wall", "small_surface", "stale_preview"]:
				h.check(room.state.held_body_id == identity and held.freeze and held.collision_layer == 0 and held.get_node("Shape").disabled, "DEV004.invalid_still_held.%s" % scenario)
			else:
				h.check(room.state.held_body_id.is_empty() and room.last_interaction_result == "ACCEPTED", "DEV004.table_release.%s" % scenario)
				h.check(Vector2(held.position.x - result.candidate_transform.origin.x, held.position.z - result.candidate_transform.origin.z).length() < 0.03, "DEV004.preview_matches_release")
				await h.frames(60)
				h.check(absf(held.position.y - (1.225 if scenario == "raised_table" else 0.345)) < 0.04 and held.linear_velocity.length() < 0.1, "DEV004.table_rest_stable.%s" % scenario)
				if scenario == "second_body":
					h.check(plate.weight() == 2 and plate.active(), "DEV004.two_direct_table_units")
			await helper.dispose(h, room)
