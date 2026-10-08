extends RefCounted
## Animation integrity only. This cannot establish actual-camera visual suitability.

func run(h: SceneTree) -> void:
	var fixture: RoomController = load("res://tests/scenes/greybox_room.tscn").instantiate()
	h.root.add_child(fixture)
	await h.frames(30)
	var visual: CharacterVisual = fixture.player.get_node("Visual")
	h.check(visual._animation != null and not visual._last_clip.is_empty(), "US1.visual.imported_idle_resolves")
	visual._play("Move")
	h.check(visual._animation.get_animation(visual._last_clip).loop_mode == Animation.LOOP_LINEAR, "US1.visual.move_loops")
	var shape: CapsuleShape3D = fixture.player.get_node("Shape").shape
	var height := shape.height
	visual.scale = Vector3(2, 0.2, 2)
	h.check(shape.height == height and fixture.player.get_node("Shape").position.y == height * 0.5, "US1.visual.squash_does_not_resize_collision")
	var corpse: Corpse = load("res://scenes/corpses/corpse.tscn").instantiate()
	corpse.position = Vector3(4, 0.23, 3)
	fixture.add_child(corpse)
	await h.frames(3)
	var corpse_visual: CharacterVisual = corpse.get_node("Visual")
	h.check(corpse_visual._animation != null and not corpse_visual._last_clip.is_empty() and not corpse_visual._animation.is_playing(), "US1.visual.collapsed_pose_sampled_and_paused")
	h.check(corpse.lock_rotation and not corpse.freeze and corpse.get_node("Shape").shape.size == corpse.tuning.corpse_size, "US1.visual.independent_translating_box")
	fixture.retire()
	fixture.queue_free()
	await h.frames(2)
