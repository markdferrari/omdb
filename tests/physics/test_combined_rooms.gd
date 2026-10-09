extends RefCounted
const MOTION := preload("res://tests/physics/test_bridge.gd")
var motion = MOTION.new()

func _pose(h: SceneTree, room: RoomController, point: Vector3, facing: Vector3 = Vector3.RIGHT) -> void:
	motion._world_input(room.player, Vector3.ZERO)
	# Disable contacts over the staging teleport; a kinematic teleport otherwise
	# imparts an artificial high velocity to props on the old/new footprint.
	room.player.collision_layer = 0
	room.player.collision_mask = 0
	room.player.get_node("Shape").disabled = true
	await h.frames(2)
	room.player.position = point
	room.player.velocity = Vector3.ZERO
	room.player.facing = facing
	room.player.reset_physics_interpolation()
	await h.frames(2)
	room.player.collision_layer = 2
	room.player.collision_mask = 5
	room.player.get_node("Shape").disabled = false
	await h.frames(12)

func _sacrifice(h: SceneTree, room: RoomController, number: int) -> String:
	var previous := room.state.subject_id
	var point: Vector3 = room.get_node("SupplySpikes").position if number == 2 else room.get_node("Anvil").position
	await _pose(h, room, point)
	for frame in range(240):
		if not room.player.alive:
			break
		await h.frames(1)
	await h.frames(2)
	var identity: String = room.state.registry.ordered_ids().back() if room.state.registry.count() > 0 else ""
	await h.frames(45)
	h.check(room.player.alive and room.state.subject_id == previous + 1 and not identity.is_empty(), "US5.room%d.real_hazard_sacrifice" % number)
	return identity

func _pick(h: SceneTree, room: RoomController, identity: String) -> void:
	if identity.is_empty() or not room.bodies.has(identity):
		h.check(false, "US5.solution_body_exists")
		return
	var body: Corpse = room.bodies[identity]
	# Stage the subject on the safe side; corpses are always hazard-created and
	# transported through the real pickup/preview/release command boundary.
	var point := body.position + Vector3(0, 0, 1.65)
	point.y = 0.05
	await _pose(h, room, point)
	room.request_interact(room.state.epoch, room.state.subject_id, identity)
	await h.frames(3)
	h.check(room.state.held_body_id == identity, "US5.solution_real_pickup")

func _place(h: SceneTree, room: RoomController, point: Vector3, facing: Vector3 = Vector3.RIGHT) -> void:
	await _pose(h, room, point, facing)
	var result := PlacementEvaluator.evaluate(room, room.state.held_body_id)
	h.check(result.valid, ("US5.%s.valid_placement.%s.%s" % [room.definition.room_id, point, result.reason]).replace(" ", ""))
	room.request_interact(room.state.epoch, room.state.subject_id)
	await h.frames(35)
	h.check(room.state.held_body_id.is_empty(), "US5.solution_real_release")

func _traverse(h: SceneTree, room: RoomController, number: int) -> void:
	var start := -4.22 if number == 4 else -2.35
	await _pose(h, room, Vector3(start, 0.05 if number == 4 else 0.5, 0))
	var landings: Array = [-2.5, -0.1, 2.3] if number == 4 else [-0.5, 2.0]
	for centre in landings:
		motion._world_input(room.player, Vector3.RIGHT)
		motion._jump(room.player)
		for frame in range(65):
			if room.player.position.x >= float(centre):
				motion._world_input(room.player, Vector3.ZERO)
			if frame > 10 and room.player.is_on_floor():
				break
			await h.frames(1)
		await h.frames(8)
		h.check(room.player.alive and room.player.position.y > 0.3, "US5.room%d.bridge_support" % number)
		motion._world_input(room.player, Vector3.RIGHT)
		for frame in range(30):
			if room.player.position.x >= float(centre) + 0.65:
				break
			await h.frames(1)
		motion._world_input(room.player, Vector3.ZERO)
		await h.frames(4)
	motion._world_input(room.player, Vector3.RIGHT)
	motion._jump(room.player)
	for frame in range(150):
		if room.state.exit_consumed or not room.player.alive:
			break
		if number == 6 and room.player.position.x > 6.6:
			var direction := Vector3(9.6, 0, 2.5) - room.player.position
			direction.y = 0
			motion._world_input(room.player, direction.normalized())
		await h.frames(1)
	h.check(room.state.exit_consumed, "US5.room%d.bridge_and_actual_exit" % number)

func run(h: SceneTree) -> void:
	var catalogue: RoomCatalogue = load("res://resources/room_catalogue.tres")
	for trial in range(10):
		for number in [2, 3, 4, 5, 6]:
			var definition := catalogue.find("room_%02d" % number)
			var room: RoomController = definition.scene.instantiate()
			room.initialize(trial + 1, definition)
			h.root.add_child(room)
			await h.frames(30)
			h.check(definition.matches_room(room), "US5.authored_metadata.%d" % number)
			if number == 3:
				# Real active-saw death creates the jam body at the contact boundary.
				motion._world_input(room.player, Vector3.RIGHT)
				for frame in range(130):
					if not room.player.alive:
						break
					await h.frames(1)
				await h.frames(50)
				h.check(room.saws[0].jammed() and room.state.registry.count() == 1, "US5.room3.saw_death_jams")
				var identity: String = room.state.registry.ordered_ids()[0]
				await _pose(h, room, Vector3(-2.2, 0.05, 0))
				room.request_interact(room.state.epoch, room.state.subject_id, identity)
				await h.frames(3)
				h.check(not room.saws[0].jammed() and room.player.alive, "US5.room3.safe_retrieval_reactivates")
				await _place(h, room, Vector3(-1.6, 0.05, 0))
				h.check(room.saws[0].jammed(), "US5.room3.replacement_rejams")
				motion._world_input(room.player, Vector3.RIGHT)
				motion._jump(room.player)
				for frame in range(180):
					if room.state.exit_consumed:
						break
					await h.frames(1)
				h.check(room.state.exit_consumed and room.state.registry.count() == 1, "US5.room3.actual_crossing")
			else:
				var oldest: String = ""
				if number == 4:
					oldest = await _sacrifice(h, room, number)
					await _pick(h, room, oldest)
					await _place(h, room, Vector3(-11.5, 0.05, 1.9), Vector3.BACK)
				for unit in range(2):
					var identity := await _sacrifice(h, room, number)
					await _pick(h, room, identity)
					var plate: PressurePlate = room.get_node("ExitPlate")
					var point := plate.position + Vector3(0.65 if unit == 0 else 2.55, 0.05, 0)
					await _place(h, room, point, Vector3.LEFT)
				await _pose(h, room, room.get_node("Spawn").position)
				h.check(room.get_node("ExitPlate").weight() == 2 and room.doors[0].is_open, "US5.room%d.remote_two_body_weight" % number)
				if number >= 5:
					var identity := await _sacrifice(h, room, number)
					await _pick(h, room, identity)
					await _place(h, room, Vector3(-4.6, 0.05, 0))
					h.check(room.saws[0].jammed(), "US5.combined_persistent_jam")
				if number >= 4:
					var centres: Array = [-2.5, -0.1, 2.3] if number == 4 else [-0.5, 2.0]
					for centre in centres:
						var identity := await _sacrifice(h, room, number)
						await _pick(h, room, identity)
						var pose_x := float(centre) - 1.6
						if centre == centres[0]:
							pose_x = -4.24 if number == 4 else -2.14
						await _place(h, room, Vector3(pose_x, 0.52 if float(centre) > -1 else 0.05, 0))
						h.check(room.state.registry.count() <= 5, "US5.combined_within_cap")
					if number == 4:
						h.check(room.state.registry.record_for(oldest).is_empty() and room.state.subject_id == 7, "US5.room4.six_creations_evict_entry")
					await _traverse(h, room, number)
				else:
					await _pose(h, room, Vector3(4.5, 0.05, 0))
					motion._world_input(room.player, Vector3.RIGHT)
					await h.frames(40)
					h.check(room.state.exit_consumed, "US5.room2.actual_exit")
			room.retire()
			room.queue_free()
			await h.frames(2)
