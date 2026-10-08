extends RefCounted
const SETUP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = SETUP.new()
	for trial in range(10):
		for role in ["held", "support", "plate", "saw"]:
			var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
			room.spawn_player = true
			h.root.add_child(room)
			var plate: PressurePlate
			var saw: Buzzsaw
			if role == "plate":
				plate = load("res://scenes/puzzle/pressure_plate.tscn").instantiate()
				plate.position = Vector3(3, 0, 3)
				room.add_child(plate)
			if role == "saw":
				saw = load("res://scenes/hazards/buzzsaw.tscn").instantiate()
				saw.position = Vector3(3, 0, 3)
				room.add_child(saw)
			var first := helper.add_body(room, Vector3(3, 0.38 if role == "plate" else 0.245, 3))
			var oldest := first.body_id
			var upper: Corpse
			if role == "support":
				upper = helper.add_body(room, Vector3(3, 0.72, 3))
			while room.state.registry.count() < 5:
				helper.add_body(room, Vector3(-6 + room.state.registry.count() * 2.0, 0.245, -3))
			await h.frames(60)
			if role == "held":
				room.state.pickup(room.state.epoch, room.state.subject_id, oldest)
				first.disable_prop()
				room._publish_snapshot()
				h.check(room.player.get_node("CarryAnchor/OldestHeldMarker").visible, "FR014.held_oldest_visible")
			if role == "plate":
				h.check(plate.active(), "EC07.plate_before_eviction")
			if role == "saw":
				h.check(saw.jammed(), "EC14.saw_before_eviction")
			room.request_death(room.state.epoch, room.state.subject_id, "fixture", room.player.global_transform)
			await h.frames(2)
			h.check(room.state.registry.count() == 5 and room.bodies.size() == 5 and not room.bodies.has(oldest), "US3.physical_fifo.%s.%d" % [role, trial])
			h.check(room.state.held_body_id.is_empty(), "US3.fifo_clears_carry")
			var bursts := room.find_children("EvictionBurst*", "Node3D", false, false)
			h.check(bursts.size() == 1 and bursts[0].find_children("*", "CollisionObject3D", true, false).is_empty(), "FR015.cosmetic_eviction_only")
			if role == "plate":
				h.check(not plate.active() and plate.weight() == 0, "EC07.fifo_plate_immediate")
			if role == "saw":
				h.check(not saw.jammed(), "EC14.fifo_saw_immediate")
			await h.frames(60)
			if role == "support":
				h.check(absf(upper.position.y - 0.225) < 0.04, "EC06.fifo_stack_settles")
			await helper.dispose(h, room)
