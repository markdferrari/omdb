extends Node3D
## Root authoring properties survive source and compiled scene export equally.
@export var passage_offset: float = 0.0

func _ready() -> void:
	if is_zero_approx(passage_offset):
		return
	var ranges := [Vector2(-6, passage_offset - 1.1), Vector2(passage_offset + 1.1, 6)]
	for index in range(2):
		var wall: StaticBody3D = get_node("North" if index == 0 else "South")
		var span: Vector2 = ranges[index]
		wall.position.z = (span.x + span.y) * 0.5
		var shape: BoxShape3D = wall.get_node("Shape").shape.duplicate()
		shape.size.z = span.y - span.x
		wall.get_node("Shape").shape = shape
		var mesh: BoxMesh = wall.get_node("Mesh").mesh.duplicate()
		mesh.size.z = span.y - span.x
		wall.get_node("Mesh").mesh = mesh
	$Lintel.position.z = passage_offset
