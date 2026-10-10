extends Node3D
## Pose derives from the authoritative owner clock, including skipped frames.
var names_visible: bool = true
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
	$State.text = ("⚠ ANVIL: %.1fs" if names_visible else "⚠ %.1fs") % maxf(0, warning_seconds-phase) if phase < warning_seconds else "↑ RESETTING"
	# cycle_seconds is supplied by the owner; no independent timer is started.
	$State.set_meta("cycle_seconds", cycle_seconds)

func _apply_metal(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = METAL
	for child in node.get_children():
		_apply_metal(child)
