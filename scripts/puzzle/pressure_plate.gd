class_name PressurePlate
extends StaticBody3D
@export var plate_id: String = "plate"
@export_range(1, 5) var required_weight: int = 1
var contributors: Dictionary = {}
var _material: StandardMaterial3D

func weight() -> int:
	return contributors.size()

func active() -> bool:
	return weight() >= required_weight

func apply_observations(observations: Array[Dictionary]) -> void:
	contributors.clear()
	for observation in observations:
		if observation.eligible and observation.direct:
			contributors[observation.id] = true
	if is_inside_tree():
		$Label.text = "WEIGHT %d / %d\n%s" % [weight(), required_weight, "OPEN" if active() else "ADD WEIGHT"]
		if _material == null:
			_material = StandardMaterial3D.new()
			$Mesh.material_override = _material
		_material.albedo_color = Color(0.2, 0.9, 0.6) if active() else Color(0.8, 0.55, 0.15)

func reconcile(room: RoomController) -> void:
	var observations: Array[Dictionary] = []
	var actors: Array[Node3D] = []
	if is_instance_valid(room.player) and room.player.alive:
		actors.append(room.player)
	for body in room.bodies.values():
		if room.state.registry.eligible(body.body_id):
			actors.append(body)
	for actor in actors:
		var foot := actor.global_position
		var identity: String
		if actor is Corpse:
			foot.y -= room.tuning.corpse_size.y * 0.5
			identity = actor.body_id
		else:
			identity = "player:%d:%d" % [room.state.epoch, room.state.subject_id]
		var velocity_y: float = actor.linear_velocity.y if actor is Corpse else actor.velocity.y
		var ray := PhysicsRayQueryParameters3D.create(foot + Vector3.UP * 0.025, foot + Vector3.DOWN * 0.06, 5, [actor.get_rid()])
		var hit := get_world_3d().direct_space_state.intersect_ray(ray)
		var direct: bool = not hit.is_empty() and hit.collider == self and absf(velocity_y) < 0.2 and hit.normal.y >= 0.95
		observations.append({"id": identity, "eligible": true, "direct": direct})
	# A stacked corpse transfers its support to the plate through the corpse below it.
	# Count every released body in that stable support chain, while keeping held bodies
	# and bodies resting beside the plate out of the contributor set.
	var direct_ids: Dictionary = {}
	for observation in observations:
		if observation.eligible and observation.direct:
			direct_ids[observation.id] = true
	var stacked_ids: Dictionary = {}
	for body in room.bodies.values():
		if not room.state.registry.eligible(body.body_id) or direct_ids.has(body.body_id):
			continue
		if _rests_on_plate_chain(body, room, direct_ids, {}) :
			stacked_ids[body.body_id] = true
	for body_id in stacked_ids:
		direct_ids[body_id] = true
	for observation in observations:
		if direct_ids.has(observation.id):
			observation.direct = true
	apply_observations(observations)

func _rests_on_plate_chain(body: Corpse, room: RoomController, direct_ids: Dictionary, visited: Dictionary) -> bool:
	if visited.has(body.body_id):
		return false
	visited[body.body_id] = true
	var half := room.tuning.corpse_size * 0.5
	var body_bottom: float = body.global_position.y - half.y
	for support in room.bodies.values():
		if support == body or not room.state.registry.eligible(support.body_id):
			continue
		var support_top: float = support.global_position.y + half.y
		if absf(body_bottom - support_top) > room.tuning.support_height_tolerance + 0.035:
			continue
		var overlap_x := absf(body.global_position.x - support.global_position.x) < room.tuning.corpse_size.x - 0.02
		var overlap_z := absf(body.global_position.z - support.global_position.z) < room.tuning.corpse_size.z - 0.02
		if not overlap_x or not overlap_z:
			continue
		if direct_ids.has(support.body_id) or _rests_on_plate_chain(support, room, direct_ids, visited):
			return true
	return false

func _ready() -> void:
	if get_parent() is RoomController:
		get_parent().plates.append(self)
