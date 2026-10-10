extends RefCounted
const INVENTORY := preload("res://scripts/checks/art_inventory.gd")
func run(h: SceneTree) -> void:
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/manifest.json"))
	h.check(manifest is Dictionary and manifest.assets.size() == 3, "ART.manifest_three_trial_assets")
	if not manifest is Dictionary:
		return
	for record in manifest.assets:
		h.check(not record.creator.is_empty() and record.licence_id == "CC0-1.0" and record.archive_sha256.length() == 64 and record.free_edition and FileAccess.file_exists("res://" + record.licence_evidence), "ART.provenance.%s" % record.asset_id)
		for path in record.runtime_paths:
			h.check(ResourceLoader.exists("res://" + path), "ART.dependency.%s" % path)
			if not ResourceLoader.exists("res://" + path):
				continue
			var root: Node = load("res://" + path).instantiate()
			h.check(FileAccess.get_sha256("res://"+path) == record.runtime_sha256, "ART.runtime_hash.%s" % record.asset_id)
			var data := INVENTORY.inspect(root)
			h.check(data.triangles > 0 and data.forbidden.is_empty() and no_scripts(root), "ART.import_isolation.%s" % record.asset_id)
			h.check(record.triangles == data.triangles and record.surfaces == data.surfaces and record.materials == data.materials.size() and record.textures == data.textures.size(), "ART.inventory_matches.%s" % record.asset_id)
			root.free()

	await fixture_checks(h)

func no_scripts(node: Node) -> bool:
	if node.get_script() != null:
		return false
	for child in node.get_children():
		if not no_scripts(child):
			return false
	return true

func fixture_checks(h: SceneTree) -> void:
	var context = load("res://tests/scenes/art_validation.tscn").instantiate()
	h.root.add_child(context)
	await h.frames(3)
	var order: Array[String] = context.room.state.registry.ordered_ids()
	var snapshot: Dictionary = context.room.state.snapshot()
	context.room.get_node("SawStation/Cosmetic").advance(.1)
	context.room.get_node("AnvilStation/Cosmetic").set_phase(1.7, 1, 3)
	h.check(context.room.state.snapshot() == snapshot, "ART.cosmetic_updates_do_not_mutate_state")
	for owner in context.room.get_children():
		if owner is SpikeBed or owner is Buzzsaw or owner is FallingAnvil:
			h.check(owner.get_node_or_null("Cosmetic") != null, "ART.fixture_candidate_hookup")
	var saw: Buzzsaw = context.room.get_node("SawStation")
	var rotor: Node3D = saw.get_node("Cosmetic/Rotor")
	context.toggle_mute()
	h.check(context.audio.sfx_volume == 0 and context.audio.music_volume == 0, "ART.fixture_muted_review")
	context.toggle_mute()
	context.toggle_pause()
	var frozen := rotor.transform
	for frame in range(3):
		await h.process_frame
	h.check(rotor.transform == frozen and context.room.state.registry.ordered_ids() == order, "ART.fixture_pause_isolated")
	context.toggle_pause()
	context.toggle_names()
	await h.frames(3)
	h.check(not str(saw.get_node("Cosmetic/State").text).contains("SAW"), "ART.fixture_label_free")
	var old_room: RoomController = context.room
	context.toggle_candidate()
	await h.frames(3)
	h.check(context.room != old_room and context.room.get_node("SawStation").get_node_or_null("Cosmetic") == null and context.room.state.registry.count() == 0, "ART.fixture_fresh_baseline")
	context.toggle_candidate()
	await h.frames(3)
	h.check(context.room.get_node("SawStation").get_node_or_null("Cosmetic") != null and context.room.state.registry.count() == 0, "ART.fixture_fresh_candidate")
	context.room.retire()
	context.queue_free()
	await h.frames(3)
