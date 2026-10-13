extends Node3D
## Persistent arch, disappearing iron gate; owner still controls the solid blocker.
const FRAME := preload("res://assets/art/kaykit_dungeon/wall_doorway.gltf")
const GATE := preload("res://assets/art/kaykit_dungeon/wall_gated.gltf")
const INV := preload("res://scripts/checks/art_inventory.gd")

func configure(passage: Vector3) -> void:
	var frame := Node3D.new()
	frame.name = "Frame"
	frame.rotation.y = PI/2
	add_child(frame)
	var arch := FRAME.instantiate()
	# The kit's wooden door is a separate named mesh. Retain only the stone arch.
	_remove_door(arch)
	_trim_frame(arch)
	frame.add_child(arch)
	# Original opening is 2 m wide with a 2.75 m door; pad for the full clear passage.
	arch.scale = Vector3((passage.z+.2)/2, (passage.y+.25)/2.75, passage.x)
	var gate := Node3D.new()
	gate.name = "Gate"
	gate.rotation.y = PI/2
	add_child(gate)
	var model := GATE.instantiate()
	gate.add_child(model)
	var box: AABB = INV.inspect(model).bounds
	model.scale = Vector3(passage.z/box.size.x,passage.y/box.size.y,passage.x/box.size.z)
	model.position = -Vector3(box.get_center().x*model.scale.x,box.position.y*model.scale.y,box.get_center().z*model.scale.z)
	set_open(false)

func set_open(value: bool) -> void:
	$Gate.visible = not value

func _remove_door(node: Node) -> void:
	for child in node.get_children():
		if str(child.name).begins_with("wall_doorway_door"):
			child.free()
		else:
			_remove_door(child)

func _trim_frame(node: Node) -> void:
	# The source has wide wall wings and a tall header. Compress these cosmetic parts
	# around its original opening so the arch does not screen adjacent traps or labels.
	if node is MeshInstance3D and node.mesh is ArrayMesh:
		var trimmed := ArrayMesh.new()
		for surface in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for i in range(vertices.size()):
				vertices[i].x = clampf(vertices[i].x,-1.15,1.15)
				if vertices[i].y > 2.75:
					vertices[i].y = 2.75+(vertices[i].y-2.75)*.12
			arrays[Mesh.ARRAY_VERTEX] = vertices
			trimmed.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			trimmed.surface_set_material(surface,node.mesh.surface_get_material(surface))
		node.mesh = trimmed
	for child in node.get_children():
		_trim_frame(child)
