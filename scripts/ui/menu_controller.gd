class_name MenuController
extends Control
var current_screen: String = ""
var game: GameSession
var _views: Dictionary = {}
var _last_focus: Dictionary = {}
var _return_screen: String = "title"
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for screen in ["title", "pause", "settings", "completion"]:
		var view: Control = load("res://scenes/ui/%s.tscn" % screen).instantiate()
		add_child(view)
		_views[screen] = view
		view.hide()
		var controls: Array[Control] = []
		for child in view.get_node("Panel/Items").get_children():
			if child is Button or child is HSlider:
				controls.append(child)
		for index in range(controls.size()):
			var control := controls[index]
			control.focus_neighbor_top = control.get_path_to(controls[(index - 1 + controls.size()) % controls.size()])
			control.focus_neighbor_bottom = control.get_path_to(controls[(index + 1) % controls.size()])
			control.focus_previous = control.focus_neighbor_top
			control.focus_next = control.focus_neighbor_bottom
			var focus_style := StyleBoxFlat.new()
			focus_style.bg_color = Color(0.12, 0.16, 0.2)
			focus_style.border_color = Color(1, 0.85, 0.1)
			focus_style.set_border_width_all(4)
			control.add_theme_stylebox_override("focus", focus_style)
	_connect("title", "Start", game.continue_game)
	_connect("title", "Settings", func(): open_settings("title"))
	_connect("title", "Quit", game.quit_game)
	_connect("pause", "Resume", game.resume_game)
	_connect("pause", "Restart", func(): game.request_restart(game.active_room.state.epoch))
	_connect("pause", "Settings", func(): open_settings("pause"))
	_connect("pause", "Title", game.quit_to_title)
	_connect("completion", "Replay", func(): game.request_activation("room_01"))
	_connect("completion", "Settings", func(): open_settings("completion"))
	_connect("completion", "Title", game.quit_to_title)
	_connect("settings", "Back", close_settings)
	for channel in ["Music", "SFX"]:
		var slider: HSlider = _views.settings.get_node("Panel/Items/" + channel)
		slider.value_changed.connect(func(value: float): _change_volume(channel, value))
func _connect(screen: String, button: String, action: Callable) -> void:
	_views[screen].get_node("Panel/Items/" + button).pressed.connect(action)
func show_screen(screen: String, restore: bool = false) -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus != null and not current_screen.is_empty():
		_last_focus[current_screen] = focus.name
	for view in _views.values():
		view.hide()
	current_screen = screen
	visible = not screen.is_empty()
	if screen.is_empty():
		return
	_views[screen].show()
	var first: String = {"title": "Start", "pause": "Resume", "settings": "Music", "completion": "Replay"}[screen]
	var focus_name: String = _last_focus.get(screen, first) if restore else first
	_views[screen].get_node("Panel/Items/" + focus_name).grab_focus.call_deferred()
func open_settings(return_screen: String) -> void:
	_return_screen = return_screen
	for channel in ["Music", "SFX"]:
		var slider: HSlider = _views.settings.get_node("Panel/Items/" + channel)
		slider.set_value_no_signal(game.settings.music_volume if channel == "Music" else game.settings.sfx_volume)
		_update_value(channel, slider.value)
	show_screen("settings")
func close_settings() -> void:
	game.persist_settings()
	show_screen(_return_screen, true)
func _change_volume(channel: String, value: float) -> void:
	game.settings["music_volume" if channel == "Music" else "sfx_volume"] = value
	game.audio.apply(game.settings.music_volume, game.settings.sfx_volume)
	if channel == "SFX":
		game.audio.preview_sfx()
	_update_value(channel, value)
func _update_value(channel: String, value: float) -> void:
	_views.settings.get_node("Panel/Items/" + channel + "Value").text = "%s: %s" % [channel, "MUTED" if value == 0 else "%d%%" % roundi(value * 100)]
