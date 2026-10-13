extends Node3D
## Pose derives from the authoritative owner clock, including skipped frames.
var _warning_visible: bool = true
var _warning_remaining: float = 1.0
var names_visible: bool = true:
	set(value):
		names_visible = value
		if is_node_ready():
			_update_label()
const METAL := preload("res://resources/materials/hazard_metal.tres")
func _ready() -> void:
	_apply_metal($Model)

func set_phase(phase: float, warning_seconds: float, cycle_seconds: float) -> void:
	var descent_start := warning_seconds - .15
	var height := 2.7
	if phase >= descent_start and phase < warning_seconds:
		height = lerpf(2.7, 0, (phase-descent_start)/.15)
	elif phase >= warning_seconds and phase <= warning_seconds+.2:
		height = 0
	elif phase < warning_seconds+1.2 and phase > warning_seconds+.2:
		height = lerpf(0, 2.7, (phase-warning_seconds-.2)/1.0)
	$Model.position.y = height
	$Warning.visible = phase < warning_seconds
	_warning_visible = phase < warning_seconds
	_warning_remaining = maxf(0, warning_seconds-phase)
	_update_label()
	# cycle_seconds is supplied by the owner; no independent timer is started.
	$State.set_meta("cycle_seconds", cycle_seconds)

func _update_label() -> void:
	$State.text = ("⚠ ANVIL: %.1fs" if names_visible else "⚠ %.1fs") % _warning_remaining if _warning_visible else "↑ RESETTING"

func _apply_metal(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = METAL
	for child in node.get_children():
		_apply_metal(child)
