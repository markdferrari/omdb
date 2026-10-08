extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var fixture: RoomController = load("res://tests/scenes/greybox_room.tscn").instantiate()
		h.root.add_child(fixture)
		var lower: Corpse = load("res://scenes/corpses/corpse.tscn").instantiate()
		lower.position = Vector3(0, 0.3, 0)
		fixture.add_child(lower)
		var upper: Corpse = load("res://scenes/corpses/corpse.tscn").instantiate()
		upper.position = Vector3(0, 0.8, 0)
		fixture.add_child(upper)
		await h.frames(60)
		h.check(absf(lower.position.y - 0.225) < 0.04 and absf(upper.position.y - 0.675) < 0.06, "US1.support.stack.%d" % trial)
		# Stand and move on the released body above the real shallow spike sensor.
		fixture.player.position = Vector3(-0.45, 1.2, 0)
		await h.frames(30)
		h.check(fixture.player.alive and fixture.player.is_on_floor(), "EC14.body_supported_spikes")
		var supported_height: float = fixture.player.position.y
		fixture.player.use_movement_override = true
		fixture.player.movement_override = Vector2.RIGHT * 0.3
		await h.frames(10)
		h.check(fixture.player.alive and fixture.player.position.y >= supported_height - 0.06, "US1.support.body_traversal")
		fixture.player.movement_override = Vector2.ZERO
		# Remove the traversal actor before testing support loss. Teleporting a live
		# kinematic collider away from a contact injects an artificial solver velocity.
		fixture.player.disable_actor.call_deferred()
		await h.frames(2)
		# Disable and wake at the same safe boundary used by controller eviction.
		lower.disable_prop.call_deferred()
		upper.set_deferred("sleeping", false)
		await h.frames(60)
		h.check(absf(upper.position.y - 0.225) < 0.04, "EC06.support_removal_settles")
		h.check(is_instance_valid(upper), "EC08.corpse_survives_spikes")
		fixture.remove_child(fixture.player)
		fixture.player.queue_free()
		fixture._spawn_subject()
		fixture.player.position = Vector3(1.3, 0.01, 0)
		await h.frames(4)
		h.check(fixture.state.phase == RoomState.Phase.DEATH_FEEDBACK and fixture.state.registry.count() == 1, "US1.exposed_spikes_lethal")
		await h.frames(50)
		h.check(fixture.state.phase == RoomState.Phase.ACTIVE and fixture.state.subject_id == 2, "US1.spike_replacement")
		fixture.retire()
		fixture.queue_free()
		await h.frames(2)
