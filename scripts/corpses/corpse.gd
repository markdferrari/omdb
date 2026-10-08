class_name Corpse
extends RigidBody3D
@export var tuning: GameplayTuning = preload("res://resources/gameplay_tuning.tres")
var body_id: String = ""
var epoch: int = 0

func _ready() -> void:
	var box: BoxShape3D = $Shape.shape.duplicate()
	box.size = tuning.corpse_size
	$Shape.shape = box
	mass = tuning.corpse_mass
	linear_damp = tuning.corpse_linear_damp
	lock_rotation = true
	var material := PhysicsMaterial.new()
	material.friction = tuning.corpse_friction
	material.bounce = tuning.corpse_bounce
	physics_material_override = material

func disable_prop() -> void:
	collision_layer = 0
	collision_mask = 0
	$Shape.disabled = true
	freeze = true
	visible = false

func mark_oldest(value: bool) -> void:
	$OldestMarker.visible = value

func release_at(pose: Transform3D) -> void:
	freeze = true
	global_transform = pose
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	collision_layer = 4
	collision_mask = 7
	$Shape.disabled = false
	visible = true
	freeze = false
	sleeping = false
	reset_physics_interpolation()
