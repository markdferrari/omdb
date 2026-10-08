extends RefCounted
const HELP := preload("res://tests/physics/test_placement.gd")
func run(h: SceneTree) -> void:
	var helper = HELP.new()
	for trial in range(10):
		for scenario in ["pending_death", "feedback", "held_oldest", "jammed", "placement"]:
			var game: GameSession = load("res://scenes/main.tscn").instantiate()
			game.auto_start = false
			game.catalogue = load("res://tests/scenes/recovery_catalogue.tres")
			game.store = SaveStore.new(SavePaths.get_root().path_join("reset_%d_%s" % [trial, scenario]))
			h.root.add_child(game)
			var activation_trace: Dictionary = {}
			game.room_activated.connect(func(_id: String, _epoch: int):
				var anvil: FallingAnvil = game.active_room.get_node("AnvilStation")
				activation_trace["initial_anvil"] = anvil.elapsed == 0 and anvil.warning and anvil.impact_count == 0)
			h.check(game.request_activation("room_01") == "ACCEPTED", "US4.activation_request")
			await h.frames(3)
			if game.active_room == null:
				h.check(false, "US4.room_activation")
				game.queue_free()
				await h.frames(2)
				continue
			var old := game.active_room
			var epoch := old.state.epoch
			var body := helper.add_body(old, Vector3(-3.7, 0.245, 0))
			old.state.pickup(epoch, old.state.subject_id, body.body_id)
			body.disable_prop()
			old._publish_snapshot()
			if scenario in ["pending_death", "feedback"]:
				old.request_death(epoch, old.state.subject_id, "fixture", old.player.global_transform)
				if scenario == "feedback":
					await h.frames(2)
					old._replace_subject.call_deferred(old.state.death_token)
			elif scenario == "jammed":
				helper.add_body(old, Vector3(3.5, 0.245, -4.1))
				await h.frames(30)
				h.check(old.saws[0].jammed(), "EC09.prepared_jam")
			elif scenario == "placement":
				old.request_interact(epoch, old.state.subject_id)
			h.check(game.request_restart(epoch) == "ACCEPTED" and old.state.phase == RoomState.Phase.RETIRED, "EC09.restart_cancels_pending_death")
			await h.frames(70)
			var fresh := game.active_room
			h.check(fresh != old and fresh.state.epoch > epoch and fresh.state.subject_id == 1 and fresh.state.registry.count() == 0 and fresh.state.held_body_id.is_empty() and fresh.player.alive, "US4.fresh_state_equivalence")
			h.check(game.room_host.get_child_count() == 1 and not fresh.saws[0].jammed() and fresh.plates[0].weight() == 0 and not fresh.doors[0].is_open, "US4.fresh_machinery_one_room")
			h.check(activation_trace.get("initial_anvil", false), "EC09.initial_anvil_restored_at_commit")
			h.check(game.request_restart(epoch) == "IGNORED_STALE", "EC09.old_restart_rejected")
			game.request_activation("room_02")
			game.request_restart(fresh.state.epoch)
			await h.frames(3)
			h.check(game.current_room_id == "room_01" and game.store.read_progress().room_id == "room_01", "EC10.restart_before_activation_keeps_committed_room")
			game.request_activation("room_02")
			await h.frames(3)
			game.request_restart(game.active_room.state.epoch)
			await h.frames(3)
			h.check(game.current_room_id == "room_02" and game.store.read_progress().room_id == "room_02", "EC10.restart_after_activation_targets_new_room")
			game.queue_free()
			await h.frames(2)
