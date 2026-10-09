class_name SpikeBed
extends Node3D
@export var hazard_id: String = "spikes"
@export var bed_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	if bed_size.x > 0 and bed_size.y > 0:
		for path in ["Bed/Shape", "Lethal/Shape"]:
			var shape: BoxShape3D = get_node(path).shape.duplicate()
			shape.size.x = bed_size.x
			shape.size.z = bed_size.y
			get_node(path).shape = shape
		var mesh: BoxMesh = $Mesh.mesh.duplicate()
		mesh.size.x = bed_size.x
		mesh.size.z = bed_size.y
		$Mesh.mesh = mesh
	$Lethal.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var room := get_parent() as RoomController
	if room != null and room.state.phase != RoomState.Phase.RETIRED and body is PlayerController and body == room.player and room.state.is_live(body.epoch, body.subject_id):
		body.report_lethal(hazard_id)
