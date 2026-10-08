class_name AudioController
extends Node
var music_volume: float = 0.7
var sfx_volume: float = 0.9
var _music: AudioStreamPlayer
var _sfx: AudioStreamPlayer
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	var loop := load("res://assets/audio/preview_music.wav").duplicate() as AudioStreamWAV
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_end = loop.data.size() / 2
	_music.stream = loop
	add_child(_music)
	_sfx = AudioStreamPlayer.new()
	_sfx.bus = "SFX"
	_sfx.stream = load("res://assets/audio/preview_sfx.wav")
	add_child(_sfx)
	apply(music_volume, sfx_volume)
	# Dummy/headless has no audible output and retains WAV playback at rapid exit.
	if DisplayServer.get_name() != "headless":
		_music.play()
func apply(music: float, sfx: float) -> void:
	music_volume = clampf(music, 0, 1)
	sfx_volume = clampf(sfx, 0, 1)
	for pair in [["Music", music_volume], ["SFX", sfx_volume]]:
		var index := AudioServer.get_bus_index(pair[0])
		if index >= 0:
			AudioServer.set_bus_mute(index, pair[1] == 0)
			AudioServer.set_bus_volume_db(index, linear_to_db(pair[1]) if pair[1] > 0 else -80)
func preview_sfx() -> void:
	if _sfx != null and DisplayServer.get_name() != "headless":
		_sfx.play()
func _exit_tree() -> void:
	for player in [_music, _sfx]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
