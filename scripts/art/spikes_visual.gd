extends Node3D
## Shallow spike pattern is bounded by the owner's authored support/lethal footprint.
const SOURCE := preload("res://assets/art/kaykit_dungeon/spike_cluster.glb")
const METAL := preload("res://resources/materials/hazard_metal.tres")
const INK := preload("res://resources/materials/hazard_ink.tres")
var pattern: MultiMeshInstance3D
var outline: Node3D

func configure(size: Vector2) -> void:
	if pattern != null:
		pattern.free()
	if outline != null:
		outline.free()
	var source := SOURCE.instantiate()
	var mesh := _mesh(source)
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = mesh
	var columns := maxi(1, int(ceil(size.x)))
	var rows := maxi(1, int(ceil(size.y)))
	batch.instance_count = columns * rows
	var cell := Vector2(size.x / columns, size.y / rows)
	for x in range(columns):
		for z in range(rows):
			var pose := Transform3D(Basis.from_scale(Vector3(cell.x * .92, 1, cell.y * .92)), Vector3(-size.x/2 + (x+.5)*cell.x, 0, -size.y/2 + (z+.5)*cell.y))
			batch.set_instance_transform(x*rows+z, pose)
	pattern = MultiMeshInstance3D.new()
	pattern.name = "Points"
	pattern.multimesh = batch
	pattern.material_override = METAL
	add_child(pattern)
	source.free()
	outline = Node3D.new()
	outline.name = "DangerBoundary"
	add_child(outline)
	for side in [-1, 1]:
		_bar(Vector3(size.x, .018, .035), Vector3(0, .01, side*(size.y/2-.0175)))
		_bar(Vector3(.035, .018, size.y), Vector3(side*(size.x/2-.0175), .01, 0))

func _mesh(node: Node) -> Mesh:
	if node is MeshInstance3D:
		return node.mesh
	for child in node.get_children():
		var found := _mesh(child)
		if found != null:
			return found
	return null

func _bar(size: Vector3, point: Vector3) -> void:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.material_override = INK
	item.position = point
	outline.add_child(item)
