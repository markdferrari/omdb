class_name RoomCatalogue
extends Resource
@export var rooms: Array[RoomDefinition] = []
@export var production: bool = false

func valid_sequence() -> bool:
	if rooms.size() != 6:
		return false
	for number in range(1, 7):
		var definition := rooms[number - 1]
		if definition == null or not definition.is_authored_room() or definition.room_id != "room_%02d" % number:
			return false
		var next_id := "room_%02d" % (number + 1) if number < 6 else ""
		if definition.next_room_id != next_id:
			return false
	return true

func find(room_id: String) -> RoomDefinition:
	if production and not valid_sequence():
		return null
	var found: RoomDefinition
	var seen: Dictionary = {}
	for definition in rooms:
		if definition == null or not definition.is_progression_room() or definition.scene == null or seen.has(definition.room_id):
			return null
		seen[definition.room_id] = true
		if definition.room_id == room_id:
			if found != null:
				return null
			found = definition
	return found
