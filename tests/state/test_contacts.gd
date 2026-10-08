extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		var plate := PressurePlate.new()
		plate.required_weight = 2
		plate.apply_observations([{"id": "player", "eligible": true, "direct": true}, {"id": "body", "eligible": true, "direct": true}, {"id": "body", "eligible": true, "direct": true}, {"id": "held", "eligible": false, "direct": true}, {"id": "stack", "eligible": true, "direct": false}])
		h.check(plate.weight() == 2 and plate.active(), "US2.direct_unique_weight.%d" % trial)
		plate.apply_observations([{"id": "player", "eligible": true, "direct": true}])
		h.check(plate.weight() == 1 and not plate.active(), "US2.threshold_removal")
		plate.apply_observations([])
		h.check(plate.weight() == 0, "US2.empty_plate")
		plate.apply_observations([{"id": "one", "eligible": true, "direct": true}, {"id": "two", "eligible": true, "direct": true}, {"id": "three", "eligible": true, "direct": true}])
		h.check(plate.active() and plate.weight() == 3, "EC07.surplus_plate_weight")
		plate.apply_observations([{"id": "two", "eligible": true, "direct": true}, {"id": "three", "eligible": true, "direct": true}])
		h.check(plate.active(), "EC07.surplus_removal_stays_open")
		plate.free()
