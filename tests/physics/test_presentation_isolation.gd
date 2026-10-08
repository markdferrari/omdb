extends RefCounted
const HELP := preload("res://tests/physics/test_placement.gd")

func has_solid(node: Node) -> bool:
	if node is CollisionObject3D or node is CollisionShape3D:
		return true
	for child in node.get_children():
		if has_solid(child):
			return true
	return false

func run(h: SceneTree) -> void:
	var helper = HELP.new()
	for trial in range(10):
		var room: RoomController = await helper.fixture(h)
		var held: Corpse = room.bodies[room.state.held_body_id]
		var player_shape: CollisionShape3D = room.player.get_node("Shape")
		var corpse_shape: CollisionShape3D = held.get_node("Shape")
		var player_pose := player_shape.transform
		var corpse_pose := corpse_shape.transform
		for clip in ["Idle", "Move", "Hurt"]:
			var visual: CharacterVisual = room.player.get_node("Visual")
			visual._play(clip)
			visual._animation.advance(0.1)
			h.check(player_shape.transform == player_pose and player_shape.shape.height == room.tuning.player_height, "US7.animation_player_shape_isolated.%s" % clip)
			h.check(corpse_shape.transform == corpse_pose and held.freeze and corpse_shape.disabled and held.collision_layer == 0, "US7.animation_held_eligibility_unchanged")
		if not room.has_method("_spawn_feedback"):
			h.check(false, "US7.bounded_feedback_available")
			await helper.dispose(h, room)
			continue
		var order := room.state.registry.ordered_ids().duplicate()
		for index in range(40):
			room.call("_spawn_feedback", "death" if index % 2 == 0 else "eviction", Vector3(-2, 1, -3))
		var fragments := 0
		for child in room.get_children():
			if child.is_in_group("cosmetic_feedback"):
				fragments += child.get_child_count()
				h.check(not has_solid(child), "US7.effects_have_no_physics")
		h.check(fragments > 0 and fragments <= room.tuning.effect_instance_budget, "US7.cosmetic_budget_under_burst_load")
		h.check(room.state.registry.ordered_ids() == order and held.freeze and corpse_shape.disabled, "US7.effects_do_not_mutate_queue_or_support")
		await h.frames(60)
		var remaining := 0
		for child in room.get_children():
			if child.is_in_group("cosmetic_feedback"):
				remaining += 1
		h.check(remaining == 0, "US7.effects_expire_in_active_play")
		await helper.dispose(h, room)
	# Twenty overlapping reports must still produce one body/replacement, within 2 s.
	for trial in range(20):
		var room: RoomController = await helper.fixture(h)
		var before := room.state.subject_id
		room.request_death(room.state.epoch, before, "spikes", room.player.global_transform)
		room.request_death(room.state.epoch, before, "saw", room.player.global_transform)
		await h.frames(2)
		var visible_feedback := false
		for child in room.get_children():
			if child.is_in_group("cosmetic_feedback"):
				visible_feedback = true
		h.check(visible_feedback, "US7.death_feedback_appears_after_commit")
		await h.frames(118)
		h.check(room.state.subject_id == before + 1 and room.state.registry.count() == 2 and room.player.alive, "US7.feedback_preserves_respawn_deadline.%d" % trial)
		await helper.dispose(h, room)
