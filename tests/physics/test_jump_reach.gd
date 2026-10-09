extends RefCounted
const MOTION := preload("res://tests/physics/test_bridge.gd")

func run(h: SceneTree) -> void:
	var motion := MOTION.new()
	var maximum := 0.0
	for trial in range(10):
		for delay in [0, 3, 5]:
			var room: RoomController = load("res://scenes/rooms/chamber.tscn").instantiate()
			room.spawn_player = true
			var floor_shape: BoxShape3D = room.get_node("Floor/Shape").shape.duplicate()
			floor_shape.size.x = 6.0
			room.get_node("Floor/Shape").shape = floor_shape
			room.get_node("Floor").position.x = -5.0
			h.root.add_child(room)
			await h.frames(30)
			motion._world_input(room.player, Vector3.RIGHT)
			# Leave the real ledge, then use the controller's actual coyote window.
			for frame in range(120):
				await h.frames(1)
				if not room.player.is_on_floor():
					break
			var departure_x := room.player.position.x
			await h.frames(delay)
			motion._jump(room.player)
			var jumped := false
			for frame in range(100):
				await h.frames(1)
				jumped = jumped or room.player.velocity.y > 1.0
				if jumped and room.player.position.y <= 0.0 and room.player.velocity.y < 0.0:
					break
			var reach := room.player.position.x - departure_x
			maximum = maxf(maximum, reach)
			h.check(jumped and reach > 2.4 and reach < 3.6, "US5.measured_coyote_jump_bound.%d.%d" % [trial, delay])
			print("OMDB_JUMP_REACH trial=", trial, " delay_frames=", delay, " reach_m=", reach)
			room.retire()
			room.queue_free()
			await h.frames(2)
	print("OMDB_JUMP_MAX_METRES ", maximum)
