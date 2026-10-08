extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		for role in ["held", "support", "plate", "saw"]:
			var state := RoomState.new(trial + 1)
			state.activate()
			for index in range(5):
				state.create_corpse(Transform3D.IDENTITY)
			var oldest := state.registry.oldest_id()
			if role == "held":
				state.pickup(state.epoch, state.subject_id, oldest)
			else:
				for cycle in range(10):
					state.pickup(state.epoch, state.subject_id, oldest)
					state.release(state.epoch, state.subject_id, oldest)
				h.check(state.registry.oldest_id() == oldest, "US3.retained_age.%s" % role)
			var result := state.create_corpse(Transform3D.IDENTITY)
			h.check(result.evicted_id == oldest and state.registry.count() == 5, "US3.fifo_role.%s" % role)
			h.check(state.held_body_id.is_empty() and not state.registry.eligible(oldest), "US3.evicted_ineligible.%s" % role)
