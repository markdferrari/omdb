extends Node3D
## Owner-fed cues only; the original plate remains the supporting surface.
const TILE := preload("res://assets/art/kaykit_dungeon/floor_tile_large.gltf")
const INV := preload("res://scripts/checks/art_inventory.gd")

func configure(size: Vector3) -> void:
	var slab := TILE.instantiate()
	slab.name = "Slab"
	add_child(slab)
	var box: AABB = INV.inspect(slab).bounds
	var scale := Vector3(size.x/box.size.x,size.y/box.size.y,size.z/box.size.z)
	slab.scale = scale
	slab.position = -Vector3(box.get_center().x*scale.x,box.position.y*scale.y,box.get_center().z*scale.z)
	for state in [false,true]:
		var cue := Node3D.new()
		cue.name = "ActiveCue" if state else "IdleCue"
		add_child(cue)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(.2,.9,.6) if state else Color(.8,.55,.15)
		var batch := MultiMesh.new()
		batch.transform_format = MultiMesh.TRANSFORM_3D
		var cube := BoxMesh.new()
		cube.size = Vector3.ONE
		batch.mesh = cube
		batch.instance_count = 4
		var index := 0
		for horizontal in [false,true]:
			for side in [-1.0,1.0]:
				var strip_size := Vector3(size.x,.012,.06) if horizontal else Vector3(.06,.012,size.z)
				var point := Vector3(0,size.y,side*(size.z/2-.03)) if horizontal else Vector3(side*(size.x/2-.03),size.y,0)
				batch.set_instance_transform(index,Transform3D(Basis.from_scale(strip_size),point))
				index += 1
		var edges := MultiMeshInstance3D.new()
		edges.multimesh = batch
		edges.material_override = material
		edges.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cue.add_child(edges)
	set_active(false)

func set_active(value: bool) -> void:
	$ActiveCue.visible = value
	$IdleCue.visible = not value
