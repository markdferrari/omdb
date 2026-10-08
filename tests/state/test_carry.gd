extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		for age in [0, 3]:
			var state := RoomState.new(trial + 1)
			state.activate()
			for index in range(5):
				state.create_corpse(Transform3D.IDENTITY)
			var order := state.registry.ordered_ids()
			var target := order[age]
			h.check(state.pickup(state.epoch, state.subject_id, "missing") == "INVALID_STATE" and state.held_body_id.is_empty(), "EC05.failed_pickup_unchanged")
			var accepted := state.pickup(state.epoch, state.subject_id, target)
			h.check(accepted == "ACCEPTED", "US2.pickup_accepts.%d.%d" % [trial, age])
			if accepted != "ACCEPTED":
				continue
			h.check(state.registry.count() == 5 and state.registry.ordered_ids() == order and state.registry.record_for(target).mode == CorpseRegistry.Mode.HELD, "EC03.held_age_count")
			h.check(state.pickup(state.epoch, state.subject_id, order[4]) == "INVALID_STATE" and state.held_body_id == target, "US2.single_held_identity")
			h.check(state.release(state.epoch - 1, state.subject_id, target) == "IGNORED_STALE" and state.held_body_id == target, "US2.stale_release")
			h.check(state.release(state.epoch, state.subject_id, target) == "ACCEPTED" and state.registry.ordered_ids() == order, "US2.release_preserves_order")
			state.pickup(state.epoch, state.subject_id, target)
			state.request_death(state.epoch, state.subject_id)
			h.check(state.release_for_death() == target and state.held_body_id.is_empty(), "EC04.death_clears_carry")
			var death := state.create_corpse(Transform3D.IDENTITY)
			h.check(death.evicted_id == order[0] and state.registry.count() == 5, "EC04.death_fifo")
			h.check(state.registry.record_for(target).is_empty() if age == 0 else state.registry.record_for(target).mode == CorpseRegistry.Mode.RELEASED, "EC04.preserve_unless_oldest")
			state.pickup(state.epoch, state.subject_id, order[1]) # Dead subject must reject.
			h.check(state.held_body_id.is_empty(), "US2.dead_pickup_rejected")
		var registry := CorpseRegistry.new(trial + 1)
		var first: String = registry.create(Transform3D.IDENTITY).body_id
		var second: String = registry.create(Transform3D.IDENTITY).body_id
		h.check(registry.set_mode(first, CorpseRegistry.Mode.HELD) == "ACCEPTED" and registry.set_mode(second, CorpseRegistry.Mode.HELD) == "INVALID_STATE", "US2.registry_single_held")
