extends RefCounted

func run(h: SceneTree) -> void:
	var state := RoomState.new(17)
	h.check(state.phase == RoomState.Phase.INITIALIZING, "foundation.initial_phase")
	state.activate()
	h.check(state.is_live(17, 1) and not state.is_live(16, 1), "foundation.epoch_identity")
	var snapshot := state.snapshot()
	snapshot.ordered_body_ids.append("forged")
	h.check(state.registry.count() == 0 and state.registry.oldest_id().is_empty(), "foundation.snapshot_isolation")
	state.retire()
	h.check(not state.is_live(17, 1), "foundation.retired_ineligible")
	var definition := RoomDefinition.new()
	h.check(not definition.is_progression_room(), "foundation.fixture_not_catalogued")
	for name in ["move_left", "move_right", "move_up", "move_down", "jump", "interact", "restart_room", "pause", "ui_accept", "ui_cancel", "ui_left", "ui_right", "ui_up", "ui_down"]:
		h.check(InputMap.has_action(name) and InputMap.action_get_events(name).size() >= 2 and is_equal_approx(InputMap.action_get_deadzone(name), 0.2), "foundation.input." + name)
