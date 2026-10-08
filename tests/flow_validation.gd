extends GameSession
## Disposable-root fixture flow; never touches normal player saves.
func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var index := args.find("--save-root")
	if index < 0 or index + 1 >= args.size() or SavePaths.inject_test_root(args[index + 1]) != OK:
		printerr("Validation flow requires --save-root with an absolute temporary directory")
		get_tree().quit(2)
		return
	super._ready()
