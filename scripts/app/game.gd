class_name GameSession
extends Node
## Persistent session; only successfully initialized candidates commit progress.
enum Mode { MENU, PLAYING, PAUSED, SWITCHING, COMPLETE, EXITING }
var mode: Mode = Mode.MENU
var menu: MenuController
var audio: AudioController
var prompts: InputPrompts
signal notification(message: String)
signal room_activated(room_id: String, epoch: int)
signal slice_completed
@export var catalogue: RoomCatalogue
@export var auto_start: bool = true
@onready var room_host: Node3D = $RoomHost
var room_epoch: int = 0
var active_room: RoomController
var current_room_id: String = ""
var store: SaveStore
var settings: Dictionary = {}
var last_save_error: Error = OK
var completed: bool = false
var _transition_serial: int = 0
var _notice_serial: int = 0
var _notice: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	room_host.process_mode = Node.PROCESS_MODE_PAUSABLE
	var args := OS.get_cmdline_user_args()
	var index := args.find("--save-root")
	if index != -1 and (index + 1 >= args.size() or SavePaths.inject_test_root(args[index + 1]) != OK):
		get_tree().quit(2)
		return
	if store == null:
		store = SaveStore.new()
	settings = store.read_settings()
	audio = AudioController.new()
	$Audio.add_child(audio)
	audio.apply(settings.music_volume, settings.sfx_volume)
	prompts = InputPrompts.new()
	add_child(prompts)
	prompts.pause_requested.connect(pause_game)
	prompts.method_changed.connect(func(_method: String):
		if menu != null and mode in [Mode.MENU, Mode.PAUSED, Mode.COMPLETE]:
			menu.show_screen(menu.current_screen, true))
	menu = MenuController.new()
	menu.game = self
	$UI.add_child(menu)
	_notice = Label.new()
	_notice.position = Vector2(40, 240)
	$UI.add_child(_notice)
	notification.connect(_show_notice)
	if auto_start and catalogue != null:
		var progress := store.read_progress()
		# Loading a fallback does not eagerly overwrite a malformed/missing document.
		activate_room(catalogue.find(progress.room_id), false)
	else:
		_set_mode(Mode.MENU)
		menu.show_screen("title")
	if catalogue == null:
		_notice.text = "Over My Dead Body — implementation in progress\nRun the isolated greybox from quickstart.md."

func activate_room(definition: RoomDefinition, persist: bool = true) -> Error:
	if definition == null or not definition.is_progression_room() or definition.scene == null:
		return ERR_INVALID_DATA
	var instance := definition.scene.instantiate()
	if not instance is RoomController:
		instance.free()
		return ERR_INVALID_DATA
	var candidate := instance as RoomController
	if candidate.get_node_or_null("Spawn") == null or not candidate.spawn_player:
		candidate.free()
		return ERR_INVALID_DATA
	room_epoch += 1
	candidate.initialize(room_epoch, definition)
	candidate.presentation_cue.connect(audio.play_cue)
	# Initialize off the live room's physics footprint before the one-shot commit.
	var authored_position := candidate.position
	candidate.position += Vector3(1000, 0, 1000)
	room_host.add_child(candidate)
	if not is_instance_valid(candidate.player) or candidate.state.phase != RoomState.Phase.ACTIVE:
		room_host.remove_child(candidate)
		candidate.queue_free()
		return ERR_INVALID_DATA
	if active_room != null:
		active_room.retire()
		room_host.remove_child(active_room)
		active_room.queue_free()
	active_room = candidate
	candidate.position = authored_position
	candidate.reset_physics_interpolation()
	current_room_id = definition.room_id
	completed = false
	candidate.restart_requested.connect(request_restart)
	candidate.room_completed.connect(_on_room_completed)
	if persist:
		last_save_error = store.write_progress(current_room_id)
		if last_save_error != OK:
			notification.emit("Progress could not be saved. The current room remains playable.")
	_set_mode(Mode.PLAYING)
	menu.show_screen("")
	room_activated.emit(current_room_id, room_epoch)
	return OK

func request_activation(room_id: String) -> String:
	if catalogue == null or catalogue.find(room_id) == null:
		return "INVALID_STATE"
	_transition_serial += 1
	_set_mode(Mode.SWITCHING)
	_finish_activation.call_deferred(_transition_serial, room_id)
	return "ACCEPTED"

func _finish_activation(ticket: int, room_id: String) -> void:
	if ticket != _transition_serial:
		return
	if activate_room(catalogue.find(room_id)) != OK:
		_set_mode(Mode.MENU)
		menu.show_screen("title")
		notification.emit("Room could not be opened. Previous progress was kept.")

func request_restart(epoch: int) -> String:
	if active_room == null or active_room.state.epoch != epoch:
		return "IGNORED_STALE"
	_transition_serial += 1
	active_room.retire()
	_set_mode(Mode.SWITCHING)
	_finish_restart.call_deferred(_transition_serial, current_room_id)
	return "ACCEPTED"

func _finish_restart(ticket: int, room_id: String) -> void:
	if ticket == _transition_serial and catalogue != null:
		# No progress/settings write on ordinary restart.
		if activate_room(catalogue.find(room_id), false) == OK:
			notification.emit("Room restarted.")

func _on_room_completed(epoch: int, room_id: String) -> void:
	if active_room == null or active_room.state.epoch != epoch or current_room_id != room_id or not active_room.state.exit_consumed:
		return
	var next_id := active_room.definition.next_room_id
	if next_id.is_empty():
		active_room.retire()
		completed = true
		_set_mode(Mode.COMPLETE)
		menu.show_screen("completion")
		slice_completed.emit()
	else:
		request_activation(next_id)

func _set_mode(value: Mode) -> void:
	mode = value
	get_tree().paused = value != Mode.PLAYING

func continue_game() -> void:
	var room_id: String = current_room_id if not current_room_id.is_empty() else store.read_progress().room_id
	if request_activation(room_id) != "ACCEPTED":
		notification.emit("No playable room catalogue is configured. Use the validation scene.")

func pause_game() -> void:
	if mode == Mode.PLAYING:
		_set_mode(Mode.PAUSED)
		menu.show_screen("pause")

func resume_game() -> void:
	if mode == Mode.PAUSED:
		_set_mode(Mode.PLAYING)
		menu.show_screen("")

func persist_settings() -> Error:
	var result := store.write_settings(settings.music_volume, settings.sfx_volume)
	if result != OK:
		notification.emit("Audio settings could not be saved. Current volumes remain active.")
	return result

func quit_to_title() -> void:
	persist_settings()
	if last_save_error != OK and not current_room_id.is_empty():
		last_save_error = store.write_progress(current_room_id)
	_transition_serial += 1
	if active_room != null:
		active_room.retire()
		room_host.remove_child(active_room)
		active_room.queue_free()
		active_room = null
	_set_mode(Mode.MENU)
	menu.show_screen("title")

func quit_game() -> void:
	persist_settings()
	if last_save_error != OK and not current_room_id.is_empty():
		last_save_error = store.write_progress(current_room_id)
	_set_mode(Mode.EXITING)
	get_tree().quit()

func _input(event: InputEvent) -> void:
	prompts.observe(event)
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if menu.current_screen == "settings":
			menu.close_settings()
		elif mode == Mode.PLAYING:
			pause_game()
		elif mode == Mode.PAUSED:
			resume_game()

func _exit_tree() -> void:
	get_tree().paused = false

func _show_notice(message: String) -> void:
	_notice_serial += 1
	_notice.text = message
	get_tree().create_timer(4.0, true).timeout.connect(_clear_notice.bind(_notice_serial))

func _clear_notice(ticket: int) -> void:
	if ticket == _notice_serial:
		_notice.text = ""
