extends RefCounted

func run(h: SceneTree) -> void:
	var camera_basis := Basis.from_euler(Vector3(deg_to_rad(-35.3), deg_to_rad(45), 0))
	var right := Vector3(sqrt(0.5), 0, -sqrt(0.5))
	var forward := Vector3(-sqrt(0.5), 0, -sqrt(0.5))
	for trial in range(10):
		for pair in [[Vector2.RIGHT, right], [Vector2.LEFT, -right], [Vector2.UP, forward], [Vector2.DOWN, -forward]]:
			h.check(PlayerController.ground_direction(pair[0], camera_basis).distance_to(pair[1]) < 0.0001, "US1.screen_direction.%d" % trial)
		h.check(is_equal_approx(PlayerController.ground_direction(Vector2(1, 1).normalized(), camera_basis).length(), 1), "US1.normalized_diagonal")
		h.check(is_equal_approx(PlayerController.ground_direction(Vector2(0.25, -0.25), camera_basis).length(), sqrt(0.125)), "US1.analog_magnitude")
		var actor: PlayerController = load("res://scenes/player/player.tscn").instantiate()
		var event := InputEventKey.new()
		event.physical_keycode = KEY_SPACE
		event.pressed = true
		event.echo = true
		actor.queue_jump(event)
		h.check(actor._jump_remaining == 0, "US1.jump_echo_rejected")
		event.echo = false
		actor.queue_jump(event)
		h.check(is_equal_approx(actor._jump_remaining, actor.tuning.jump_buffer), "US1.jump_buffer_one_press")
		actor.free()
