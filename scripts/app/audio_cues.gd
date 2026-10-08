class_name AudioCues
extends Resource
@export var music: AudioStream
@export var spike_hit: AudioStream
@export var saw_hit: AudioStream
@export var saw_jam: AudioStream
@export var anvil_warning: AudioStream
@export var anvil_drop: AudioStream
@export var body_pop: AudioStream

func sound(cue: String) -> AudioStream:
	return {"spike_hit": spike_hit, "saw_hit": saw_hit, "saw_jam": saw_jam,
		"anvil_warning": anvil_warning, "anvil_drop": anvil_drop, "body_pop": body_pop}.get(cue)
