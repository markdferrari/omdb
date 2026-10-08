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
