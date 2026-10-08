extends RefCounted
const SETUP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = SETUP.new()
	for trial in range(10):
		var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
		room.spawn_player = true
		h.root.add_child(room)
		var anvil: FallingAnvil = load("res://scenes/hazards/anvil.tscn").instantiate()
		anvil.position = Vector3(3, 0, 3)
		room.add_child(anvil)
		var body := helper.add_body(room, Vector3(3, 0.245, 3))
		await h.frames(30)
		h.check(anvil.warning and anvil.impact_count == 0, "US3.anvil_clear_warning.%d" % trial)
		room.player.position = Vector3(3, 0.7, 3)
		await h.frames(36)
		h.check(anvil.impact_count == 1 and not room.player.alive, "US3.anvil_warned_impact")
		await h.frames(180)
		h.check(anvil.impact_count == 2 and room.player.alive and room.state.subject_id == 2, "US3.anvil_repeatable_cycle")
		h.check(room.bodies.has(body.body_id) and absf(body.position.y - 0.225) < 0.04 and body.linear_velocity.length() < 0.1, "EC08.anvil_corpse_immunity_stability")
		var count := anvil.impact_count
		room.retire()
		await h.frames(190)
		h.check(anvil.impact_count == count, "EC09.anvil_retirement_cancels_cycle")
		room.queue_free()
		await h.frames(2)
