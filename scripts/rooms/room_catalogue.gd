class_name RoomCatalogue
extends Resource
@export var rooms: Array[RoomDefinition] = []
func find(room_id: String) -> RoomDefinition:
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
