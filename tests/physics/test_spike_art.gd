extends RefCounted
const INVENTORY := preload("res://scripts/checks/art_inventory.gd")
const HELP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://scenes/art/hazards/spikes_visual.tscn"):
		h.check(false, "ART.spikes_missing")
		return
	var helper = HELP.new()
	for size in [Vector2(3.6, 11.9), Vector2(2, 2), Vector2(8.4, 11.9), Vector2(5.2, 11.9)]:
		for trial in range(10):
			var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
			h.root.add_child(room)
			var bed: SpikeBed = load("res://scenes/hazards/spike_bed.tscn").instantiate()
			bed.bed_size = size
			bed.set("cosmetic_scene", load("res://scenes/art/hazards/spikes_visual.tscn"))
			room.add_child(bed)
			await h.frames(2)
			var visual := bed.get_node_or_null("Cosmetic")
			h.check(visual != null, "ART.spikes_hookup")
			if visual != null:
				var data := INVENTORY.inspect(visual)
				var box: AABB = data.bounds
				h.check(data.forbidden.is_empty() and box.end.y <= .17001 and box.position.x >= -size.x/2-.001 and box.end.x <= size.x/2+.001 and box.position.z >= -size.y/2-.001 and box.end.z <= size.y/2+.001, "ART.spikes_shallow_bounded.%.1fx%.1f.%d" % [size.x, size.y, trial])
			var solid: BoxShape3D = bed.get_node("Bed/Shape").shape
			var lethal: BoxShape3D = bed.get_node("Lethal/Shape").shape
			h.check(solid.size == Vector3(size.x, .2, size.y) and lethal.size == Vector3(size.x, .16, size.y) and is_equal_approx(bed.get_node("Bed").position.y, -.1), "ART.spikes_envelope")
			var body := helper.add_body(room, Vector3(0, .245, 0))
			await h.frames(30)
			h.check(absf(body.position.y-.225) < .04 and room.state.registry.count() == 1, "ART.spikes_body_support")
			await helper.dispose(h, room)
