extends RefCounted
## Runtime inventory, including transformed and repeated geometry. No physics queries.
static func inspect(root: Node) -> Dictionary:
	var result := {"triangles": 0, "surfaces": 0, "materials": {}, "textures": {}, "forbidden": [], "bounds": AABB(), "has_bounds": false}
	_visit(root, Transform3D.IDENTITY, result)
	return result

static func _visit(node: Node, parent_transform: Transform3D, result: Dictionary) -> void:
	var pose := parent_transform
	if node is Node3D:
		pose *= node.transform
	if node is CollisionObject3D or node is CollisionShape3D or node is Camera3D or node is Light3D:
		result.forbidden.append(str(node.get_path()) if node.is_inside_tree() else str(node.name))
	if node is MeshInstance3D and node.mesh != null:
		_mesh(node.mesh, pose, result, node.material_override)
	elif node is MultiMeshInstance3D and node.multimesh != null and node.multimesh.mesh != null:
		for i in range(node.multimesh.instance_count):
			_mesh(node.multimesh.mesh, pose * node.multimesh.get_instance_transform(i), result, node.material_override)
	for child in node.get_children():
		_visit(child, pose, result)

static func _mesh(mesh: Mesh, pose: Transform3D, result: Dictionary, override: Material) -> void:
	var box: AABB = pose * mesh.get_aabb()
	result.bounds = result.bounds.merge(box) if result.has_bounds else box
	result.has_bounds = true
	for surface in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface)
		if (not mesh is ArrayMesh or mesh.surface_get_primitive_type(surface) == Mesh.PRIMITIVE_TRIANGLES) and arrays.size() > Mesh.ARRAY_INDEX:
			var indices = arrays[Mesh.ARRAY_INDEX]
			var vertices = arrays[Mesh.ARRAY_VERTEX]
			result.triangles += (indices.size() if indices != null and indices.size() > 0 else vertices.size()) / 3
		result.surfaces += 1
		var material := override if override != null else mesh.surface_get_material(surface)
		if material != null:
			result.materials[material.get_instance_id()] = true
			if material is BaseMaterial3D:
				for property in material.get_property_list():
					if property.name.ends_with("_texture"):
						var texture = material.get(property.name)
						if texture is Texture2D:
							result.textures[texture.get_instance_id()] = [texture.get_width(), texture.get_height()]
