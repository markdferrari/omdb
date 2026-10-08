extends RefCounted

func run(h: SceneTree) -> void:
	for trial in range(10):
		var registry := CorpseRegistry.new(100 + trial)
		var prior: Array[String] = []
		for index in range(12):
			var result := registry.create(Transform3D(Basis.IDENTITY, Vector3(index, 1, 0)))
			h.check(result.result == "ACCEPTED" and not result.body_id.is_empty(), "US1.registry.creation.%d.%d" % [trial, index])
			if result.result != "ACCEPTED":
				break
			h.check(not result.body_id in prior, "US1.registry.unique_identity")
			prior.append(result.body_id)
			var expected_count := mini(index + 1, 5)
			h.check(registry.count() == expected_count and registry.ordered_ids() == prior.slice(maxi(0, index - 4)), "US1.registry.fifo_cap")
			h.check(registry.oldest_id() == prior[maxi(0, index - 4)], "US1.registry.oldest")
			h.check(result.evicted_id == ("" if index < 5 else prior[index - 5]), "US1.registry.eviction_result")
			var record := registry.record_for(result.body_id)
			h.check(record.creation_index == index + 1 and record.death_origin.origin.x == index, "US1.registry.immutable_age_origin")
			record.creation_index = -1
			h.check(registry.record_for(result.body_id).creation_index == index + 1, "US1.registry.copy_isolation")
