extends SceneTree
## Project-owned runner. Missing cases and failed assertions cannot produce success.
const SUITES := {
	"state": ["res://tests/state/test_foundation.gd", "res://tests/state/test_registry.gd", "res://tests/state/test_lifecycle.gd", "res://tests/state/test_movement.gd"],
	"physics": ["res://tests/physics/test_foundation.gd", "res://tests/physics/test_support.gd"],
	"recovery": ["res://tests/recovery/test_foundation.gd"],
}
var passed: int = 0
var failed: int = 0
var suite_cases: Dictionary = {}
var current_suite: String = ""
var _finished: bool = false
var _deadline_ms: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, case_id: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
	suite_cases[current_suite] = int(suite_cases.get(current_suite, 0)) + 1
	print("OMDB_CASE ", current_suite, " ", case_id, " ", "PASS" if condition else "FAIL")

func frames(count: int) -> void:
	for _index in range(count):
		await physics_frame

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var parsed: Dictionary = {}
	var index := 0
	while index < args.size():
		if args[index] not in ["--suite", "--save-root"] or index + 1 >= args.size() or parsed.has(args[index]):
			_fail_arguments()
			return
		parsed[args[index]] = args[index + 1]
		index += 2
	var selected: String = parsed.get("--suite", "")
	if selected not in ["state", "physics", "recovery", "all"] or SavePaths.inject_test_root(parsed.get("--save-root", "")) != OK:
		_fail_arguments()
		return
	# Wall-time watchdog remains bounded even with fixed-step fast headless simulation.
	# Six authored ten-trial walkthroughs and real-process reopen checks outgrew
	# the original 45-second fixture budget. Keep a bounded whole-run deadline.
	_deadline_ms = Time.get_ticks_msec() + 180000
	var requested: Array = SUITES.keys() if selected == "all" else [selected]
	for suite in requested:
		current_suite = suite
		suite_cases[suite] = 0
		if SUITES[suite].is_empty():
			check(false, "missing_suite")
		var files: Array = SUITES[suite].duplicate()
		for leaf in DirAccess.get_files_at("res://tests/" + suite):
			if leaf.begins_with("test_") and leaf.ends_with(".gd"):
				var path: String = "res://tests/" + suite + "/" + leaf
				if path not in files:
					files.append(path)
		files.sort()
		for path in files:
			if not ResourceLoader.exists(path):
				check(false, "missing_case_file")
				continue
			var script: Script = load(path)
			if script == null or not script.can_instantiate():
				check(false, "invalid_case_script")
				continue
			var test = script.new()
			if not test.has_method("run"):
				check(false, "missing_run_method")
				continue
			var before := passed + failed
			await test.run(self)
			if passed + failed == before:
				check(false, "no_assertions")
		if int(suite_cases[suite]) == 0:
			check(false, "empty_suite")
	_finish()

func _fail_arguments() -> void:
	failed += 1
	printerr("Usage: -- --suite state|physics|recovery|all --save-root ABSOLUTE_TEMP_DIRECTORY")
	_finish()

func _process(_delta: float) -> bool:
	if _deadline_ms > 0 and Time.get_ticks_msec() >= _deadline_ms:
		_watchdog()
	return false

func _watchdog() -> void:
	if not _finished:
		failed += 1
		printerr("OMDB watchdog timeout")
		_finish()

func _finish() -> void:
	if _finished:
		return
	_finished = true
	print("OMDB_TEST_RESULT ", JSON.stringify({"passed": passed, "failed": failed, "suites": suite_cases}))
	quit(0 if failed == 0 and passed > 0 else 1)
