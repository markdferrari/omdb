class_name PlayerController
extends CharacterBody3D
signal restart_requested(epoch: int)
signal interact_requested(epoch: int, subject_id: int)
var is_carrying_visual: bool = false
signal lethal_contact(epoch: int, subject_id: int, hazard_id: String, death_transform: Transform3D)

@export var tuning: GameplayTuning = preload("res://resources/gameplay_tuning.tres")
var epoch: int = 0
var subject_id: int = 0
var alive: bool = true
var facing: Vector3 = Vector3.FORWARD
var camera: Camera3D
var _jump_remaining: float = 0.0
var _coyote_remaining: float = 0.0
var movement_override: Vector2 = Vector2.ZERO
var use_movement_override: bool = false

func _ready() -> void:
	var capsule: CapsuleShape3D = $Shape.shape.duplicate()
	capsule.radius = tuning.player_radius
	capsule.height = tuning.player_height
	$Shape.shape = capsule
	$Shape.position.y = tuning.player_height * 0.5
	process_physics_priority = 100
	floor_snap_length = tuning.floor_snap
	platform_on_leave = CharacterBody3D.PLATFORM_ON_LEAVE_DO_NOTHING
	platform_floor_layers = 0
	camera = get_viewport().get_camera_3d()

static func ground_direction(input: Vector2, camera_basis: Basis) -> Vector3:
	var right := camera_basis.x
	right.y = 0
	right = right.normalized()
	# Orthogonal ground-plane forward preserves diagonal and analog magnitudes.
	var forward := Vector3.UP.cross(right).normalized()
	return right * input.x - forward * input.y

func queue_jump(event: InputEvent) -> void:
	if alive and event.is_action_pressed("jump") and not event.is_echo():
		_jump_remaining = tuning.jump_buffer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_room") and not event.is_echo():
		get_viewport().set_input_as_handled()
		restart_requested.emit(epoch)
		return
	queue_jump(event)
	if alive and event.is_action_pressed("interact") and not event.is_echo():
		interact_requested.emit(epoch, subject_id)

func _physics_process(delta: float) -> void:
	if not alive:
		return
	var input := movement_override if use_movement_override else Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var basis := camera.global_basis if camera != null else Basis.IDENTITY
	var direction := ground_direction(input, basis)
	if direction.length_squared() > 0.0001:
		facing = direction.normalized()
	velocity.x = move_toward(velocity.x, direction.x * tuning.move_speed, tuning.acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * tuning.move_speed, tuning.acceleration * delta)
	_coyote_remaining = tuning.coyote_time if is_on_floor() else maxf(0, _coyote_remaining - delta)
	if _jump_remaining > 0 and _coyote_remaining > 0:
		velocity.y = tuning.jump_speed
		_jump_remaining = 0
		_coyote_remaining = 0
	else:
		velocity.y -= tuning.gravity * delta
	_jump_remaining = maxf(0, _jump_remaining - delta)
	move_and_slide()
	$CarryAnchor.position = facing * 0.6 + Vector3.UP * 1.2
	_update_shadow()

func report_lethal(hazard_id: String) -> void:
	if alive:
		lethal_contact.emit(epoch, subject_id, hazard_id, global_transform)

func disable_actor() -> void:
	alive = false
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	$Shape.disabled = true

func _update_shadow() -> void:
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.1, global_position + Vector3.DOWN * 20, 5)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	$GroundShadow.visible = not hit.is_empty()
	if not hit.is_empty():
		$GroundShadow.global_position = hit.position + Vector3.UP * 0.008
