extends RefCounted
func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://scenes/art/gothic_chamber.tscn"):
		h.check(false, "DECOR.cutaways_missing")
		return
	var room: RoomController = load("res://tests/scenes/greybox_room.tscn").instantiate()
	h.root.add_child(room)
	var dressing = load("res://scenes/art/gothic_chamber.tscn").instantiate()
	room.add_child(dressing)
	dressing.configure(room,Vector2(16,12))
	var snapshot: Dictionary = room.state.snapshot()
	for view in range(4):
		room.camera_views.select_view(view)
		var near := Vector3(room.camera_views.camera.position.x,0,room.camera_views.camera.position.z).normalized()
		for side in dressing.side_roots:
			var group: Node3D = dressing.side_roots[side]
			h.check(group.visible == (group.position.dot(near) <= 0), "DECOR.nested_cutaway.%d.%s" % [view,side])
		for name in ["Wall0","Wall1","Wall2","FrontBoundary"]:
			h.check(not room.get_node(name+"/Shape").disabled, "DECOR.solids_remain")
		h.check(dressing.get_node("BoundaryTrim").visible and dressing.get_node("BoundaryTrim").get_child_count() == 4,"DECOR.low_trim_persists")
		h.check(room.state.snapshot() == snapshot, "DECOR.view_preserves_state")
	room.retire()
	room.queue_free()
	await h.frames(2)
