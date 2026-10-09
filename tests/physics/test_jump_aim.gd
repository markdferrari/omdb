extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		for view in range(4):
			var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
			room.spawn_player = true
			h.root.add_child(room)
			await h.frames(12)
			room.camera_views.select_view(view)
			var actor := room.player
			actor.use_movement_override = true
			actor.movement_override = Vector2.RIGHT
			await h.frames(20)
			var jump := InputEventAction.new()
			jump.action = "jump"
			jump.pressed = true
			actor.queue_jump(jump)
			await h.frames(4)
			h.check(not actor.is_on_floor() and actor.get_node("JumpFootprint").visible, "JUMP01.airborne_footprint.%d.%d" % [trial, view])
			var footprint: MeshInstance3D = actor.get_node("JumpFootprint")
			h.check(Vector2(footprint.global_position.x, footprint.global_position.z).distance_to(Vector2(actor.global_position.x, actor.global_position.z)) < 0.001 and absf(footprint.global_position.y - 0.025) < 0.01, "JUMP01.footprint_tracks_ground_under_feet")
			var release := actor.global_position
			actor.movement_override = Vector2.ZERO
			await h.frames(8)
			var drift := Vector2(actor.global_position.x - release.x, actor.global_position.z - release.z).length()
			h.check(drift <= 0.18 and Vector2(actor.velocity.x, actor.velocity.z).length() < 0.001, "JUMP01.release_brakes_within_18cm")
			if trial == 0:
				print("OMDB_JUMP_AIM view=", view, " release_drift_m=", drift)
			await h.frames(50)
			h.check(actor.is_on_floor() and not footprint.visible and actor.get_node("GroundShadow").visible, "JUMP01.landing_hides_ring_retains_shadow")
			# A second real jump checks reversing direction without changing jump power.
			actor.movement_override = Vector2.RIGHT
			await h.frames(20)
			actor.queue_jump(jump)
			await h.frames(4)
			actor.movement_override = Vector2.LEFT
			await h.frames(8)
			var left := PlayerController.ground_direction(Vector2.LEFT, actor.camera.global_basis)
			h.check(Vector3(actor.velocity.x, 0, actor.velocity.z).dot(left) > 0.4, "JUMP01.airborne_direction_correction")
			h.check(actor.tuning.jump_speed == 6.0 and actor.tuning.gravity == 20.0 and actor.tuning.move_speed == 4.5, "JUMP01.preserves_jump_power_and_top_speed")
			# The marker follows actual support height, including a solid corpse top.
			actor.set_physics_process(false)
			actor.position = Vector3(0, 2, 3)
			var body: Corpse = load("res://scenes/corpses/corpse.tscn").instantiate()
			body.position = Vector3(0, 0.225, 3)
			body.freeze = true
			room.add_child(body)
			await h.frames(2)
			actor._update_shadow()
			h.check(absf(footprint.global_position.y - 0.475) < 0.01, "JUMP01.footprint_on_corpse_top")
			body.collision_layer = 0
			await h.frames(2)
			actor._update_shadow()
			h.check(absf(footprint.global_position.y - 0.025) < 0.01, "JUMP01.footprint_ignores_non_supporting_body")
			room.retire()
			room.queue_free()
			await h.frames(2)
