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
	apply_observations(observations)

func _ready() -> void:
	if get_parent() is RoomController:
		get_parent().plates.append(self)
