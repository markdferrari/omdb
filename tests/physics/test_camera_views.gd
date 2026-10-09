extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(60):
		var room_number := trial % 6 + 1
		var room: RoomController = load("res://scenes/rooms/room_%02d.tscn" % room_number).instantiate()
		h.root.add_child(room)
		await h.frames(2)
		var camera: Camera3D = room.get_node("Camera")
		var original_size := camera.size
		var original_transform := camera.transform
		var before := room.state.snapshot()
		# Both cycling directions must rotate immediately from the authored view.
		for action in ["camera_next", "camera_previous"]:
			room.camera_views.select_view(0)
			var cycle := InputEventAction.new()
			cycle.action = action
			cycle.pressed = true
			room.camera_views._unhandled_input(cycle)
			# Compare horizontal vectors: elevation must not affect the yaw measurement.
			var start := Vector3(original_transform.origin.x, 0, original_transform.origin.z)
			var end := Vector3(camera.position.x, 0, camera.position.z)
			var angle := start.signed_angle_to(end, Vector3.UP)
			h.check(is_equal_approx(angle, -PI / 2.0 if action == "camera_next" else PI / 2.0), "CAM02.first_cycle_quarter_turn.%d.%s" % [trial, action])
		for index in range(4):
			var direct := InputEventAction.new()
			direct.action = ["camera_north", "camera_east", "camera_south", "camera_west"][index]
			direct.pressed = true
			room.camera_views._unhandled_input(direct)
			var horizontal := Vector3(camera.position.x, 0, camera.position.z).normalized()
			var expected: Vector3 = [Vector3(1, 0, 1), Vector3(-1, 0, 1), Vector3(-1, 0, -1), Vector3(1, 0, -1)][index]
			h.check(horizontal.distance_to(expected.normalized()) < 0.001 and room.camera_views.view_index == index, "CAM02.diagonal_isometric_preset.%d.%d" % [trial, index])
			h.check(is_equal_approx(camera.position.y, original_transform.origin.y) and is_equal_approx(camera.position.length(), original_transform.origin.length()) and is_equal_approx(camera.basis.y.y, original_transform.basis.y.y) and is_equal_approx(camera.basis.z.y, original_transform.basis.z.y), "CAM02.preserves_authored_elevation_distance_pitch")
			if index == 0:
				h.check(camera.transform.is_equal_approx(original_transform), "CAM02.first_view_matches_authored_camera")
			h.check(camera.projection == Camera3D.PROJECTION_ORTHOGONAL and camera.size == original_size, "CAM01.preserves_projection_framing")
			var right := PlayerController.ground_direction(Vector2.RIGHT, camera.global_basis)
			var up := PlayerController.ground_direction(Vector2.UP, camera.global_basis)
			h.check(right.dot(camera.global_basis.x) > 0.999 and up.dot(camera.global_basis.y) > 0, "CAM01.screen_movement_each_view")
			h.check(room.state.snapshot() == before and not room.get_node("Wall1/Shape").disabled, "CAM01.view_does_not_mutate_puzzle_collision")
			for wall_name in ["Wall0", "Wall1", "Wall2", "FrontBoundary"]:
				var wall: Node3D = room.get_node(wall_name)
				for child in wall.get_children():
					if child is MeshInstance3D:
						h.check(child.visible == (wall.position.dot(horizontal) <= 0), "CAM02.diagonal_foreground_cutaway")
					elif child is CollisionShape3D:
						h.check(not child.disabled, "CAM02.all_boundaries_remain_solid")
		var event := InputEventAction.new()
		event.action = "camera_next"
		event.pressed = true
		room.camera_views._unhandled_input(event)
		h.check(room.camera_views.view_index == 0, "CAM02.wraps_to_authored_corner")
		h.check(room.get_node("Exit/FrameTop").visible and room.get_node("Exit/FrameLeft").visible, "CAM01.exit_has_visible_frame")
		room.retire()
		room.queue_free()
		await h.frames(2)
