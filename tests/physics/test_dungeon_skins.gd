extends RefCounted
const INV := preload("res://scripts/checks/art_inventory.gd")

func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://scenes/art/props/plate_skin.tscn") or not ResourceLoader.exists("res://scenes/art/props/exit_skin.tscn"):
		h.check(false, "DUNGEON.skins_missing")
		return
	for trial in range(10):
		var room: RoomController = load("res://tests/scenes/greybox_room.tscn").instantiate()
		var plates: Array[PressurePlate] = []
		var doors: Array[ExitDoor] = []
		for child in room.get_children():
			if child is PressurePlate:
				child.cosmetic_scene = load("res://scenes/art/props/plate_skin.tscn")
				plates.append(child)
			elif child is ExitDoor:
				child.cosmetic_scene = load("res://scenes/art/props/exit_skin.tscn")
				doors.append(child)
		h.root.add_child(room)
		for plate in plates:
			var original_size: Vector3 = plate.get_node("Shape").shape.size
			var cosmetic: Node3D = plate.get_node("Cosmetic")
			h.check(INV.inspect(cosmetic).forbidden.is_empty() and not plate.get_node("Mesh").visible, "DUNGEON.plate_cosmetic_only.%d" % trial)
			var box: AABB = INV.inspect(cosmetic.get_node("Slab")).bounds
			h.check(absf(box.end.y-.12) <= .005 and box.size.x <= original_size.x+.005 and box.size.z <= original_size.z+.005, "DUNGEON.plate_support_alignment.%d" % trial)
			plate.apply_observations([{ "id": "review_body", "eligible": true, "direct": true }])
			h.check(cosmetic.get_node("ActiveCue").visible == plate.active() and plate.get_node("Label").text.contains("1 /"), "DUNGEON.plate_owner_state.%d" % trial)
			var idle: Node3D = load("res://scenes/art/props/plate_skin.tscn").instantiate()
			room.add_child(idle)
			idle.configure(original_size)
			idle.set_active(false)
			h.check(not idle.get_node("ActiveCue").visible and idle.get_node("IdleCue").visible, "DUNGEON.independent_plate_state.%d" % trial)
			plate.apply_observations([])
			h.check(not cosmetic.get_node("ActiveCue").visible and plate.get_node("Shape").shape.size == original_size, "DUNGEON.plate_clear_preserves_shape.%d" % trial)
		for door in doors:
			var shape: CollisionShape3D = door.get_node("Blocker/Shape")
			var original_size: Vector3 = shape.shape.size
			var retreat: Transform3D = door.get_node("Retreat").transform
			var cosmetic: Node3D = door.get_node("Cosmetic")
			var frame: Node3D = cosmetic.get_node("Frame")
			var frame_box: AABB = INV.inspect(frame).bounds
			h.check(frame_box.size.z <= door.passage_size.z+.6 and frame_box.end.y <= 2.85, "DUNGEON.exit_frame_bounded.%d" % trial)
			h.check(INV.inspect(cosmetic).forbidden.is_empty(), "DUNGEON.exit_cosmetic_only.%d" % trial)
			door.set_open(true)
			h.check(shape.disabled and frame.visible and not cosmetic.get_node("Gate").visible and door.get_node("Label").text == "EXIT OPEN", "DUNGEON.exit_open_frame.%d" % trial)
			for view in range(4):
				room.camera_views.select_view(view)
				h.check(frame.is_visible_in_tree(), "DUNGEON.exit_frame_all_views.%d.%d" % [trial,view])
			door.set_open(false)
			h.check(not shape.disabled and cosmetic.get_node("Gate").visible and shape.shape.size == original_size and door.get_node("Retreat").transform == retreat, "DUNGEON.exit_close_preserves_physics.%d" % trial)
		room.retire()
		room.queue_free()
		await h.frames(2)
