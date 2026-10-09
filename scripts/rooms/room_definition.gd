class_name RoomDefinition
extends Resource
## Immutable metadata. No live puzzle state is stored here.
@export var room_id: String = ""
@export var title: String = ""
@export var teaching_goal: String = ""
@export var scene: PackedScene
@export var next_room_id: String = ""
@export var camera_transform: Transform3D
@export var camera_size: float = 18.0
@export var playable_bounds: AABB
@export var aspect_policy: String = "keep"
@export var spawn: Transform3D
@export var hazard_ids: PackedStringArray
@export var plate_ids: PackedStringArray
@export var exit_id: String = ""
@export var onboarding_cues: PackedStringArray
@export var solution_record: String = ""

func is_progression_room() -> bool:
	return room_id in ["room_01", "room_02", "room_03", "room_04", "room_05", "room_06"]

func is_authored_room() -> bool:
	return is_progression_room() and scene != null and scene.resource_path == "res://scenes/rooms/%s.tscn" % room_id and not title.is_empty() and not teaching_goal.is_empty() and camera_size > 0 and camera_transform.origin.y > 0 and playable_bounds.size.x > 0 and playable_bounds.size.z > 0 and playable_bounds.has_point(spawn.origin) and not exit_id.is_empty() and not onboarding_cues.is_empty() and not solution_record.is_empty()

func matches_room(room: RoomController) -> bool:
	var floor_shape: BoxShape3D = room.get_node("Floor/Shape").shape
	if not is_equal_approx(floor_shape.size.x, playable_bounds.size.x) or not is_equal_approx(floor_shape.size.z, playable_bounds.size.z):
		return false
	if not room.get_node("Spawn").transform.is_equal_approx(spawn):
		return false
	var camera: Camera3D = room.get_node("Camera")
	if camera.projection != Camera3D.PROJECTION_ORTHOGONAL or not is_equal_approx(camera.size, camera_size) or not camera.transform.is_equal_approx(camera_transform):
		return false
	var actual_hazards: Array[String] = []
	for child in room.get_children():
		if child is SpikeBed or child is Buzzsaw or child is FallingAnvil:
			actual_hazards.append(child.hazard_id)
		if child is SpikeBed and child.bed_size.x > 0:
			for path in ["Bed/Shape", "Lethal/Shape"]:
				var shape: BoxShape3D = child.get_node(path).shape
				if not is_equal_approx(shape.size.x, child.bed_size.x) or not is_equal_approx(shape.size.z, child.bed_size.y):
					return false
	var actual_plates: Array[String] = []
	for plate in room.plates:
		actual_plates.append(plate.plate_id)
	if actual_hazards.size() != hazard_ids.size() or actual_plates.size() != plate_ids.size() or room.doors.size() != 1:
		return false
	for identity in hazard_ids:
		if actual_hazards.count(identity) != 1:
			return false
	for identity in plate_ids:
		if actual_plates.count(identity) != 1:
			return false
	var door := room.doors[0]
	return door.exit_id == exit_id and (door.linked_plate_id.is_empty() or door.linked_plate_id in plate_ids)
