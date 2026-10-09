class_name ExitDoor
extends Node3D
@export var exit_id: String = "exit"
@export var linked_plate_id: String = "plate"
@export var passage_size: Vector3 = Vector3(0.5, 2.4, 2.2)
var is_open: bool = false
var _observed_subject: int = -1
var _previous_position: Vector3
var _crossing_subject: int = -1

func has_crossing(player: PlayerController) -> bool:
	return is_instance_valid(player) and player.alive and _crossing_subject == player.subject_id

func _physics_process(_delta: float) -> void:
	var room := get_parent() as RoomController
	if room == null or not is_instance_valid(room.player) or not room.player.alive:
		_observed_subject = -1
		_crossing_subject = -1
		return
	var player := room.player
	var point := to_local(player.global_position)
	if _observed_subject == player.subject_id and is_open:
		# Follow the segment through the passage plane, so a fast crossing cannot
		# skip a thin sensor. Only entry-to-exit travel completes the room.
		var plane := passage_size.x * 0.5
		if _previous_position.x <= plane and point.x > plane:
			var fraction := (plane - _previous_position.x) / (point.x - _previous_position.x)
			var crossing := _previous_position.lerp(point, fraction)
			if absf(crossing.z) <= passage_size.z * 0.5 and crossing.y >= -0.1 and crossing.y <= passage_size.y:
				_crossing_subject = player.subject_id
				room.request_exit(player.epoch, player.subject_id, exit_id)
	_previous_position = point
	_observed_subject = player.subject_id

func set_open(value: bool, player: PlayerController = null) -> void:
	if not value:
		_crossing_subject = -1
	if is_inside_tree():
		# Query the actor's actual position; never rely on stale Area overlap caches.
		if not value and is_instance_valid(player) and player.alive:
			var local: Vector3 = $Blocker.to_local(player.global_position + Vector3.UP * 0.75)
			if absf(local.x) <= passage_size.x * 0.5 + player.tuning.player_radius and absf(local.z) <= passage_size.z * 0.5 + player.tuning.player_radius and absf(local.y) <= passage_size.y * 0.5:
				# Authored direction is +X; the reserved anchor is on the entry side.
				player.global_position = $Retreat.global_position
				player.velocity = Vector3.ZERO
				player.reset_physics_interpolation()
		$Blocker/Shape.disabled = value
		$Blocker.visible = not value
		$Label.text = "EXIT OPEN" if value else "EXIT LOCKED"
	is_open = value

func _ready() -> void:
	process_physics_priority = 200
	if get_parent() is RoomController:
		get_parent().doors.append(self)
