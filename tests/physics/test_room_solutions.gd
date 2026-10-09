extends RefCounted
const MOTION := preload("res://tests/physics/test_bridge.gd")

func run(h: SceneTree) -> void:
	# The authored catalogue is separate from the repeated recovery fixture catalogue.
	if not ResourceLoader.exists("res://tests/scenes/authored_room_catalogue.tres"):
		h.check(false, "US5.authored_catalogue_exists")
		return
	var catalogue: RoomCatalogue = load("res://tests/scenes/authored_room_catalogue.tres")
	var definition := catalogue.find("room_01")
	if definition == null:
		h.check(false, "US5.authored_room_one_exists")
		return
	var motion := MOTION.new()
	for trial in range(10):
		var room: RoomController = definition.scene.instantiate()
		room.initialize(trial + 1, definition)
		h.root.add_child(room)
		var completions: Array = []
		room.room_completed.connect(func(epoch: int, identity: String): completions.append([epoch, identity]))
		await h.frames(30)
		var started := Engine.get_physics_frames()
		var teaching: Label = room.get_node("HUD/Onboarding")
		h.check(teaching.visible and teaching.text.contains("sacrifice"), "US5.room01.teaches_before_death")
		motion._world_input(room.player, Vector3.RIGHT)
		for frame in range(90):
			if room.player.position.x >= -2.65:
				break
			await h.frames(1)
		motion._jump(room.player)
		for frame in range(120):
			if room.state.phase == RoomState.Phase.DEATH_FEEDBACK:
				break
			await h.frames(1)
		await h.frames(2)
		h.check(room.state.registry.count() == 1, "US5.room01.hazard_created_body.%d" % trial)
		await h.frames(55)
		h.check(teaching.text.contains("Space") and teaching.text.contains("Your body remains"), "US5.room01.teaches_body_after_death")
		var prompts: InputPrompts = room.get_node("HUD")._prompts
		var controller := InputEventJoypadButton.new()
		controller.pressed = true
		prompts.observe(controller)
		h.check(teaching.text.contains("South"), "US5.room01.controller_teaching")
		motion._world_input(room.player, Vector3.RIGHT)
		for frame in range(90):
			if room.player.position.x >= -2.65:
				break
			await h.frames(1)
		motion._jump(room.player)
		for frame in range(32):
			await h.frames(1)
			if room.player.is_on_floor() and room.player.position.y > 0.3:
				break
		for frame in range(20):
			if room.player.position.x >= 0.45:
				break
			await h.frames(1)
		motion._jump(room.player)
		await h.frames(48)
		h.check(room.player.alive and room.player.is_on_floor() and room.player.position.x > 2.12, "US5.room01.body_supported_far_bank")
		for frame in range(90):
			if not completions.is_empty():
				break
			await h.frames(1)
		h.check(completions.size() == 1 and completions[0][1] == "room_01" and room.state.exit_consumed, "US5.room01.real_exit_completed")
		h.check(room.state.registry.count() == 1 and room.state.held_body_id.is_empty() and room.state.subject_id == 2, "US5.room01.one_body_no_carry")
		print("OMDB_SOLUTION room_01 trial=", trial, " ticks=", Engine.get_physics_frames() - started, " retained=1 created=1 poses=", room.bodies.values().map(func(b): return b.position))
		room.retire()
		room.queue_free()
		await h.frames(2)
		# Fresh empty rooms: both outer edges and the centre must remain lethal;
		# vary launch timing rather than relying on a ballistic formula alone.
		for side in [-5.6, 0.0, 5.6]:
			for launch_x in [-2.7, -2.35, -2.15]:
				room = definition.scene.instantiate()
				room.initialize(trial + 1, definition)
				h.root.add_child(room)
				room.player.position = Vector3(-5, 0.05, side)
				await h.frames(30)
				motion._world_input(room.player, Vector3.RIGHT)
				for frame in range(90):
					if room.player.position.x >= launch_x or not room.player.alive:
						break
					await h.frames(1)
				motion._jump(room.player)
				for frame in range(100):
					if not room.player.alive or room.player.position.x > 2.12:
						break
					await h.frames(1)
				h.check(not room.player.alive and not room.state.exit_consumed, "US5.room01.empty_jump_blocked.%d.%.1f.%.2f" % [trial, side, launch_x])
				room.retire()
				room.queue_free()
				await h.frames(2)
