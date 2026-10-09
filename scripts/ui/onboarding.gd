extends Label
## Teaching follows authoritative room snapshots and current input method.
var _room: RoomController
var _prompts: InputPrompts
var _snapshot: Dictionary = {}

func _ready() -> void:
	_bind.call_deferred()

func _bind() -> void:
	_room = get_parent().get_parent() as RoomController
	_prompts = get_parent()._prompts
	_room.room_snapshot_changed.connect(_refresh)
	_prompts.method_changed.connect(func(_method: String): _refresh(_snapshot))
	_refresh(_room.state.snapshot())

func _refresh(snapshot: Dictionary) -> void:
	_snapshot = snapshot.duplicate(true)
	var cues := _room.definition.onboarding_cues
	visible = not cues.is_empty()
	if not visible:
		return
	var jump := "South" if _prompts.method == "controller" else "Space"
	var interact := "West" if _prompts.method == "controller" else "E"
	var instruction := _room.definition.teaching_goal
	if "body_support" in cues and "carry" not in cues:
		if snapshot.body_count == 0:
			instruction = "The spikes are too wide for one jump. A sacrifice leaves a solid body for your next clone."
		else:
			instruction = "Your body remains. %s: jump onto it, cross its top, then jump to the far bank. The yellow ring marks the ground beneath you; release movement to brake in the air." % jump
	if "carry" in cues:
		instruction = "%s: pick up a nearby body. Face a surface and press again when the placement preview is valid." % interact
	if "weight" in cues:
		instruction += " Each released body adds one weight unit, including a stable stack."
	if "saw" in cues:
		instruction += " A released body stops the saw; picking it up restarts it. Approach from the safe side."
	if "anvil" in cues:
		instruction += " The yellow anvil marker warns before each drop; stay clear when carrying."
	if "limit" in cues:
		instruction = "Use an early body as a step to the observation shelf. Two newer bodies hold the plate; three cross the spikes. The sixth removes the oldest marked body. %s picks up and places." % interact
		if snapshot.body_count == 5:
			instruction = "At capacity: the oldest marked body goes next. Keep plate and bridge bodies newer; the anvil can create the replacement. %s picks up and places." % interact
	if "allocation" in cues:
		instruction = "Two bodies on the plate, one in the saw, two across the spikes. Keep the jam body in place while ferrying the bridge bodies. %s picks up/places; %s jumps. Anvils warn before dropping." % [interact, jump]
	text = "%s\n%s" % [_room.definition.title, instruction]
