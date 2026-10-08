extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		var audio := AudioController.new()
		h.root.add_child(audio)
		audio.apply(0, 0.8)
		var music := AudioServer.get_bus_index("Music")
		var sfx := AudioServer.get_bus_index("SFX")
		h.check(music >= 0 and sfx >= 0, "US6.separate_audio_buses")
		if music >= 0 and sfx >= 0:
			h.check(AudioServer.is_bus_mute(music) and not AudioServer.is_bus_mute(sfx) and audio.sfx_volume == 0.8, "SC010.independent_music_mute")
			audio.apply(0.3, 0)
			h.check(not AudioServer.is_bus_mute(music) and AudioServer.is_bus_mute(sfx) and is_equal_approx(AudioServer.get_bus_volume_db(music), linear_to_db(0.3)), "SC010.independent_sfx_mute")
		audio.queue_free()
		await h.frames(2)
