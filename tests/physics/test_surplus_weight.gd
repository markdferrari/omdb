extends RefCounted
const SETUP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = SETUP.new()
	for trial in range(10):
		var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
		room.spawn_player = true
		h.root.add_child(room)
		var plate: PressurePlate = load("res://scenes/puzzle/pressure_plate.tscn").instantiate()
		plate.position = Vector3(0, 0, 3)
		plate.required_weight = 2
		var shape: BoxShape3D = plate.get_node("Shape").shape.duplicate()
		shape.size.x = 6.2
		plate.get_node("Shape").shape = shape
		room.add_child(plate)
		var door: ExitDoor = load("res://scenes/puzzle/exit_door.tscn").instantiate()
		door.position = Vector3(5, 0, -3)
		room.add_child(door)
		var first := helper.add_body(room, Vector3(-2, 0.38, 3))
		var second := helper.add_body(room, Vector3(0, 0.38, 3))
		helper.add_body(room, Vector3(2, 0.38, 3))
		await h.frames(60)
		h.check(plate.weight() == 3 and door.is_open, "EC07.actual_surplus_weight.%d" % trial)
		room.state.remove_body(first.body_id)
		room._remove_prop(first.body_id)
		room._sync_contacts()
		h.check(plate.weight() == 2 and door.is_open, "EC07.actual_surplus_removal")
		room.state.remove_body(second.body_id)
		room._remove_prop(second.body_id)
		room._sync_contacts()
		h.check(plate.weight() == 1 and not door.is_open, "EC07.actual_threshold_loss")
		await helper.dispose(h, room)
