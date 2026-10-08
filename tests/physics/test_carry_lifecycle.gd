extends RefCounted
const SETUP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = SETUP.new()
	for trial in range(10):
		for age in [0, 3]:
			var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
			room.spawn_player = true
			h.root.add_child(room)
			for index in range(5):
				helper.add_body(room, Vector3(-4, 0.245, 0) if index == age else Vector3(-6 + index * 2, 0.245, 4))
			await h.frames(45)
			var order := room.state.registry.ordered_ids()
			room.request_interact(room.state.epoch, room.state.subject_id, order[age])
			await h.frames(2)
			h.check(room.state.held_body_id == order[age], "EC04.scene_held_age.%d.%d" % [trial, age])
			room.request_death(room.state.epoch, room.state.subject_id, "test", room.player.global_transform)
			await h.frames(2)
			h.check(room.state.held_body_id.is_empty() and room.state.registry.count() == 5 and room.bodies.size() == 5 and not room.bodies.has(order[0]), "EC04.scene_death_cap_clears")
			if age != 0:
				var released: Corpse = room.bodies[order[age]]
				h.check(not released.freeze and released.collision_layer == 4 and not released.get_node("Shape").disabled, "EC04.scene_newer_body_preserved")
			await h.frames(55)
			h.check(room.state.phase == RoomState.Phase.ACTIVE and room.player.alive and room.state.subject_id == 2, "EC04.scene_replacement")
			await helper.dispose(h, room)
