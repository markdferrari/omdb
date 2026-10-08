extends RefCounted
func run(h: SceneTree) -> void:
	for trial in range(10):
		var registry := CorpseRegistry.new(trial + 1)
		var first: String = registry.create(Transform3D.IDENTITY).body_id
		var second: String = registry.create(Transform3D.IDENTITY).body_id
		var saw := Buzzsaw.new()
		saw.apply_candidates([first, first, second, "missing"], registry)
		h.check(saw.jammed() and saw.contributors.size() == 2, "EC14.unique_saw_contributors.%d" % trial)
		registry.set_mode(first, CorpseRegistry.Mode.HELD)
		saw.apply_candidates([first, second], registry)
		h.check(saw.jammed() and saw.contributors.size() == 1, "EC14.remaining_jam")
		registry.remove(second)
		saw.apply_candidates([first, second], registry)
		h.check(not saw.jammed(), "EC14.final_removal_reactivates")
		saw.free()
