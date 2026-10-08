class_name ExitDoor
extends Node3D
@export var exit_id: String = "exit"
@export var linked_plate_id: String = "plate"
@export var passage_size: Vector3 = Vector3(0.5, 2.4, 2.2)
var is_open: bool = false

func set_open(value: bool, player: PlayerController = null) -> void:
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
	if get_parent() is RoomController:
		get_parent().doors.append(self)
