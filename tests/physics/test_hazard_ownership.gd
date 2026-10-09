extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var game: GameSession = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new(SavePaths.get_root().path_join("hazard_owner_%d" % trial))
		h.root.add_child(game)
		game.activate_room(game.catalogue.find("room_01"), false)
		var old := game.active_room
		var spikes: SpikeBed = old.get_node("Spikes")
		game.activate_room(game.catalogue.find("room_02"), false)
		var fresh := game.active_room
		# Emulate a pending body_entered dispatched after the activation commit.
		spikes._on_body_entered(fresh.player)
		h.check(fresh.player.alive and fresh.state.phase == RoomState.Phase.ACTIVE, "EC13.retired_hazard_cannot_kill_new_subject")
		var foreign: Buzzsaw = load("res://scenes/hazards/buzzsaw.tscn").instantiate()
		old.add_child(foreign)
		foreign._on_body_entered(fresh.player)
		h.check(fresh.player.alive, "EC13.retired_saw_cannot_kill_new_subject")
		game.queue_free()
		await h.frames(2)
