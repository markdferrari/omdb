extends RefCounted
const INV := preload("res://scripts/checks/art_inventory.gd")
func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://scenes/art/gothic_chamber.tscn"):
		h.check(false, "DECOR.chamber_missing")
		return
	for width in [16.0,24.0]:
		var path := "res://tests/scenes/greybox_room.tscn" if width == 16 else "res://scenes/rooms/room_04.tscn"
		var room: RoomController = load(path).instantiate()
		h.root.add_child(room)
		var dressing = load("res://scenes/art/gothic_chamber.tscn").instantiate()
		room.add_child(dressing)
		dressing.configure(room, Vector2(width,12))
		var before: Dictionary = room.state.snapshot()
		var data := INV.inspect(dressing)
		h.check(data.forbidden.is_empty(), "DECOR.no_physics")
		for box: AABB in dressing.tile_bounds:
			h.check(absf(box.end.y) <= .005 and box.size.y <= .1, "DECOR.floor_height")
			for spike in room.get_children():
				if spike is SpikeBed:
					var danger: Vector3 = spike.get_node("Bed/Shape").shape.size
					h.check(not box.intersects(AABB(spike.position-Vector3(danger.x/2,1,danger.z/2),Vector3(danger.x,2,danger.z))), "DECOR.floor_excludes_trap")
		h.check(room.state.snapshot() == before and dressing.get_node("Props").get_child_count() >= 3, "DECOR.props_cosmetic")
		room.retire()
		room.queue_free()
		await h.frames(2)
