extends Node3D
## Cosmetic rotor reads contributor eligibility from Buzzsaw; it owns no contacts.
var _contributor_count: int = 0
var names_visible: bool = true:
	set(value):
		names_visible = value
		if is_node_ready():
			_update_label()
const METAL := preload("res://resources/materials/hazard_metal.tres")
var stopped: bool = false

func _ready() -> void:
	_apply_metal($Rotor)

func set_jammed(value: bool, count: int) -> void:
	stopped = value
	$JamIndicator.visible = value
	_contributor_count = count
	_update_label()
	# Only this instance's indicator changes; base materials remain immutable.

func _update_label() -> void:
	$State.text = "■ JAMMED (%d)" % _contributor_count if stopped else ("⚠ ACTIVE SAW" if names_visible else "⚠ ACTIVE")

func advance(delta: float) -> void:
	if not stopped:
		$Rotor.rotate_x(delta * 9.0)

func _apply_metal(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = METAL
	for child in node.get_children():
		_apply_metal(child)
