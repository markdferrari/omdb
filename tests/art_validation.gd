extends ValidationContext
## Development-only baseline comparison; production catalogue and saves remain isolated.
const SPIKES := preload("res://scenes/art/hazards/spikes_visual.tscn")
const SAW := preload("res://scenes/art/hazards/saw_visual.tscn")
const ANVIL := preload("res://scenes/art/hazards/anvil_visual.tscn")
var candidate: bool = true
var names_visible: bool = true
var _comparison: Button
var muted: bool = false
var _mute: Button
var _pause: Button
var _names: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	var layer := CanvasLayer.new()
	add_child(layer)
	var bar := HBoxContainer.new()
	bar.position = Vector2(24, 280)
	layer.add_child(bar)
	_comparison = Button.new()
	_comparison.text = "Candidate art (B)"
	_comparison.pressed.connect(toggle_candidate)
	bar.add_child(_comparison)
	_names = Button.new()
	_names.text = "Hide trap names (N)"
	_names.pressed.connect(toggle_names)
	bar.add_child(_names)
	_mute = Button.new()
	_mute.text = "Mute (M)"
	_mute.pressed.connect(toggle_mute)
	bar.add_child(_mute)
	_pause = Button.new()
	_pause.text = "Pause (P)"
	_pause.pressed.connect(toggle_pause)
	bar.add_child(_pause)

func restart() -> void:
	epoch += 1
	if room != null:
		room.retire()
		remove_child(room)
		room.queue_free()
	room = room_scene.instantiate()
	room.process_mode = Node.PROCESS_MODE_PAUSABLE
	room.initialize(epoch, room_definition if room_definition != null else RoomDefinition.new())
	for node in room.get_children():
		if node is SpikeBed:
			node.cosmetic_scene = SPIKES if candidate else null
		elif node is Buzzsaw:
			node.cosmetic_scene = SAW if candidate else null
		elif node is FallingAnvil:
			node.cosmetic_scene = ANVIL if candidate else null
	room.presentation_cue.connect(audio.play_cue)
	add_child(room)
	room.restart_requested.connect(func(command_epoch: int):
		if room != null and room.state.epoch == command_epoch:
			restart.call_deferred())
	_apply_names()

func toggle_candidate() -> void:
	candidate = not candidate
	_comparison.text = "Candidate art (B)" if candidate else "Baseline art (B)"
	restart()

func toggle_names() -> void:
	names_visible = not names_visible
	_names.text = "Hide trap names (N)" if names_visible else "Show trap names (N)"

func toggle_mute() -> void:
	muted = not muted
	audio.apply(0 if muted else .7, 0 if muted else .9)
	_mute.text = "Unmute (M)" if muted else "Mute (M)"

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	_pause.text = "Resume (P)" if get_tree().paused else "Pause (P)"

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			toggle_candidate()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_M:
			toggle_mute()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_P:
			toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_N:
			toggle_names()
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	_apply_names()

func _apply_names() -> void:
	if room == null:
		return
	for hazard in room.get_children():
		if hazard is Buzzsaw or hazard is FallingAnvil:
			var cosmetic := hazard.get_node_or_null("Cosmetic")
			if cosmetic != null:
				cosmetic.set("names_visible", names_visible)
			# Baseline labels are hidden only during label-free recognition.
			if hazard is Buzzsaw:
				hazard.get_node("State").visible = names_visible and not candidate
			elif not candidate:
				hazard._label.visible = names_visible
