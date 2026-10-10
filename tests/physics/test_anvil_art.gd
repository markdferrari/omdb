extends RefCounted
const INVENTORY := preload("res://scripts/checks/art_inventory.gd")
func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://scenes/art/hazards/anvil_visual.tscn"):
		h.check(false, "ART.anvil_missing")
		return
	for trial in range(10):
		var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
		h.root.add_child(room)
		var anvil: FallingAnvil = load("res://scenes/hazards/anvil.tscn").instantiate()
		anvil.set("cosmetic_scene", load("res://scenes/art/hazards/anvil_visual.tscn"))
		room.add_child(anvil)
		var visual := anvil.get_node_or_null("Cosmetic")
		h.check(visual != null, "ART.anvil_hookup")
		if visual != null:
			var model: Node3D = visual.get_node("Model")
			for phase in [0.0, .85, .925, 1.0, 1.2, 1.7, 2.2, 2.9]:
				visual.set_phase(phase, 1.0, 3.0)
				var expected := 0.0 if phase >= 1 and phase <= 1.2 else 2.7
				if is_equal_approx(phase, .925) or is_equal_approx(phase, 1.7):
					expected = 1.35
				h.check(absf(model.position.y-expected) < .001, "ART.anvil_phase.%s" % phase)
			visual.set_phase(1, 1, 3)
			var box: AABB = INVENTORY.inspect(model).bounds
			h.check(absf(box.position.y) < .001 and box.position.x >= -1 and box.end.x <= 1 and box.position.z >= -1 and box.end.z <= 1 and INVENTORY.inspect(visual).forbidden.is_empty(), "ART.anvil_pivot_footprint")
			anvil.elapsed = .99
			anvil._physics_process(.02)
			h.check(anvil.impact_count == 1 and model.position.y == 0, "ART.anvil_owner_strike_agreement")
			h.paused = true
			var paused_pose := model.transform
			var paused_elapsed := anvil.elapsed
			for frame in range(3):
				await h.process_frame
			h.check(model.transform == paused_pose and anvil.elapsed == paused_elapsed, "ART.anvil_pause")
			h.paused = false
			anvil.elapsed = 0
			anvil._last_cycle = -1
			anvil.impact_count = 0
			anvil._physics_process(2.5)
			h.check(is_equal_approx(model.position.y, 2.7) and anvil.impact_count == 1, "ART.anvil_skipped_phase_no_replayed_pose")
			room.retire()
			var pose := model.transform
			anvil._physics_process(4)
			h.check(model.transform == pose and anvil.impact_count == 1, "ART.anvil_retired_no_update")
		room.queue_free()
		await h.frames(2)
