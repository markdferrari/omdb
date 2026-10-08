class_name ValidationContext
extends Node3D
## Isolated launch context, never a seventh saved room.
@export var room_scene: PackedScene = preload("res://tests/scenes/physics_fixture.tscn")
var room: RoomController
var epoch: int = 0
var audio: AudioController

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var index := args.find("--save-root")
	if index == -1 or index + 1 >= args.size() or SavePaths.inject_test_root(args[index + 1]) != OK:
		push_error("Validation requires --save-root with an absolute temporary directory")
		get_tree().quit(2)
		return
	audio = AudioController.new()
	add_child(audio)
	restart()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_room") and not event.is_echo():
		get_viewport().set_input_as_handled()
		restart.call_deferred()

func restart() -> void:
	epoch += 1
	if room != null:
		room.retire()
		remove_child(room)
		room.queue_free()
	room = room_scene.instantiate()
	room.initialize(epoch, RoomDefinition.new())
	room.presentation_cue.connect(audio.play_cue)
	add_child(room)
	room.restart_requested.connect(func(command_epoch: int):
		if room != null and room.state.epoch == command_epoch:
			restart.call_deferred())
