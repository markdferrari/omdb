extends Node3D
## Curated, deterministic cosmetic modules; existing room solids remain authoritative.
const INV := preload("res://scripts/checks/art_inventory.gd")
const INK := preload("res://resources/materials/art_ink.tres")
var side_roots: Dictionary = {}
var tile_bounds: Array[AABB] = []
var _room: RoomController

func configure(room: RoomController, footprint: Vector2) -> void:
	_room = room
	var floor_root := Node3D.new()
	floor_root.name = "FloorTiles"
	add_child(floor_root)
	var source := _source("floor_tile_large")
	var mesh := _first_mesh(source)
	var bounds := mesh.get_aabb()
	var poses: Array[Transform3D] = []
	for x in range(int(footprint.x/2)):
		for z in range(int(footprint.y/2)):
			var center := Vector3(-footprint.x/2+1+2*x,0,-footprint.y/2+1+2*z)
			var scale := Vector3(1.95/bounds.size.x,.08/bounds.size.y,1.95/bounds.size.z)
			var pose := Transform3D(Basis.from_scale(scale),center+Vector3(0,.002-bounds.end.y*scale.y,0))
			var box: AABB = pose * bounds
			if not _reserved(box):
				poses.append(pose)
				tile_bounds.append(box)
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = mesh
	batch.instance_count = poses.size()
	for i in range(poses.size()): batch.set_instance_transform(i,poses[i])
	var tiles := MultiMeshInstance3D.new()
	tiles.multimesh = batch
	tiles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_root.add_child(tiles)
	source.free()
	var trim := Node3D.new()
	trim.name = "BoundaryTrim"
	add_child(trim)
	for horizontal in [true,false]:
		for sign_value in [-1.0,1.0]:
			var edge := MeshInstance3D.new()
			var strip := BoxMesh.new()
			strip.size = Vector3(footprint.x+.4,.08,.12) if horizontal else Vector3(.12,.08,footprint.y+.4)
			edge.mesh = strip
			edge.material_override = INK
			edge.position = Vector3(0,.04,sign_value*(footprint.y/2+.2)) if horizontal else Vector3(sign_value*(footprint.x/2+.2),.04,0)
			edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			trim.add_child(edge)
	var props := Node3D.new()
	props.name = "Props"
	add_child(props)
	for side in ["North","South","East","West"]:
		var group := Node3D.new()
		group.name = side
		var horizontal: bool = side in ["North","South"]
		var sign_value := -1.0 if side in ["North","West"] else 1.0
		group.position = Vector3(0,0,sign_value*(footprint.y/2+.2)) if horizontal else Vector3(sign_value*(footprint.x/2+.2),0,0)
		add_child(group)
		side_roots[side] = group
		var span := footprint.x if horizontal else footprint.y
		var models: Dictionary = {}
		for i in range(int(span/2)):
			var model := "wall_cracked" if i % 8 == 3 else ("wall_arched" if i % 4 == 1 else ("wall_pillar" if i % 4 == 2 else "wall"))
			if not models.has(model): models[model] = []
			models[model].append(Vector3(-span/2+1+i*2,0,0) if horizontal else Vector3(0,0,-span/2+1+i*2))
		for model in models:
			_wall_batch(model,group,models[model],0 if horizontal else PI/2)
		# Wall-mounted objects cannot be mistaken for movable puzzle props.
		var cluster := Node3D.new()
		cluster.name = side+"Props"
		cluster.position = group.position
		cluster.rotation.y = PI if side == "South" else (PI/2 if side == "West" else (-PI/2 if side == "East" else 0))
		props.add_child(cluster)
		_piece("shelf_small_candles",cluster,Vector3(1.2,.7,.45),Vector3(-span/2+2,1.0,.25))
		_piece("bottle_A_labeled_brown",cluster,Vector3(.22,.48,.22),Vector3(-span/2+2.3,1.25,.55))
		_piece("candle_lit",cluster,Vector3(.12,.25,.12),Vector3(-span/2+1.8,1.7,.5),null,true)
		_piece("banner_patternA_red",cluster,Vector3(.65,1.15,.10),Vector3(span/2-2, .6,.25))
		_piece("torch_mounted",cluster,Vector3(.3,.65,.28),Vector3(0,1.1,.25))
		_piece("torch_lit",cluster,Vector3(.25,.7,.25),Vector3(0,1.3,.48),null,true)
		_piece("sword_shield",cluster,Vector3(.7,.65,.12),Vector3(span/2-3.1,.85,.25))
		if side == "North":
			var sign: Node3D = load("res://scenes/art/props/trial_sign.tscn").instantiate()
			sign.position = Vector3(-2,1.15,.3)
			cluster.add_child(sign)
		# Small rubble sits within the wall margin, away from authored solution routes.
		var rubble_at := cluster.position + cluster.basis * Vector3(-span/2+.6,0,.1)
		if not _reserved(AABB(rubble_at-Vector3(.3,0,.15),Vector3(.6,.3,.3))):
			_piece("rubble_half",cluster,Vector3(.6,.3,.3),Vector3(-span/2+.6,0,.1))
		room.camera_views.register_cosmetic_root(group,group.position)
		room.camera_views.register_cosmetic_root(cluster,group.position)
	for wall_name in ["Wall0","Wall1","Wall2","FrontBoundary"]:
		var wall := room.get_node_or_null(wall_name)
		if wall != null:
			for child in wall.get_children():
				if child is MeshInstance3D:
					child.set_meta("cosmetic_replaced",true)
					child.hide()
	# Closed grate at the existing entrance, flush with its supported floor.
	var spawn: Node3D = room.get_node("Spawn")
	_piece("floor_tile_big_grate",self,Vector3(1.5,.07,1.5),Vector3(spawn.position.x,-.069,spawn.position.z))
	room.camera_views.select_view(room.camera_views.view_index)

func _reserved(box: AABB) -> bool:
	var spawn: Node3D = _room.get_node("Spawn")
	if box.intersects(AABB(Vector3(spawn.position.x-.75,-1,spawn.position.z-.75),Vector3(1.5,2,1.5))):
		return true
	for owner in _room.get_children():
		var region := AABB()
		if owner is SpikeBed:
			var size: Vector3 = owner.get_node("Bed/Shape").shape.size
			region = AABB(owner.position-Vector3(size.x/2,1,size.z/2),Vector3(size.x,2,size.z))
		elif owner is Buzzsaw:
			region = AABB(owner.position-Vector3(.35,1,1.2),Vector3(.7,2,2.4))
		elif owner is FallingAnvil:
			region = AABB(owner.position-Vector3(1,1,1),Vector3(2,2,2))
		else: continue
		if box.intersects(region): return true
	return false

func _source(model: String) -> Node3D:
	if model == "floor_tile_big_grate":
		return load("res://scenes/art/props/entrance_hatch.tscn").instantiate()
	return load("res://assets/art/kaykit_dungeon/"+model+".gltf").instantiate()

func _wall_batch(model: String,parent: Node3D,anchors: Array,yaw: float) -> void:
	var source := _source(model)
	var mesh := _first_mesh(source)
	var box := mesh.get_aabb()
	var scale := Vector3(1.98/box.size.x,2/box.size.y,.4/box.size.z)
	var rotation := Basis(Vector3.UP,yaw)
	var offset := rotation * -Vector3(box.get_center().x*scale.x,box.position.y*scale.y,box.get_center().z*scale.z)
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = mesh
	batch.instance_count = anchors.size()
	for i in range(anchors.size()):
		batch.set_instance_transform(i,Transform3D(rotation*Basis.from_scale(scale),anchors[i]+offset))
	var tiles := MultiMeshInstance3D.new()
	tiles.name = model
	tiles.multimesh = batch
	parent.add_child(tiles)
	source.free()

func _piece(model: String,parent: Node3D,size: Vector3,bottom: Vector3,material: Material=null,warm: bool=false) -> void:
	var source := _source(model)
	var box: AABB = INV.inspect(source).bounds
	var scale := Vector3(size.x/box.size.x,size.y/box.size.y,size.z/box.size.z)
	var wrapper := Node3D.new()
	wrapper.name = model
	wrapper.position = bottom
	parent.add_child(wrapper)
	wrapper.add_child(source)
	source.scale = scale
	source.position = -Vector3(box.get_center().x*scale.x,box.position.y*scale.y,box.get_center().z*scale.z)
	_style(source,material,warm,not model.begins_with("wall"))

func _style(node: Node,material: Material,warm: bool=false,no_shadow: bool=false) -> void:
	if node is MeshInstance3D:
		if material != null: node.material_override = material
		if warm:
			var atlas: StandardMaterial3D = node.mesh.surface_get_material(0).duplicate()
			atlas.emission_enabled = true
			atlas.emission = Color(.25,.10,.025)
			atlas.emission_texture = atlas.albedo_texture
			node.material_override = atlas
		if no_shadow:
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children(): _style(child,material,warm,no_shadow)

func _first_mesh(node: Node) -> Mesh:
	if node is MeshInstance3D: return node.mesh
	for child in node.get_children():
		var mesh := _first_mesh(child)
		if mesh != null: return mesh
	return null
