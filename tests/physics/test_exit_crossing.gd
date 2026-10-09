extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
		room.spawn_player = true
		h.root.add_child(room)
		var door: ExitDoor = load("res://scenes/puzzle/exit_door.tscn").instantiate()
		door.position = Vector3(5, 0, 0)
		door.linked_plate_id = ""
		room.add_child(door)
		var events: Array = []
		room.room_completed.connect(func(epoch: int, identity: String): events.append([epoch, identity]))
		await h.frames(2)
		h.check(room.request_exit(room.state.epoch, room.state.subject_id, door.exit_id) == "INVALID_STATE", "US5.exit_requires_crossing_evidence")
		room.player.position = Vector3(4.9, 0, 0)
		await h.frames(2)
		h.check(events.is_empty(), "US5.entry_side_does_not_complete.%d" % trial)
		room.player.position = Vector3(5.4, 0, 0)
		await h.frames(3)
		h.check(events.size() == 1 and room.state.exit_consumed, "US5.real_open_crossing_once")
		room.player.position = Vector3(4.9, 0, 0)
		await h.frames(2)
		room.player.position = Vector3(5.4, 0, 0)
		await h.frames(3)
		h.check(events.size() == 1, "EC13.duplicate_crossing_ignored")
		room.retire()
		room.queue_free()
		await h.frames(2)
		for scenario in ["closed", "outside", "dead", "simultaneous_death", "retired", "reverse", "closes_before_commit"]:
			room = load("res://tests/scenes/physics_fixture.tscn").instantiate()
			room.spawn_player = true
			h.root.add_child(room)
			door = load("res://scenes/puzzle/exit_door.tscn").instantiate()
			door.position = Vector3(5, 0, 0)
			door.linked_plate_id = "missing" if scenario == "closed" else ""
			room.add_child(door)
			if scenario == "reverse":
				room.player.position = Vector3(5.4, 0, 0)
			await h.frames(2)
			room.player.position = Vector3(5.4 if scenario == "reverse" else 4.9, 0, 3 if scenario == "outside" else 0)
			door._physics_process(0)
			if scenario == "dead":
				room.player.alive = false
			room.player.position.x = 4.9 if scenario == "reverse" else 5.4
			door._physics_process(0)
			if scenario == "simultaneous_death":
				room.request_death(room.state.epoch, room.state.subject_id, "fixture", room.player.global_transform)
			elif scenario == "retired":
				room.retire()
			elif scenario == "closes_before_commit":
				door.linked_plate_id = "missing"
				room._sync_contacts()
			await h.frames(3)
			h.check(not room.state.exit_consumed, "US5.reject_exit.%s.%d" % [scenario, trial])
			room.retire()
			room.queue_free()
			await h.frames(2)
