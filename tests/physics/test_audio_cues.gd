extends RefCounted
const HELP := preload("res://tests/physics/test_placement.gd")

func run(h: SceneTree) -> void:
	if not ResourceLoader.exists("res://resources/audio_cues.tres"):
		h.check(false, "US7.hazard_cue_mapping_available")
		return
	var helper = HELP.new()
	for trial in range(10):
		var audio := AudioController.new()
		h.root.add_child(audio)
		var cues: Array[String] = []
		if not audio.has_signal("cue_requested"):
			h.check(false, "US7.audio_event_contract")
			audio.queue_free()
			continue
		audio.connect("cue_requested", func(cue: String): cues.append(cue))
		h.check(audio._music.stream.get_length() > 10 and audio._music.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "US7.cheerful_music_loops")
		h.check(audio._voices.size() == 4 and audio._music.bus == "Music", "US7.bounded_audio_voices_separate_music")
		for voice in audio._voices:
			h.check(voice.bus == "SFX", "US7.hazard_voice_sfx_routing")
		var mapping: Resource = load("res://resources/audio_cues.tres")
		var sources: Dictionary = {}
		for cue in ["spike_hit", "saw_hit", "saw_jam", "anvil_warning", "anvil_drop", "body_pop"]:
			var stream: AudioStream = mapping.call("sound", cue)
			h.check(stream != null and stream.get_length() > 0.05 and stream.get_length() < 2, "US7.short_cartoon_cue.%s" % cue)
			if stream != null:
				sources[stream.resource_path] = true
		h.check(sources.size() == 6, "US7.distinct_hazard_sources")
		var room: RoomController = await helper.fixture(h)
		room.connect("presentation_cue", Callable(audio, "play_cue"))
		audio.apply(0, 0)
		room.request_death(room.state.epoch, room.state.subject_id, "spikes", room.player.global_transform)
		room.request_death(room.state.epoch, room.state.subject_id, "saw", room.player.global_transform)
		await h.frames(40)
		h.check(cues.count("spike_hit") == 1 and not cues.has("saw_hit") and room.player.alive, "US7.overlapping_death_cue_once_and_muted_respawn")
		var named_saw: Buzzsaw = load("res://scenes/hazards/buzzsaw.tscn").instantiate()
		named_saw.hazard_id = "blade_west"
		named_saw.position = Vector3(4, 0, -4)
		room.add_child(named_saw)
		room.request_death(room.state.epoch, room.state.subject_id, "blade_west", room.player.global_transform)
		await h.frames(40)
		h.check(cues.count("saw_hit") == 1 and cues.count("spike_hit") == 1, "US7.hazard_type_independent_of_authored_id")
		var saw: Buzzsaw = load("res://scenes/hazards/buzzsaw.tscn").instantiate()
		saw.position = Vector3(4, 0, 4)
		room.add_child(saw)
		helper.add_body(room, Vector3(4, 0.245, 4))
		await h.frames(30)
		h.check(saw.jammed() and cues.count("saw_jam") == 1, "US7.jam_cue_on_transition_not_every_tick")
		var anvil: FallingAnvil = load("res://scenes/hazards/anvil.tscn").instantiate()
		anvil.position = Vector3(2, 0, -4)
		room.add_child(anvil)
		await h.frames(200)
		h.check(cues.count("anvil_warning") == 2 and cues.count("anvil_drop") == 1, "US7.warning_and_impact_once_per_cycle")
		var impact_cues := cues.count("anvil_drop")
		room.player.position = anvil.position + Vector3.UP * 0.1
		await h.frames(100)
		h.check(cues.count("anvil_drop") == impact_cues + 1 and room.player.alive, "US7.lethal_anvil_impact_not_duplicated")
		room.retire()
		var count_before := cues.size()
		await h.frames(120)
		h.check(cues.size() == count_before, "US7.retired_room_emits_no_cues")
		await helper.dispose(h, room)
		audio.queue_free()
		await h.frames(2)
