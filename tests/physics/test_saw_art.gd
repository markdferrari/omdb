extends RefCounted
const INVENTORY := preload("res://scripts/checks/art_inventory.gd")
const HELP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://scenes/art/hazards/saw_visual.tscn"):
		h.check(false, "ART.saw_missing")
		return
	var helper = HELP.new()
	for trial in range(10):
		var room: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
		h.root.add_child(room)
		var saw: Buzzsaw = load("res://scenes/hazards/buzzsaw.tscn").instantiate()
		saw.set("cosmetic_scene", load("res://scenes/art/hazards/saw_visual.tscn"))
		room.add_child(saw)
		var other: Buzzsaw = load("res://scenes/hazards/buzzsaw.tscn").instantiate()
		other.set("cosmetic_scene", load("res://scenes/art/hazards/saw_visual.tscn"))
		other.position.x = 5
		room.add_child(other)
		var a := helper.add_body(room, Vector3(-4, .245, -3))
		var b := helper.add_body(room, Vector3(-4, .245, 3))
		var visual := saw.get_node_or_null("Cosmetic")
		h.check(visual != null, "ART.saw_hookup")
		if visual != null:
			var rotor: Node3D = visual.get_node("Rotor")
			var box: AABB = INVENTORY.inspect(rotor).bounds
			h.check(box.size.x <= .16001 and absf(box.size.y-1.7) < .01 and absf(box.size.z-1.7) < .01 and INVENTORY.inspect(visual).forbidden.is_empty(), "ART.saw_axle_bounds")
			var original := rotor.rotation.x
			visual.advance(.1)
			h.check(absf(rotor.rotation.x-original-.9) < .001, "ART.saw_active_motion")
			var ids: Array[String] = [a.body_id, b.body_id]
			saw.apply_candidates(ids, room.state.registry)
			var stopped := rotor.transform
			visual.advance(.5)
			h.check(rotor.transform == stopped and saw.jammed() and not other.jammed(), "ART.saw_persistent_independent_jam")
			ids = [b.body_id]
			saw.apply_candidates(ids, room.state.registry)
			h.check(saw.jammed(), "ART.saw_remaining_contributor")
			room.state.registry.set_mode(b.body_id, CorpseRegistry.Mode.HELD)
			saw.apply_candidates(ids, room.state.registry)
			h.check(not saw.jammed(), "ART.saw_held_excluded")
			visual.advance(.1)
			h.check(rotor.transform != stopped, "ART.saw_immediate_reactivation")
		await helper.dispose(h, room)
