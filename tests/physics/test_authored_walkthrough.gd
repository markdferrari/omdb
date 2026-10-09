extends RefCounted
## Complete Rooms 2–6 without subject staging or injected/teleported corpses.
const MOTION := preload("res://tests/physics/test_bridge.gd")
var motion = MOTION.new()
var room: RoomController
var h: SceneTree

func _move(point: Vector3, jump: bool = false) -> bool:
	if jump:
		motion._jump(room.player)
	for frame in range(320):
		if not room.player.alive:
			return room.state.exit_consumed
		var delta := point - room.player.position
		delta.y = 0
		if delta.length() < 0.07:
			motion._world_input(room.player, Vector3.ZERO)
			if room.player.is_on_floor():
				await h.frames(5)
				return true
		else:
			motion._world_input(room.player, delta.normalized() * minf(1, delta.length() / 0.6))
		await h.frames(1)
	motion._world_input(room.player, Vector3.ZERO)
	h.check(false, "US5.walkthrough_reached.%s.%s.actual_%s" % [room.definition.room_id, point, room.player.position])
	return false

func _supply(number: int) -> String:
	var subject := room.state.subject_id
	var supply: Node3D = room.get_node("SupplySpikes") if number == 2 else room.get_node("Anvil")
	await _move(supply.position)
	motion._world_input(room.player, Vector3.ZERO)
	for frame in range(240):
		if not room.player.alive:
			break
		await h.frames(1)
	await h.frames(2)
	var identity: String = room.state.registry.ordered_ids().back()
	await h.frames(45)
	h.check(room.player.alive and room.state.subject_id == subject + 1, "US5.walkthrough_real_supply")
	var body: Corpse = room.bodies[identity]
	var point := body.position
	point.y = 0
	point.z += -1.65 if point.z > 0 else 1.65
	await _move(point)
	room.request_interact(room.state.epoch, room.state.subject_id, identity)
	await h.frames(3)
	h.check(room.state.held_body_id == identity, "US5.walkthrough_real_pickup")
	return identity

func _release(facing: Vector3) -> void:
	motion._world_input(room.player, Vector3.ZERO)
	room.player.facing = facing
	await h.frames(8)
	var preview := PlacementEvaluator.evaluate(room, room.state.held_body_id)
	h.check(preview.valid, "US5.walkthrough_preview.%s.%s" % [room.definition.room_id, preview.reason])
	room.request_interact(room.state.epoch, room.state.subject_id)
	await h.frames(30)
	h.check(room.state.held_body_id.is_empty(), "US5.walkthrough_release")

func _plate_bodies(number: int) -> void:
	var plate: PressurePlate = room.get_node("ExitPlate")
	for unit in range(2):
		await _supply(number)
		var actor_x: float = plate.position.x + (0.65 if unit == 0 else 2.55)
		var approach := Vector3(actor_x, 0, plate.position.z - signf(plate.position.z) * 1.7)
		await _move(Vector3(actor_x, 0, 0))
		await _move(approach)
		await _move(Vector3(actor_x, 0, plate.position.z), unit == 0)
		await _release(Vector3.LEFT)
		await _move(approach)
		await _move(Vector3(actor_x, 0, 0))
	h.check(plate.weight() == 2 and room.doors[0].is_open, "US5.walkthrough_remote_plate")

func _bridge_approach(number: int, index: int) -> void:
	if number == 4:
		await _move(Vector3(-4.24, 0, 0))
		if index >= 1:
			await _move(Vector3(-2.64, 0, 0), true)
			await _move(Vector3(-1.7, 0, 0))
		if index >= 2:
			await _move(Vector3(-0.1, 0, 0), true)
			await _move(Vector3(0.7, 0, 0))
	else:
		await _move(Vector3(-5.2, 0, 0))
		await _move(Vector3(-2.14, 0, 0), true)
		if index >= 1:
			await _move(Vector3(-0.54, 0, 0), true)
			await _move(Vector3(0.4, 0, 0))

func _return_supply(number: int, index: int) -> void:
	if number == 4:
		if index >= 2:
			await _move(Vector3(-0.1, 0, 0))
			await _move(Vector3(-2.64, 0, 0), true)
		elif index >= 1:
			await _move(Vector3(-2.64, 0, 0))
		await _move(Vector3(-4.24, 0, 0), true)
	else:
		if index >= 1:
			await _move(Vector3(-0.54, 0, 0))
			await _move(Vector3(-3, 0, 0), true)
		else:
			await _move(Vector3(-3, 0, 0))
		await _move(Vector3(-5.2, 0, 0), true)

func run(harness: SceneTree) -> void:
	h = harness
	var catalogue: RoomCatalogue = load("res://resources/room_catalogue.tres")
	for trial in range(10):
		for number in [2, 3, 4, 5, 6]:
			var definition := catalogue.find("room_%02d" % number)
			room = definition.scene.instantiate()
			room.initialize(trial + 1, definition)
			h.root.add_child(room)
			await h.frames(30)
			var started := Engine.get_physics_frames()
			var oldest := ""
			if number == 2:
				await _move(Vector3(-5, 0, 1.8))
				await _move(Vector3(-5, 0, 3.5), true)
				h.check(room.get_node("TeachingPlate").weight() == 1 and room.get_node("TeachingPlate").active() and not room.doors[0].is_open, "US5.walkthrough_single_live_contribution")
				await _move(Vector3(-5, 0, 1.8))
				h.check(room.get_node("TeachingPlate").weight() == 0, "US5.walkthrough_remote_weight_needed")
			if number == 3:
				await _move(Vector3(0, 0, 0))
				await h.frames(45)
				await _move(Vector3(-2.2, 0, 0))
				room.request_interact(room.state.epoch, room.state.subject_id)
				await h.frames(3)
				h.check(not room.saws[0].jammed() and not room.state.held_body_id.is_empty(), "US5.walkthrough_safe_saw_retrieval")
				await _move(Vector3(-1.6, 0, 0))
				await _release(Vector3.RIGHT)
				await _move(Vector3(1.8, 0, 0), true)
			else:
				if number == 4:
					oldest = await _supply(number)
					await _move(Vector3(-11.5, 0, 0))
					await _move(Vector3(-11.5, 0, 1.9))
					await _release(Vector3.BACK)
					await _move(Vector3(-11.5, 0, 3.5), true)
					await _move(Vector3(-10, 1.3, 3.5), true)
					h.check(room.player.position.y > 1.2, "US5.walkthrough_early_body_support_shelf")
					await _move(Vector3(-8, 0, 0))
				await _plate_bodies(number)
				if number >= 5:
					await _supply(number)
					await _move(Vector3(-4.6, 0, 0))
					await _release(Vector3.RIGHT)
					h.check(room.saws[0].jammed(), "US5.walkthrough_persistent_jam")
				if number >= 4:
					var count := 3 if number == 4 else 2
					for index in range(count):
						await _supply(number)
						await _bridge_approach(number, index)
						await _release(Vector3.RIGHT)
						if index < count - 1:
							await _return_supply(number, index)
					if number == 4:
						h.check(room.state.registry.record_for(oldest).is_empty() and room.state.subject_id == 7, "US5.walkthrough_six_creations_five_retained")
					await _move(Vector3(2.3 if number == 4 else 2.0, 0, 0), true)
					await _move(Vector3(2.95 if number == 4 else 2.65, 0, 0))
					await _move(Vector3(6.6, 0, 0), true)
				else:
					await _move(Vector3(4.5, 0, 0))
			await _move(Vector3(8 if number >= 4 else 5, 0, room.doors[0].position.z))
			await _move(room.doors[0].position + Vector3.RIGHT)
			h.check(room.state.exit_consumed and room.state.registry.count() <= 5, "US5.walkthrough_fresh_solution.%d.%d" % [number, trial])
			var budget: int = 2 if number == 2 else 1 if number == 3 else 5
			var creations: int = 6 if number == 4 else budget
			h.check(room.state.registry.count() == budget and room.state.subject_id == creations + 1, "US5.walkthrough_exact_intended_budget")
			print("OMDB_SOLUTION ", definition.room_id, " trial=", trial, " ticks=", Engine.get_physics_frames() - started, " retained=", room.state.registry.count(), " created=", room.state.subject_id - 1, " poses=", room.bodies.values().map(func(b): return b.position))
			room.retire()
			room.queue_free()
			await h.frames(2)
