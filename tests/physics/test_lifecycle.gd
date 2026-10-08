extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var fixture: RoomController = load("res://tests/scenes/greybox_room.tscn").instantiate()
		h.root.add_child(fixture)
		await h.frames(2)
		for death in range(7):
			var old_subject := fixture.state.subject_id
			var epoch := fixture.state.epoch
			var death_pose := fixture.player.global_transform
			# A contact emits twice during the same physics dispatch, then a stale subject emits.
			h.check(fixture.request_death(epoch, old_subject, "spikes", death_pose) == "ACCEPTED", "EC01.scene_first_contact")
			h.check(fixture.request_death(epoch, old_subject, "overlap", death_pose) == "IGNORED_DUPLICATE", "EC01.scene_duplicate_contact")
			h.check(not fixture.player.alive, "US1.scene_immediate_ineligibility")
			await h.frames(2)
			h.check(fixture.state.registry.count() == mini(death + 1, 5) and fixture.bodies.size() == mini(death + 1, 5), "EC02.scene_cap")
			h.check(fixture.player.collision_layer == 0 and fixture.player.get_node("Shape").disabled, "US1.scene_dead_shape_disabled")
			# Give each generated prop separated safe diagnostic space, before it contacts another.
			var latest: Corpse = fixture.bodies[fixture.state.registry.ordered_ids()[-1]]
			h.check(absf(latest.position.x - death_pose.origin.x) < 0.04, "US1.scene_death_location")
			latest.freeze = true
			latest.position = Vector3(-4 + death, 0.23, 4)
			latest.freeze = false
			await h.frames(50)
			h.check(fixture.player.alive and fixture.player.position.distance_to(fixture.get_node("Spawn").position) < 0.1 and fixture.state.subject_id == old_subject + 1, "US1.scene_safe_replacement")
			h.check(fixture.request_death(epoch, old_subject, "stale", death_pose) == "IGNORED_STALE", "US1.scene_stale_contact")
			var live_count := 0
			for child in fixture.get_children():
				if child is PlayerController:
					live_count += 1
			h.check(live_count == 1, "US1.scene_exactly_one_subject")
			for identity in fixture.bodies:
				h.check(fixture.bodies[identity].get_node("OldestMarker").visible == (identity == fixture.state.registry.oldest_id()), "US1.scene_oldest_marker")
		fixture.retire()
		fixture.queue_free()
		await h.frames(2)
