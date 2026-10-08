class_name FallingAnvil
extends Node3D
## Visual drop and live-only query; never applies impulses to corpse props.
@export var hazard_id: String = "anvil"
@export var warning_seconds: float = 1.0
@export var cycle_seconds: float = 3.0
var elapsed: float = 0.0
var warning: bool = true
var impact_count: int = 0
var _room: RoomController
var _epoch: int
var _last_cycle: int = -1
var _visual: MeshInstance3D
var _label: Label3D
var _impact_shape := BoxShape3D.new()

func _ready() -> void:
	_room = get_parent() as RoomController
	_epoch = _room.state.epoch if _room != null else -1
	_impact_shape.size = Vector3(2.0, 2.0, 2.0)
	_visual = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.8, 0.6, 1.8)
	_visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.35, 0.4)
	_visual.material_override = material
	add_child(_visual)
	var marker := MeshInstance3D.new()
	var target := CylinderMesh.new()
	target.top_radius = 1.42
	target.bottom_radius = 1.42
	target.height = 0.015
	marker.mesh = target
	marker.position.y = 0.025
	var target_material := StandardMaterial3D.new()
	target_material.albedo_color = Color(1, 0.7, 0.05)
	marker.material_override = target_material
	add_child(marker)
	_label = Label3D.new()
	_label.position.y = 3.9
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 32
	_label.outline_size = 8
	add_child(_label)
	_update_visual(0)
	if _room != null:
		_room.presentation_cue.emit("anvil_warning")

func _physics_process(delta: float) -> void:
	if _room == null or _room.state.epoch != _epoch or _room.state.phase == RoomState.Phase.RETIRED:
		return
	var previous_cycle := int(elapsed / cycle_seconds)
	elapsed += delta
	var cycle := int(elapsed / cycle_seconds)
	var phase := fmod(elapsed, cycle_seconds)
	warning = phase < warning_seconds
	if cycle != previous_cycle:
		_room.presentation_cue.emit("anvil_warning")
	if phase >= warning_seconds and _last_cycle != cycle:
		_last_cycle = cycle
		impact_count += 1
		_room.presentation_cue.emit("anvil_drop")
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = _impact_shape
		query.transform = Transform3D(global_basis, global_position + Vector3.UP)
		query.collision_mask = 2
		for hit in get_world_3d().direct_space_state.intersect_shape(query, 8):
			if hit.collider is PlayerController:
				hit.collider.report_lethal(hazard_id)
	_update_visual(phase)

func _update_visual(phase: float) -> void:
	if _visual == null:
		return
	_visual.position.y = 3.0 if warning else lerpf(0.3, 3.0, clampf((phase - warning_seconds - 0.2) / 1.0, 0, 1))
	_label.text = "⚠ ANVIL: %.1fs" % (warning_seconds - phase) if warning else "↑ RESETTING"
