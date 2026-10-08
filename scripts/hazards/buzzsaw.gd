class_name Buzzsaw
extends Node3D
## No solid rotor collider: the stopped route remains traversable.
@export var hazard_id: String = "saw"
var contributors: Dictionary = {}
var _material: StandardMaterial3D

func jammed() -> bool:
	return not contributors.is_empty()

func apply_candidates(ids: Array[String], registry: CorpseRegistry) -> void:
	contributors.clear()
	for identity in ids:
		if registry.eligible(identity):
			contributors[identity] = true
	_update_visual()

func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	$Rotor.material_override = _material
	$Lethal.body_entered.connect(_on_body_entered)
	if get_parent() is RoomController:
		get_parent().saws.append(self)
	_update_visual()

func reconcile(room: RoomController) -> void:
	var ids: Array[String] = []
	for hit in _overlaps($JamPoint, 4):
		if hit.collider is Corpse and hit.collider.epoch == room.state.epoch:
			ids.append(hit.collider.body_id)
	apply_candidates(ids, room.state.registry)
	# Query current physics state, including a player already inside at reactivation.
	if not jammed():
		for hit in _overlaps($Lethal/Shape, 2):
			_on_body_entered(hit.collider)

func _overlaps(shape_node: CollisionShape3D, mask: int) -> Array[Dictionary]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.collision_mask = mask
	return get_world_3d().direct_space_state.intersect_shape(query, 32)

func _on_body_entered(body: Node3D) -> void:
	if not jammed() and body is PlayerController:
		body.report_lethal(hazard_id)

func _physics_process(delta: float) -> void:
	if not jammed():
		$Rotor.rotate_z(delta * 9.0)

func _update_visual() -> void:
	if not is_inside_tree() or _material == null:
		return
	var color := Color(0.15, 0.95, 0.65) if jammed() else Color(1, 0.1, 0.3)
	_material.albedo_color = color
	_material.emission = color * 0.3
	$State.text = "■ JAMMED (%d)" % contributors.size() if jammed() else "⚠ ACTIVE SAW"
