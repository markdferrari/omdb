class_name AudioController
extends Node
signal cue_requested(cue: String)
@export var cues: AudioCues = preload("res://resources/audio_cues.tres")
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
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
	var loop := cues.music.duplicate() as AudioStreamWAV
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_end = loop.data.size() / 2
	_music.stream = loop
	add_child(_music)
	for index in range(4):
		var voice := AudioStreamPlayer.new()
		voice.bus = "SFX"
		add_child(voice)
		_voices.append(voice)
	_sfx = _voices[0]
	_sfx.stream = cues.body_pop
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
	play_cue("body_pop")

func play_cue(cue: String) -> bool:
	var stream := cues.sound(cue)
	if stream == null or _voices.is_empty():
		return false
	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stop()
	voice.stream = stream
	cue_requested.emit(cue)
	if DisplayServer.get_name() != "headless":
		voice.play()
	return true

func _exit_tree() -> void:
	for player in _voices + [_music]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
