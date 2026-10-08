extends RefCounted

func _world_input(actor: PlayerController, direction: Vector3) -> void:
	var right := actor.camera.global_basis.x
	right.y = 0
	right = right.normalized()
	var forward := Vector3.UP.cross(right)
	actor.use_movement_override = true
	actor.movement_override = Vector2(direction.dot(right), -direction.dot(forward))

func _jump(actor: PlayerController) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_SPACE
	event.pressed = true
	actor.queue_jump(event)

func run(h: SceneTree) -> void:
	for trial in range(10):
		var fixture: RoomController = load("res://tests/scenes/greybox_room.tscn").instantiate()
		h.root.add_child(fixture)
		await h.frames(30)
		# Sacrifice by making one ordinary jump from the near side toward the middle.
		_world_input(fixture.player, Vector3.RIGHT)
		for _frame in range(90):
			if fixture.player.position.x >= -2.65:
				break
			await h.frames(1)
		_jump(fixture.player)
		for _frame in range(120):
			if fixture.state.phase == RoomState.Phase.DEATH_FEEDBACK:
				break
			await h.frames(1)
		await h.frames(2) # Contact latch precedes the deferred physical death commit.
		h.check(fixture.state.registry.count() == 1, "US1.bridge.sacrifice.%d" % trial)
		await h.frames(55)
		# Rebuild from a fresh room every trial; use only the actual hazard-created prop.
		_world_input(fixture.player, Vector3.RIGHT)
		for _frame in range(90):
			if fixture.player.position.x >= -2.65:
				break
			await h.frames(1)
		_jump(fixture.player)
		for _frame in range(32):
			await h.frames(1)
			if fixture.player.is_on_floor() and fixture.player.position.y > 0.3:
				break
		# Advance across the broad prop top, then one forgiving jump to the far bank.
		for _frame in range(20):
			if fixture.player.position.x >= 0.45:
				break
			await h.frames(1)
		_jump(fixture.player)
		await h.frames(48)
		_world_input(fixture.player, Vector3.ZERO)
		h.check(fixture.player.alive and fixture.state.subject_id == 2 and fixture.player.position.x > 2.12 and fixture.player.is_on_floor(), "US1.bridge.fresh_traversal.%d" % trial)
		h.check(fixture.state.registry.count() == 1, "US1.bridge.one_body_budget")
		fixture.retire()
		fixture.queue_free()
		await h.frames(2)
