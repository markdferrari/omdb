extends RefCounted
## Physical keyboard events exercise the serialized InputMap, not an action override.
const MOVEMENT := ["move_left", "move_right", "move_up", "move_down"]
const DIRECTIONS := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const ARROWS := [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]
const LETTERS := [KEY_A, KEY_D, KEY_W, KEY_S]
const UI := ["ui_left", "ui_right", "ui_up", "ui_down"]

func key_event(key: Key, pressed: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	return event

func send_key(key: Key, pressed: bool) -> void:
	Input.parse_input_event(key_event(key, pressed))
	Input.flush_buffered_events()

func vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func run(h: SceneTree) -> void:
	for trial in range(10):
		for index in range(4):
			for key in [ARROWS[index], LETTERS[index]]:
				var event := key_event(key, true)
				var matches: Array[String] = []
				for action in MOVEMENT:
					if event.is_action_pressed(action):
						matches.append(action)
				h.check(matches == [MOVEMENT[index]], "FR003.keyboard.exclusive_binding.%d.%d.%d" % [trial, index, key])
				send_key(key, true)
				h.check(vector().is_equal_approx(DIRECTIONS[index]), "FR003.keyboard.vector.%d.%d.%d" % [trial, index, key])
				send_key(key, false)
				h.check(vector() == Vector2.ZERO, "FR003.keyboard.release")
			var ui_matches: Array[String] = []
			for action in UI:
				if key_event(ARROWS[index], true).is_action_pressed(action):
					ui_matches.append(action)
			h.check(ui_matches == [UI[index]], "FR031.keyboard.ui_direction.%d.%d" % [trial, index])
		for keys in [ARROWS, LETTERS]:
			send_key(keys[0], true)
			send_key(keys[2], true)
			h.check(vector().is_equal_approx(Vector2(-1, -1).normalized()), "FR003.keyboard.diagonal")
			send_key(keys[0], false)
			send_key(keys[2], false)
			send_key(keys[0], true)
			send_key(keys[1], true)
			h.check(vector() == Vector2.ZERO, "FR003.keyboard.opposed_cancel")
			send_key(keys[0], false)
			h.check(vector().is_equal_approx(Vector2.RIGHT), "FR003.keyboard.opposed_release")
			send_key(keys[1], false)
