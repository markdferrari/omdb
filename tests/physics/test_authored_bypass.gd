extends RefCounted
const MOTION := preload("res://tests/physics/test_bridge.gd")
var motion = MOTION.new()

func run(h: SceneTree) -> void:
	var catalogue: RoomCatalogue = load("res://resources/room_catalogue.tres")
	for trial in range(10):
		for number in [2, 3, 4, 5, 6]:
			var definition := catalogue.find("room_%02d" % number)
			for side in [-5.6, 0.0, 5.6]:
				var room: RoomController = definition.scene.instantiate()
				room.initialize(trial + 1, definition)
				h.root.add_child(room)
				# Fresh subject starting poses isolate each boundary attempt; no props,
				# altered hazard/door states, or collision changes are introduced.
				if number == 3:
					room.player.position = Vector3(-1.8, 0.05, side)
				elif number >= 4:
					room.player.position = Vector3(-3.7 if number == 4 else -1.2, 0.05, side)
				else:
					room.player.position = Vector3(4.5, 0.05, side)
				await h.frames(15)
				motion._world_input(room.player, Vector3.RIGHT)
				motion._jump(room.player)
				for frame in range(130):
					if not room.player.alive or room.state.exit_consumed:
						break
					await h.frames(1)
				h.check(not room.state.exit_consumed, "US5.room%d.empty_bypass_blocked.%d.%.1f" % [number, trial, side])
				if number >= 4:
					h.check(not room.player.alive, "US5.full_spike_width_lethal")
				elif number == 3 and side == 0:
					h.check(not room.player.alive, "US5.active_saw_jump_lethal")
				else:
					var barrier_x: float = 0 if number == 3 else room.doors[0].position.x
					h.check(room.player.alive and room.player.position.x < barrier_x, "US5.solid_gate_prevents_walkaround")
				room.retire()
				room.queue_free()
				await h.frames(2)
			# Isolate the exit partition on its far bank, and the taught saw in
			# each combined room, so a later obstacle cannot hide an earlier bypass.
			var barriers: Array[String] = []
			if number != 3:
				barriers.append("Exit")
			if number >= 5:
				barriers.append("Saw")
			for obstacle in barriers:
				for side in [-5.6, 2.5 if number == 6 and obstacle == "Exit" else 0.0, 5.6]:
					var room: RoomController = definition.scene.instantiate()
					room.initialize(trial + 1, definition)
					h.root.add_child(room)
					var barrier: Node3D = room.get_node(obstacle)
					room.player.position = Vector3(barrier.position.x - 1.8, 0.05, side)
					await h.frames(15)
					motion._world_input(room.player, Vector3.RIGHT)
					motion._jump(room.player)
					for frame in range(90):
						if not room.player.alive:
							break
						await h.frames(1)
					h.check(not room.state.exit_consumed and room.player.position.x < barrier.position.x, "US5.isolated_%s_blocked.room%d.%.1f" % [obstacle, number, side])
					if obstacle == "Saw" and side == 0:
						h.check(not room.player.alive, "US5.combined_active_saw_blocks_jump")
					else:
						h.check(room.player.alive, "US5.closed_partition_blocks_walk_and_jump")
					room.retire()
					room.queue_free()
					await h.frames(2)
