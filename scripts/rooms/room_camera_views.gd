class_name RoomCameraViews
extends Node
signal view_changed(view_name: String)
const NAMES := ["South-east", "South-west", "North-west", "North-east"]
const ACTIONS := ["camera_north", "camera_east", "camera_south", "camera_west"]
var camera: Camera3D
var view_index: int = 0
var authored_transform: Transform3D

func _ready() -> void:
	camera = get_parent().get_node_or_null("Camera")
	if camera == null:
		set_process_unhandled_input(false)
		return
	authored_transform = camera.transform
	select_view(0)

func view_name() -> String:
	return NAMES[view_index]

func select_view(index: int) -> void:
	if camera == null:
		return
	view_index = posmod(index, 4)
	# Rotate the authored isometric rig intact: pitch, distance and zoom stay fixed.
	var rotation := Basis(Vector3.UP, -view_index * PI / 2.0)
	camera.transform = Transform3D(rotation * authored_transform.basis, rotation * authored_transform.origin)
	camera.reset_physics_interpolation()
	# The perimeter stays solid; camera-side meshes must not hide the puzzle.
	var near_side := Vector3(camera.position.x, 0, camera.position.z).normalized()
	for name in ["Wall0", "Wall1", "Wall2", "FrontBoundary"]:
		var wall := get_parent().get_node_or_null(name) as Node3D
		if wall != null:
			for child in wall.get_children():
				if child is MeshInstance3D:
					child.visible = wall.position.dot(near_side) <= 0
	view_changed.emit(view_name())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	for index in range(4):
		if event.is_action_pressed(ACTIONS[index]):
			select_view(index)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("camera_next"):
		select_view(view_index + 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("camera_previous"):
		select_view(view_index - 1)
		get_viewport().set_input_as_handled()
