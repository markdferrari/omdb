extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var state := RoomState.new(trial + 1)
		state.activate()
		for death in range(12):
			var subject := state.subject_id
			var accepted := state.request_death(state.epoch, subject)
			h.check(accepted == "ACCEPTED", "US1.lifecycle.accepted.%d.%d" % [trial, death])
			if accepted != "ACCEPTED":
				break
			h.check(state.request_death(state.epoch, subject) == "IGNORED_DUPLICATE", "EC01.overlapping_contacts")
			h.check(not state.is_live(state.epoch, subject) and state.phase == RoomState.Phase.DEATH_FEEDBACK, "US1.lifecycle.dead_ineligible")
			var existing := state.registry.ordered_ids()
			state.registry.create(Transform3D.IDENTITY)
			var token := state.death_token
			h.check(state.replace_subject(token) and state.subject_id == subject + 1, "US1.lifecycle.one_replacement")
			h.check(not state.replace_subject(token), "US1.lifecycle.replacement_latch")
			h.check(state.request_death(state.epoch, subject) == "IGNORED_STALE", "US1.lifecycle.stale_subject")
			h.check(state.request_death(state.epoch - 1, state.subject_id) == "IGNORED_STALE", "US1.lifecycle.stale_epoch")
			h.check(state.registry.count() <= 5 and state.registry.ordered_ids().slice(0, maxi(0, state.registry.count() - 1)) == existing.slice(1 if existing.size() == 5 else 0), "EC02.rapid_deaths_preserve_state")
		state.retire()
		h.check(state.request_death(state.epoch, state.subject_id) == "IGNORED_STALE", "US1.lifecycle.retirement")
		var exiting := RoomState.new(trial + 1)
		exiting.activate()
		h.check(exiting.request_exit(exiting.epoch - 1, 1) == "IGNORED_STALE", "US5.stale_exit")
		h.check(exiting.request_exit(exiting.epoch, 2) == "IGNORED_STALE", "US5.wrong_subject_exit")
		h.check(exiting.request_exit(exiting.epoch, 1) == "ACCEPTED" and exiting.request_exit(exiting.epoch, 1) == "INVALID_STATE", "EC13.exit_latch")
		var dying := RoomState.new(trial + 1)
		dying.activate()
		dying.request_death(dying.epoch, 1)
		h.check(dying.request_exit(dying.epoch, 1) == "INVALID_STATE" and not dying.exit_consumed, "US5.death_before_exit")
