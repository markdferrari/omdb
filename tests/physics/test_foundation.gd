extends RefCounted

func run(h: SceneTree) -> void:
	var fixture: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
	h.root.add_child(fixture)
	await h.frames(2)
	h.check(fixture.get_node("Camera").projection == Camera3D.PROJECTION_ORTHOGONAL, "foundation.fixed_camera")
	var body := RigidBody3D.new()
	body.collision_layer = 4
	body.collision_mask = 7
	body.position = Vector3(0, 2, 0)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 0.5, 1)
	shape.shape = box
	body.add_child(shape)
	fixture.add_child(body)
	await h.frames(90)
	h.check(absf(body.position.y - 0.25) < 0.04, "foundation.real_physics_floor_support")
	h.check(body.linear_velocity.length() < 0.1, "foundation.settled")
	fixture.retire()
	h.check(fixture.enqueue({"epoch": 1, "kind": "test"}) == "IGNORED_STALE", "foundation.retired_commands")
	fixture.queue_free()
	await h.frames(2)
