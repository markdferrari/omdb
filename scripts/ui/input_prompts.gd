class_name InputPrompts
extends Node
signal method_changed(method: String)
signal pause_requested
var method: String = "keyboard"
var active_device: int = -1
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.joy_connection_changed.connect(connection_changed)
func _input(event: InputEvent) -> void:
	observe(event)

func observe(event: InputEvent) -> void:
	var next := method
	if event is InputEventKey and event.pressed and not event.echo:
		next = "keyboard"
	elif (event is InputEventJoypadButton and event.pressed) or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.2):
		next = "controller"
		active_device = event.device
	if next != method:
		method = next
		method_changed.emit(method)
func connection_changed(device: int, connected: bool) -> void:
	if not connected and method == "controller" and active_device == device:
		pause_requested.emit()
	elif connected and method == "controller":
		method_changed.emit(method)
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause_requested.emit()
