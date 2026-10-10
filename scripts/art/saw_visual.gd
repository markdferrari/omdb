extends Node3D
## Cosmetic rotor reads contributor eligibility from Buzzsaw; it owns no contacts.
var names_visible: bool = true
const METAL := preload("res://resources/materials/hazard_metal.tres")
var stopped: bool = false

func _ready() -> void:
	_apply_metal($Rotor)

func set_jammed(value: bool, count: int) -> void:
	stopped = value
	$JamIndicator.visible = value
	$State.text = "■ JAMMED (%d)" % count if value else ("⚠ ACTIVE SAW" if names_visible else "⚠ ACTIVE")
	# Only this instance's indicator changes; base materials remain immutable.

func advance(delta: float) -> void:
	if not stopped:
		$Rotor.rotate_x(delta * 9.0)

func _apply_metal(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = METAL
	for child in node.get_children():
		_apply_metal(child)
