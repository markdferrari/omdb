# Quickstart and Validation: Six-Room Puzzle Slice

**Date**: 2026-10-08 | **Plan**: [plan.md](plan.md)

This guide defines how to run and validate the implementation once its project, scenes,
scripts, and export presets exist. Those files are planned, not present at planning time.
Do not interpret the commands or expected outcomes here as completed game tests.

## 1. Prerequisites and first import

Run commands from the repository root. Use Godot **4.7.2** standard build and Python 3.12
for the development check wrapper. Runtime players need only the exported game. Obtain
matching 4.7.2 export templates before export; the inspected local template directory is
empty. Interactive checks require graphics access and a physical controller.

During implementation, copy the selected cow assets and retained sources as specified in
[research R5](research.md#r5-character-candidate-and-asset-workflow), verify provenance,
and create `project.godot`, the planned scenes/scripts, and export presets. Then run:

```sh
godot --version
godot --headless --path . --import
godot --editor --path .
```

**Expected:** Version 4.7.2, clean imports without parse/resource errors, correct main scene,
Compatibility renderer, Jolt selected, and no dependence on Blender during routine imports.
Inspect the selected visual at the actual camera before claiming the asset gate passes.

## 2. Isolated automated checks

Create a disposable root so tests cannot read or overwrite player saves:

```sh
OMDB_CHECK_ROOT="$(mktemp -d /tmp/omdb-checks.XXXXXX)"
python3 scripts/checks/run_checks.py --godot godot --suite all --save-root "$OMDB_CHECK_ROOT"
```

For targeted reruns after a change, replace `all` with `state`, `physics`, or `recovery`.
The wrapper must perform/import-check the project, invoke the SceneTree runner, impose a
bounded process timeout, reject script/import errors, and require a final nonempty passing
`OMDB_TEST_RESULT` summary. It returns a nonzero status on any failure. A bare engine
exit code of zero is not sufficient evidence.

To diagnose the underlying runner directly, after a clean import:

```sh
godot --headless --path . --script res://tests/run_tests.gd -- --suite state --save-root "$OMDB_CHECK_ROOT/state"
godot --headless --path . --script res://tests/run_tests.gd -- --suite physics --save-root "$OMDB_CHECK_ROOT/physics"
godot --headless --path . --script res://tests/run_tests.gd -- --suite recovery --save-root "$OMDB_CHECK_ROOT/recovery"
```

`--suite` and `--save-root` after `--` are project-defined user arguments, not Godot options.
There is no assumed native `--user-data-dir` flag. Inject the root before constructing or
loading SaveStore. The override isolates game progress/settings, not engine logs/cache.
Tests must refuse the normal player-save root and never recursively clean a supplied root.

| Suite | Required cases | Expected evidence |
| --- | --- | --- |
| State | First/repeated lethal contacts; creation-order cap; pickup does not reorder; held-body eligibility; eviction in every role; multiple jam contacts; direct plate units; epoch and exit latches | VR-001 invariants, ten repetitions of each applicable scenario, no duplicate or stale state. |
| Physics | Real shapes; valid surface categories; every rejection category; stable stacks/bridges; removal wakes supports; spike clearance; saw traversal; warned anvil; safe door closure | Ten independently rebuilt trials; body cap always respected; no hidden support or hazard mismatch. |
| Recovery | Restart during death/carry/exit; fresh scene comparison; all six saved room IDs; missing/corrupt/unsupported/out-of-range saves; partial settings; checked write failures | VR-005 ten repetitions each; one live subject, zero bodies/carry, initial machinery, valid settings retained. |

**Expected:** All requested scenarios appear in the summary and pass. Record actual
build, scenario IDs, repetitions, outcomes and defects in `validation.md`. If a suite or
fixture is missing, mark the check unverified rather than substituting a success stub.

## 3. Playable greybox and character proof

Use a separate disposable root for manual validation:

```sh
OMDB_GREYBOX_ROOT="$(mktemp -d /tmp/omdb-greybox.XXXXXX)"
godot --path . --scene res://tests/scenes/greybox_validation.tscn -- --save-root "$OMDB_GREYBOX_ROOT"
```

The greybox scene must compose the actual room components with an isolated application
context. It provides a safe entrance, spike crossing, floor/body placement surfaces, a
single/multi-unit plate, a linked door, and a saw jam route. The later physics fixture
adds an anvil and door-closure cases. No extra progression room is saved for the fixture.

Perform these checks with keyboard and controller separately, using the bindings in
[player-interface.md](contracts/player-interface.md):

1. Move in all four screen directions and diagonally. Jump onto broad surfaces; confirm
   shadow, height, landing cues, no camera movement, and complete room framing.
2. Die to exposed spikes, then cross a body-supported route. Verify one corpse and one
   replacement per death. Time twenty deaths, including overlaps and carrying, each at
   most two seconds from lethal contact to regained control during active play.
3. Pick up one body; show that it no longer supports, presses, or jams. Place it on floor,
   another body, and a spike bed. Run ten valid attempts on each allowed surface and ten
   invalid attempts for each rejection category. The ghost and outcome must agree.
4. Build and traverse each intended bridge/stack from scratch ten consecutive times.
   Remove a supporting body and verify physical settling without invisible support.
5. Activate one-unit and multi-unit plates with the live player and released bodies.
   A body resting only on another body must not add a plate unit. Excess valid weight
   must keep the door open after one contributor leaves.
6. Jam a saw with a released body; wait to prove there is no timeout. Retrieve/remove it
   from a safe position; verify reactivation. Repeat with two bodies so one remaining
   contributor keeps the jam. A jammed designated route must be traversable.
7. Create six bodies. Confirm the marker predicts removal and count stays five. Repeat
   with the oldest held, pressing a plate, supporting a stack, and jamming a saw. Include
   dying while carrying both the oldest and a newer body.
8. Inspect cow movement, jump, carry, hurt/death and collapsed pose with five bodies visible.
   Record missing clips/pose work, materials, scale, support-silhouette fit, and glitches.
   Initial metadata or portraits do not pass this check.
9. Repeat framing at 1920×1080, 1280×800, and 1024×768; all necessary puzzle and HUD cues
   remain visible using the chosen aspect policy. Mute audio and recheck hazard warnings.

**Stage 1 passes only when VR-003/VR-004 and the applicable state/placement/support checks
have actual passing results.** Record changed tuning values and rerun affected checks
before full room production. An unavailable display/controller leaves those checks unverified.

## 4. Recovery, menus, and room solutions

After stage 2, run the main project with an isolated root and follow US4–US6:

```sh
OMDB_FLOW_ROOT="$(mktemp -d /tmp/omdb-flow.XXXXXX)"
godot --path . -- --save-root "$OMDB_FLOW_ROOT"
```

- Restart while holding the oldest body, while a saw is jammed, during death feedback,
  and at an exit transition. Confirm fresh-state equivalence and no later stale callbacks.
- Adjust and independently mute both audio categories. Restart, quit, and reopen with
  the same root; settings survive while the room starts with no corpse arrangement.
- Advance to the next room, reopen, and verify that new room is current. Complete room 6,
  reopen to a fresh room 6, then Replay and verify room 1 is saved with settings preserved.
- Navigate Title, Pause, Settings, Completion and Quit using each input method alone.
  Confirm focus returns correctly and menu events do not also trigger gameplay actions.
- Inspect every anvil warning/drop cycle and safe door displacement. Closing a door cannot
  become an unlisted lethal hazard or let the player pass with insufficient plate weight.

For each authored room, record the actual solution actions, body creation order, placement
positions, peak count, and timing. Complete it from a fresh state ten consecutive times.
Room 4's intended walkthrough must demonstrate six total creations while never retaining
more than five. Test boundary walk-arounds and the measured maximum jump including grace
periods; do not merely compare gaps against the nominal ballistic range.

## 5. Performance and first-time playtests

Use a release build in a working graphics session. Follow [research R8](research.md#r8-initial-tuning-and-measurement-decisions):
30 s warmup, then 120 s representative play at 1920×1080 with one player, five corpses,
hazards and normal effects. Record actual hardware/OS, renderer, engine/build, resolution,
settings, frame-time distribution, physics time, draw calls, visible triangles, and observed
stutters. Check 95th-percentile frame time ≤16.7 ms and physics ≤4 ms against the selected
baseline hardware. Headless timing is not a rendering benchmark.

Conduct at least five first-time sessions after the six-room flow exists. Record active
completion time including deaths/restarts, non-completions, help requests, misunderstood
rules, jump judgments, and placement frustration. Measure cue recognition against SC-008
(at least 80%). Compare median completion time with the 20–30 minute target; review pacing
and repeat playtests after changes when outside it. Do not discard failed or assisted runs.

## 6. Native exports and release matrix

Install matching 4.7.2 templates and define presets named exactly `Windows Desktop` and
`macOS` in `export_presets.cfg`. The Windows preset targets x86_64; macOS is Universal 2.
Create output directories and export:

```sh
mkdir -p builds/windows builds/macos
godot --headless --path . --export-release "Windows Desktop" builds/windows/over-my-dead-body.exe
godot --headless --path . --export-release "macOS" builds/macos/over-my-dead-body.zip
```

**Expected:** Complete runnable artifacts with all required resources. Package the Windows
executable with its PCK if the preset does not embed it. A successful export on Linux
is not evidence of native launch or full-flow behavior.

| Native system | Input | Mandatory run | Planning-time result |
| --- | --- | --- | --- |
| Windows x86_64 | Keyboard only | Six rooms, menus/settings, restart, reopen, completion, replay | Unverified |
| Windows x86_64 | Controller only | Same complete flow without mouse/keyboard assistance | Unverified |
| macOS Universal 2 | Keyboard only | Same flow; record hardware architecture | Unverified |
| macOS Universal 2 | Controller only | Same complete flow; record hardware architecture | Unverified |

Run at least a native launch/smoke test on each architecture advertised by the macOS
Universal package; the full-flow runs must identify which hardware they exercised.
Test an actual downloaded macOS package and record signing/notarization and launch behavior;
credentials are not assumed. Review any distribution limitation before the release gate.
Prepare an Itch.io listing with both platforms and no required purchase price.

## 7. Evidence and completion

Implementation creates `specs/001-six-room-slice/validation.md`. For each check, record:
requirement/scenario IDs, setup/build/hardware/input, starting room/state, actions,
expected result, actual result, trial count/metrics, pass/fail/unverified, and defect links.
Keep room solution steps and first-time findings with that evidence.

The slice is release-ready only after the spec's required checks pass and acceptance
violations are corrected. The quality checklist for the specification and the constitution
checks in the plan establish document readiness; they do not replace game validation.
