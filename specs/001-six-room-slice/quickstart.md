# Quickstart and Validation: Six-Room Puzzle Slice

**Date**: 2026-10-08 | **Plan**: [plan.md](plan.md)

The pinned project, foundation harness, and US1 greybox now exist. Carrying, plates,
saws, recovery, menus, authored rooms, and exports remain planned. Commands and expected
outcomes for those later milestones are procedures, not completed test evidence.
See [validation.md](validation.md) for actual results.

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
   Every released body in a stable stack whose support chain reaches the plate adds one
   plate unit; a body resting beside the plate or on an ineligible/held body does not.
   Excess valid weight must keep the door open after one contributor leaves.
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
- Walk through an open door from its entry side to trigger progression. Closed doors,
  reverse crossings and corpses cannot complete a room; restarting before a queued
  crossing commits keeps the current room. The isolated greybox has no next-room
  catalogue, so it reports completion without becoming a progression room. Use the
  representative flow fixture for progression/Completion/Replay checks; its repeated
  greybox rooms remain fixtures until T071–T077 author and integrate the six rooms.
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

## Implementation checkpoint: foundation failure probes

The project, cow imports, and foundation runner now exist. The complete story suites,
playable integration, and exports described above remain incremental work; consult
`validation.md` for actual coverage.

```sh
python3 scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-foundation-checks
python3 scripts/checks/check_harness.py
```

The wrapper redirects Godot XDG data/cache/config into disposable temporary directories,
independently of the injected game save root. Restricted environments may need local
socket permission for the headless editor import. Errors are never filtered away.

`check_harness.py` makes temporary project copies, injects empty/missing suites,
assertion/no-assertion failures, parse/runtime errors, missing fixtures/summary and a
short watchdog, and requires rejection of every fault. It also exercises invalid runner
arguments, an unsafe `user://` root, and the wrapper process timeout. It restores no
working file because no working file is changed. Exit 0 means all negative probes were
rejected, not that game story acceptance has passed.

## Current interaction greybox checkpoint

Use a real graphics session for this scene:

```sh
OMDB_GREYBOX_ROOT="$(mktemp -d /tmp/omdb-greybox.XXXXXX)"
godot --path . --scene res://tests/scenes/greybox_validation.tscn -- --save-root "$OMDB_GREYBOX_ROOT"
```

Current geometry: 16 × 12 m floor, 3.6 m exposed spike strip across the entire lane,
side/rear boundaries and a solid front cutaway boundary, fixed orthographic camera,
safe hatch position (-5, 0.05, 0). The greybox contains the reused cow player/corpses, spike support/sensor, carrying and
placement preview, one/two-unit plates with linked doors, a persistent-jam saw, a warned
anvil, queue/oldest HUD, cosmetic FIFO eviction, and keyboard/controller restart.

To reproduce the scripted one-body route manually, walk from the entrance toward the
spike strip, jump toward its middle from approximately x=-2.65, and let the spikes create
a central body. On the replacement clone, repeat the jump to land on that corpse,
walk across its top, then jump to the far bank. Rebuild from a fresh restart ten times
with each input device. Check the oldest marker and support silhouette while traversing.
This is a preliminary repeatable headless route; broad landing and control feel still
need human evaluation. Walk-around/jump bypasses require actual control checks.

Automated checkpoint command:

```sh
python3 scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-systems-final
```

The wrapper compiles/loads all code/scenes/resources, discovers `test_*.gd` files with
required-case checks, and runs real Jolt physics at fixed 60 Hz. `--fixed-fps 60` lets
headless runs simulate faster than wall time; the watchdog uses monotonic wall time.
No accelerated simulation time is reported as human respawn timing or rendering performance.
Recovery now checks versioned saves, fresh scene reconstruction, stale callback rejection,
settings retention, and ten separate-process reopen trials for each allowed fixture ID.
These fixtures are not six authored progression rooms.

T023 is partially verified by automated trials. T024 requires graphics plus a physical
controller: four screen directions, jump reach including grace, shadow/landings, and
1920×1080 / 1280×800 / 1024×768 framing. Leave these tasks unchecked until actual results
are recorded. Complete this phase's playable checks before marking US1 verified.

### Arrow-key fix retest (DEV-003)

Close the existing greybox and launch it again with the same command to reload the fixed
InputMap. Check Left/Right/Up/Down and A/D/W/S separately: each must move in its corresponding
screen direction. Releasing a key must stop movement; diagonals must have consistent speed.
Repeat the corpse route and jumps. The original horizontal arrow codes were incorrect;
state and real-player-motion regressions now cover physical keyboard events. The user subsequently reported the playtest was “good”; the full four-direction, jump,
controller, and framing review remains unverified in `validation.md`. T024 stays unchecked.


### Carry, weight, jam, and anvil stations

Use **E** or the controller **West face button** to pick up the nearest reachable,
unobstructed body. Press the same button while holding to place it at the ghost.
Move to change the ghost direction. A valid ghost shows **✓ PLACE**; an invalid ghost
shows **✕ BLOCKED** and the HUD explains the reason. An invalid attempt keeps the body
held. Near a table edge, the ghost can adjust up to 0.6 m toward a fully supported
spot while preserving facing. Valid aim stays unchanged. Raised tables use a lifted
placement path. Retest straight and diagonal approaches, two bodies side by side,
and a wall between you and the table; walls must still reject placement. Check that
these adjustments feel predictable with keyboard and controller (T109).
Held bodies count toward five but provide no collision, plate weight, or saw jam.

- Floor/body/spikes: create bodies by dying on the spike strip, then use E/West near a
  body. Place on the near-bank floor, on another settled body, and on the spike bed.
  Build and traverse each arrangement ten fresh times per input method. Try blocked
  walls, another body/player, unsupported edges, and unreachable targets; rejected
  attempts must retain the same held identity and creation order.
- Plates: the near-bank stations are at (-4.4, 0, -3.5) and (-4.4, 0, 3.5), requiring
  one and two units respectively. A player counts as one unit; a corpse directly resting
  on the plate counts as one. An upper stacked corpse adds one more unit when its stable
  support chain reaches the plate.
  The linked far-bank doors at x=6.2 reflect the thresholds. Losing weight while standing
  in the doorway returns the player to the reserved entry-side retreat.
- Saw: the far-bank station is at (3.5, 0, -4.1). Place a body across its lower jam point
  from the approach side. **■ JAMMED** persists while any released contributor remains;
  **⚠ ACTIVE SAW** returns after the final contributor is held or removed. Test two
  contributors separately. The stopped rotor itself has no solid collision; the body
  remains a solid prop. An active rotor is lethal to live players.
- FIFO: create five bodies and note **NEXT TO GO**, including while holding the oldest.
  Create a sixth by hazard death. The indicated oldest disappears in a cosmetic burst,
  count stays at five, and its support/plate/saw effects end immediately. Dying while
  carrying releases the body before creating the new corpse; its age still determines
  eviction. Repeat with oldest/newer held identities and support/plate/saw roles.
- Anvil: the far-bank station is at (3.5, 0, 4.3), with an amber footprint and countdown.
  It warns for one second and repeats every three seconds. Standing in the footprint
  at impact kills the clone; existing bodies survive without destructive impulses.
- Restart: **R** or the controller **North face button** rebuilds this isolated fixture,
  including during death feedback, clearing bodies/carry and restoring original machinery.

Record setup, expected/actual result, ten repetitions per applicable category, defects,
input device, and camera resolution in `validation.md`. Check the reused cow at the
actual camera with one player and five bodies. These are verification stations rather
than six authored progression rooms. Human controller, camera, warning readability,
control feel, and native acceptance remain outstanding.


### Representative menus, recovery, and audio

```sh
OMDB_FLOW_ROOT="$(mktemp -d /tmp/omdb-flow.XXXXXX)"
godot --path . --scene res://tests/scenes/flow_validation.tscn -- --save-root "$OMDB_FLOW_ROOT"
```

Start/Continue enters the shared greybox fresh. **Escape / Menu** opens Pause; Resume
returns control, Restart rebuilds the room, Settings edits Music/SFX, and Quit to Title
preserves room/settings and discards the arrangement. Use arrows/Tab or D-pad/stick to
navigate visible focus, Enter/South to activate, and left/right to adjust sliders.
Settings initially focuses Music and restores the previous menu control on Back.
Zero explicitly mutes only that channel; SFX changes play a provisional preview.
The music melody and cartoon tone are generated previews, not final US7 sound design.
Headless/Dummy checks retain streams and bus controls but do not start inaudible playback;
normal graphics sessions play both previews. Audibility/native shutdown must be reviewed.

Create bodies/carry/jams, restart with **R / North**, then close and relaunch with the
**same** `$OMDB_FLOW_ROOT`. The room resumes fresh with one player, zero bodies/carry,
original machinery, and retained audio values. Closing/reopening with a different temp
root intentionally starts without the previous progress/settings. Do not copy these
fixture saves to the normal player directory. Both validation Game scenes require an
explicit temporary root before any read/write. `recovery_validation.tscn` enters the same
fixture immediately; `flow_validation.tscn` begins at Title.

The six valid IDs in `recovery_catalogue.tres` deliberately reuse the same greybox. They
verify lookup/recovery, not room authoring. Automated checks invoke the final-room
completion event to exercise Completion and Replay; actual live-player exit crossing
and six authored rooms remain later work gated on T044/T065. Physical controller,
window disconnect/reconnection, audio audibility, focus/readability, and full manual
recovery checks remain unverified until recorded.

```sh
python3 scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-final-flow
python3 scripts/checks/check_harness.py
```

### Representative desktop exports

Matching **standard Godot 4.7.2** templates are available from the
[official release archive](https://godotengine.org/download/archive/4.7.2-stable/).
The downloader retrieves only version/Windows release/macOS members by HTTP range,
checks the exact version and ZIP CRC, and records per-file SHA-256 in `SOURCE.json`.
This avoids downloading every platform; it does not claim a full-archive checksum.

```sh
python3 scripts/checks/download_export_templates.py --output /tmp/omdb-export-templates/4.7.2.stable
python3 scripts/checks/export_fixture.py --template-dir /tmp/omdb-export-templates/4.7.2.stable
python3 scripts/checks/check_package.py
```

Presets: Windows Desktop x86_64 with separate PCK, macOS Universal 2. Source art and
state/physics/recovery runners are excluded. The exporter temporarily selects the
representative flow scene, restores normal main-scene wiring, isolates engine XDG paths,
and validates package architectures. `builds/fixture-manifest.json` records artifact
hashes, including the separate Windows PCK; `builds/` is ignored by Git. ETC2/ASTC texture imports are enabled because Godot
requires them for Universal 2/arm64 export. The macOS package is unsigned and unnotarized.

Outputs: `builds/windows/over-my-dead-body.exe` **and its .pck**, plus
`builds/macos/over-my-dead-body.zip`. Run these on their native target with
`--save-root` set to a fresh child of the OS temporary directory. They are representative
fixtures, not release packages. Native keyboard/controller launch, signing/download
behavior, and the authored six-room acceptance matrix remain unverified.

### Reusable feedback and audio review — T084/T091

The greybox now uses a short original swing loop and separate cartoon trap/eviction
sounds. Relaunch the original isolated greybox for actual speaker/headphone checks.
Use `flow_validation.tscn` for Settings: mute Music, then SFX, then both; reopen with
that same temporary root and confirm independent volume retention. Listen for a smooth
music seam, balanced overlapping sounds, one saw-jam cue on first jamming, anvil warning
bells before each drop, one impact clang even on a lethal drop, and an eviction pop.
Critical labels/motion/warnings must remain clear with both categories muted.

At the stationary camera, inspect movement, jump, carry and death with five bodies at
16:9, 16:10 and 4:3. Verify the cow silhouette fits its solid support, the jump shadow
marks landing position, neon fragments stay local to the death/eviction, and humorous
captions do not cover the exit, ghost, plate count, saw state or anvil target. Effects
pause with gameplay, expire after 0.6 seconds of active play, and share a maximum of
24 fragments. Force repeated deaths/evictions and check readable cues under that load.
Time twenty deaths including overlapping hazards and carrying; replacement/control must
return within two seconds of active play. Restart during effects and confirm all old
fragments disappear with the retired room. Record setup, expected/actual outcomes and
any defects in `validation.md`; resource/collision tests do not establish rendered feel.

First-time six-room testing follows [playtest.md](playtest.md); its five session rows
are unrun until participants test the authored slice after the required gates.
