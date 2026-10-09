extends RefCounted
const HELP := preload("res://tests/physics/test_placement.gd")

func run(h: SceneTree) -> void:
	var helper = HELP.new()
	for trial in range(10):
		for scenario in ["pending_death", "feedback", "held_oldest", "jammed", "placement"]:
			var game: GameSession = load("res://scenes/main.tscn").instantiate()
			game.store = SaveStore.new(SavePaths.get_root().path_join("authored_lifecycle_%d_%s" % [trial, scenario]))
			h.root.add_child(game)
			var initial: Array = []
			game.room_activated.connect(func(_id: String, _epoch: int):
				var anvil: FallingAnvil = game.active_room.get_node("Anvil")
				initial.append(anvil.elapsed == 0 and anvil.warning and anvil.impact_count == 0))
			game.request_activation("room_05")
			await h.frames(3)
			var old := game.active_room
			var epoch := old.state.epoch
			var body := helper.add_body(old, Vector3(-8.7, 0.245, 0))
			old.state.pickup(epoch, old.state.subject_id, body.body_id)
			body.disable_prop()
			old._publish_snapshot()
			if scenario in ["pending_death", "feedback"]:
				old.request_death(epoch, old.state.subject_id, "reset_probe", old.player.global_transform)
				if scenario == "feedback":
					await h.frames(2)
					old._replace_subject.call_deferred(old.state.death_token)
			elif scenario == "jammed":
				helper.add_body(old, Vector3(-3, 0.245, 0))
				await h.frames(30)
				h.check(old.saws[0].jammed(), "EC09.authored_prepared_jam")
			elif scenario == "placement":
				old.player.facing = Vector3.RIGHT
				old.request_interact(epoch, old.state.subject_id)
			h.check(game.request_restart(epoch) == "ACCEPTED" and old.state.phase == RoomState.Phase.RETIRED, "EC09.authored_restart_cancels_pending_work")
			await h.frames(70)
			var fresh := game.active_room
			h.check(fresh != old and fresh.state.epoch > epoch and fresh.state.subject_id == 1 and fresh.state.registry.count() == 0 and fresh.state.held_body_id.is_empty() and fresh.player.alive, "US4.authored_lifecycle_fresh_equivalence")
			h.check(game.room_host.get_child_count() == 1 and not fresh.saws[0].jammed() and fresh.plates[0].weight() == 0 and not fresh.doors[0].is_open and initial.back(), "US4.authored_lifecycle_initial_machinery")
			h.check(game.request_restart(epoch) == "IGNORED_STALE", "EC09.authored_stale_restart_rejected")
			game.request_activation("room_06")
			game.request_restart(fresh.state.epoch)
			await h.frames(3)
			h.check(game.current_room_id == "room_05" and game.store.read_progress().room_id == "room_05", "EC10.authored_restart_before_activation")
			game.request_activation("room_06")
			await h.frames(3)
			game.request_restart(game.active_room.state.epoch)
			await h.frames(3)
			h.check(game.current_room_id == "room_06" and game.store.read_progress().room_id == "room_06", "EC10.authored_restart_after_activation")
			game.queue_free()
			await h.frames(2)
