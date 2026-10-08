extends RefCounted
## Real actor acceleration/physics driven by keys and the loaded InputMap.
const INPUT_TEST := preload("res://tests/state/test_keyboard_input.gd")

func run(h: SceneTree) -> void:
	var input_test = INPUT_TEST.new()
	for trial in range(10):
		for keys in [INPUT_TEST.ARROWS, INPUT_TEST.LETTERS]:
			for index in range(4):
				var fixture: RoomController = load("res://tests/scenes/physics_fixture.tscn").instantiate()
				fixture.spawn_player = true
				h.root.add_child(fixture)
				await h.frames(12)
				var actor := fixture.player
				var camera := fixture.get_node("Camera") as Camera3D
				var start := camera.unproject_position(actor.global_position)
				input_test.send_key(keys[index], true)
				await h.frames(12)
				input_test.send_key(keys[index], false)
				var displacement := camera.unproject_position(actor.global_position) - start
				var expected: Vector2 = INPUT_TEST.DIRECTIONS[index]
				h.check(not actor.use_movement_override and displacement.dot(expected) > 1.0, "FR003.keyboard.projected_motion.%d.%d.%d" % [trial, index, keys[index]])
				h.check(absf(displacement.cross(expected)) < 0.1, "FR003.keyboard.projected_axis")
				await h.frames(20)
				h.check(Vector2(actor.velocity.x, actor.velocity.z).length() < 0.001, "FR003.keyboard.stop_on_release")
				fixture.retire()
				fixture.queue_free()
				await h.frames(2)
