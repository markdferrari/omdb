# Six-room slice validation evidence

Implementation began 2026-10-08. Engine: `4.7.2.stable.official.ed1daf0bf`;
Python 3.12.3; `Linux-7.0.0-31-generic-x86_64-with-glibc2.39`; CPU `AMD Ryzen 5 220 w/ Radeon 740M Graphics`; `MemTotal:       30429908 kB`. GPU and controller devices are not exposed. No usable display/GPU/controller device access in
this session. Rendered launch confirmed X11 and Wayland unavailable. Headless results do not establish visual, input-feel, or native acceptance.

## Record format

For every scenario record requirement/scenario IDs, task, code revision, engine/build,
OS/CPU/GPU/RAM/input, resolution, setup/starting state, exact actions, expected outcome,
actual result, repetitions, metrics, pass/fail/unverified, and related defect IDs.
A changed implementation invalidates affected earlier evidence until rechecked.
Procedures and commands: [quickstart.md](quickstart.md).

## Implementation checkpoints

| Check | Setup / actions | Expected | Actual | Status |
| --- | --- | --- | --- | --- |
| T001–T004 project/assets | Initialize pinned project; copy R5 files; recompute source and copy SHA-256 | Engine/renderer/layers/inputs/tuning present; byte-identical sources | Godot 4.7.2 imports cow; all three hashes match source; `SOURCE.md` records bytes and hashes; source project untouched | PASS (setup only) |
| T006–T010 foundations | `python3 scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-foundation-checks`; fresh fixture, 90 actual physics frames | Nonempty state/physics/recovery; isolated paths; solid floor support | 31 assertions passed: state 19, physics 4, recovery 8; floor support within 0.04 m and velocity <0.1 m/s | PASS (foundation only, one run) |

The foundation recovery suite checks only storage-root injection and rejection. It does
not implement or validate SaveStore, restart, saved-room resume, or production recovery.
Registry/death behavior is now implemented and covered by the US1 results below.
No suite is represented as complete story coverage by the foundation results.

## Defects and environment limitations

| ID | Observation | Resolution / remaining work |
| --- | --- | --- |
| ENV-001 | Restricted first import could not create engine user/cache/config files and local editor sockets | Wrapper redirects XDG directories into disposable `/tmp/omdb-engine-*` directories; authorized headless checks run with local socket access. Game save-root injection is separate. No errors suppressed. |
| ENV-002 | No `/dev/dri` or `/dev/input` exposed | Rendered checks, physical controller trials, and representative benchmark remain UNVERIFIED. |

## T011 negative harness results

Procedure: `python3 scripts/checks/check_harness.py`; fresh temporary project per fault,
headless Godot 4.7.2, Linux, no human input. Expected: each faulty runner/wrapper returns
nonzero, no production saves touched, no fault left in working code. Actual: all twelve
fault categories rejected; project files were only mutated in temporary copies.

| Fault | Observed exit | Result |
| --- | ---: | --- |
| Empty suite | 1 | PASS |
| Missing case script | 1 | PASS |
| Intentional false assertion | 1 | PASS |
| No assertions | 1 | PASS |
| Script parse/import error | 1 | PASS |
| Runtime script error | 1 | PASS |
| Missing final summary | 1 | PASS |
| Runner watchdog (0.1 s injected, unbounded frames) | 1 | PASS |
| Missing physics fixture | 1 | PASS |
| Unknown suite | 1 | PASS |
| Unsafe `user://` root | 1 | PASS |
| Caller process timeout (0.1 s, five-second child) | 1 | PASS |

One execution per fault; these prove harness failure handling, not ten-trial gameplay.
Intentional fault injections never entered the working tree. T011 complete.

## Tuning history

All [R8 defaults](research.md#r8-initial-tuning-and-measurement-decisions) are captured
in `resources/gameplay_tuning.tres` and remain labelled unmeasured. No observed control,
jump, placement, camera, or performance measurement has justified a tuning change yet.

## Greybox and representative character gates

| Gate / requirement | Expected evidence | Actual | Status |
| --- | --- | --- | --- |
| G1 / VR-003 | Keyboard/controller greybox: movement, jump, death, carry, placement, stacks, plates, saws, cap | US1 movement/death/bridge fixture and tests complete; carry/plate/saw core still pending | UNVERIFIED |
| VR-004 / SC-009 | Actual-camera cow material/scale/action review with one player and five corpses; performance observations | GLB imports; source provenance verified; visual assessment unrun | UNVERIFIED |
| VR-002 / SC-003 | Ten fresh rebuilds and traversals per bridge/stack | Ten scripted fresh US1 bridges and ten support-removal trials pass; human traversal/readability review unrun | PARTIAL |
| G2 / VR-006 representative flow | Complete menu/play/restart/settings with keyboard and controller | Not implemented/run | UNVERIFIED |

## State and recovery scenario trials

VR-001 / VR-005 require ten repetitions per applicable scenario, including all
EC-01–EC-15. Story trial records will be appended below as actual tests run.
US1 applicable state/physics results follow below. All other story and recovery scenarios remain UNVERIFIED.

## Six-room solution records

All room production awaits G1/G2. Each future record must include original scene,
measured geometry/jump reach, exact actions, creation order, placements, peak count,
anti-bypass checks, ten fresh trials, traversal observations, and defects.

| Room | Intended teaching | Trials | Status |
| --- | --- | ---: | --- |
| 1 | Sacrifice/traversal | 0 | UNVERIFIED |
| 2 | Carry/weigh | 0 | UNVERIFIED |
| 3 | Persistent jam | 0 | UNVERIFIED |
| 4 | Anvil/FIFO replacement (six creations, five active) | 0 | UNVERIFIED |
| 5 | Deliberate five-body allocation | 0 | UNVERIFIED |
| 6 | Final combined experiment | 0 | UNVERIFIED |

## Native input matrix

| Platform | Input | Full flow / restart / reopen / settings / replay | Status |
| --- | --- | --- | --- |
| Windows x86_64 | Keyboard | Not run | UNVERIFIED |
| Windows x86_64 | Controller | Not run | UNVERIFIED |
| macOS Universal 2 | Keyboard | Not run | UNVERIFIED |
| macOS Universal 2 | Controller | Not run | UNVERIFIED |

Native machines and matching export templates are not available here. Downloaded macOS
launch/signing and architecture smoke checks remain UNVERIFIED.

## Performance

Required: rendered release build, one player/five bodies/hazards/effects, 1920×1080,
30 s warmup and 120 s capture; record actual hardware and frame/physics p95,
triangles/draw calls/effects. Targets: frame p95 ≤16.7 ms, physics p95 ≤4 ms.
No rendered capture run: UNVERIFIED. Headless support timing is not a benchmark.

## First-time playtests

Required: at least five people unfamiliar with solutions, active completion times
including retries, non-completions/help, cue recognition, jump judgments, placement
frustration; pacing review/follow-up after changes. No participants/session evidence:
UNVERIFIED. The 20–30 minute median and ≥80% cue recognition remain targets.

## US1 implementation and regression checkpoint (T012–T023)

**Build identity:** working tree based on `2952b7180465b0afa87f0b8c5046a6841b4338c4`. SHA-256 of sorted runtime/test
paths and bytes (`path + NUL + bytes + NUL`, excluding UIDs/cache): `a6a55391c9647232cc40b8cbcdfbf27710ba8a6b17ea5a88db2939d13c0408fd`.
Includes project/version files and `.gd`, `.tscn`, `.tres`, `.glb`, `.import` under
scripts/scenes/tests/resources/assets/characters/cow. This identifies the code tested;
no Git commit has been created.

**Setup:** Linux, Godot 4.7.2 standard, Compatibility selected, Jolt, 60 Hz physics;
headless Dummy renderer/audio; scripted input, no human/controller. Wrapper isolates XDG
engine data and injects `/tmp/omdb-us1-final` before game save access. Tests use fixed
60 Hz simulation (`--fixed-fps 60`), accelerated relative to wall time. CPU/GPU benchmark
conditions are not exercised. Command in quickstart; final process exit 0.

**Expected:** compile every current script/scene/resource; all nonempty requested suites
pass; one accepted death/corpse/replacement, body count ≤5 with creation-order eviction,
no stale contact acceptance, solid support, support-removal settling, and ten fresh
scripted bridge traversals.

**Actual:** 33 resources compile/load without engine/script errors; 2,906
assertions pass, zero fail. State: 1,909; physics:
989; foundation storage-root recovery: 8.

| Scenario / requirements | Setup and actions | Expected / actual | Repetitions | Status |
| --- | --- | --- | ---: | --- |
| T012/T015; FR-013; EC-02 | New registry per trial; create 12 bodies and inspect every returned identity, immutable age/origin, snapshots, FIFO and eviction result | Unique epoch-qualified IDs; never >5; oldest correctly replaced; returned record mutation cannot alter authoritative age — all pass | 10 × 12 creations | PASS |
| T012/T015; FR-004–FR-005; EC-01–EC-02 | Fresh RoomState, 12 accepted deaths per trial with duplicate/stale epoch/subject requests and repeated replacement token | Exactly one latch/replacement per subject; old tokens rejected; prior body IDs retained except legitimate eviction — all pass | 10 × 12 deaths | PASS |
| T014/T017; FR-003 | Independent expected 45° ground directions, normalized diagonals, analog magnitude and echoed/non-echoed jump events | Correct cardinal vectors/speed; echo rejected; one press buffers jump — all pass | 10 per scenario | PASS (scripted input only) |
| T013/T016/T018; FR-006/FR-017; EC-06/EC-08/EC-14 | Actual corpse boxes on spike-support bed; live player stands/traverses upper body; disable support and wake upper prop | Lower/upper centre height within 0.04/0.06 m; live actor supported without death; upper settles within 0.04 m after removal; exposed contact kills; corpse survives — all pass | 10 fresh fixtures | PASS |
| T019/T022; FR-004–FR-006/FR-013–FR-014; EC-01–EC-02 | Real player/corpse/HUD scene, two lethal requests in same dispatch, seven repeated deaths per fixture; arrange resulting props in separated diagnostic space | Immediate dead-player ineligibility, disabled physical shape after commit, one corpse at observed X, one replacement at safe hatch, count ≤5, marker agrees with registry — all pass | 10 × 7 scene deaths | PASS (no human timing claim) |
| T021/T023; VR-002/SC-003 preliminary | Fresh greybox each trial; walk/jump into spike strip, let actual hazard create central corpse, respawn, jump onto corpse, walk top, jump to far bank | One hazard-created body supports completed route; replacement alive/grounded beyond x=2.12; no extra deaths — all pass | 10 consecutive fresh rebuilt routes | PASS (scripted); playable review UNVERIFIED |
| T020; FR-006/FR-035 preliminary | Import cow, resolve Idle/Move/collapsed clips, squash visual and inspect independent collision, sample/pause corpse pose | Clips resolve; continuous movement loops; visual scale does not alter collision; flat pose paused; released box translates with rotation locked — all pass | 1 integrity run | PASS (resource/animation integrity only) |

Body/rig metadata and scripted animation integrity do not establish visual fit or camera
readability. Mixed-hazard and held-body twenty-death timing acceptance remains T043.
The recovery suite still validates only root isolation; SaveStore and actual recovery
are not implemented. Carry/plate/saw/anvil scenarios are not silently covered by these results.

### Observed defects and corrections

| ID | Observation | Fix / recheck |
| --- | --- | --- |
| DEV-001 | Child HUD `_ready` preceded parent state initialization and raised a nil snapshot error | Initialize state in room `_enter_tree`; final all-suite recheck has zero script errors |
| TEST-001 | Support-removal fixture teleported a live CharacterBody away from contact, injecting a large kinematic solver velocity into its supporting body | Disable the test actor before independent support-loss trial; upper prop now settles in ten trials. This was a fixture correction, not evidence that arbitrary game teleports are safe |
| TEST-002 | Bridge test inspected registry at the immediate death latch, before the deferred physical commit | Await the safe commit boundary; ten fresh routes pass |
| DEV-002 | Imported continuous clip loop behavior was not guaranteed by clip names | Explicit Idle/Move looping and animation-integrity assertion; final check passes |

### T023/T024 playable boundary

T023 automated rerun (2026-10-08): Linux, Godot 4.7.2 standard, Compatibility/Jolt,
headless fixed 60 Hz, isolated temporary roots. State completed with
`OMDB_TEST_RESULT {"failed":0,"passed":2829,"suites":{"state":2829}}`; physics completed
with `OMDB_TEST_RESULT {"failed":0,"passed":2859,"suites":{"physics":2859}}`. These
passes include the ten fresh greybox bridge/support trials and the death/replacement,
support-removal, exposed-spike, and corpse-survival repetitions described above. No
script/import errors or failed cases were observed. This closes T023's repeatable
automated evidence; mixed-hazard/held-body timing remains reserved for T043.

Attempted an actual rendered launch of `greybox_validation.tscn` with isolated storage
and five-iteration limit. **Actual exit 1:** `X11 Display is not available`, Wayland
connection/creation also failed, and Godot reported all display drivers failed. `/dev/dri`
and `/dev/input` are absent. Therefore human physics/control feel, maximum jump reach
including forgiveness under each input method, shadows/landing judgment, camera framing
at the three required resolutions, and actual-camera cow fit cannot be checked here.
No graphics acceptance was inferred from headless tests. T024 remains unverified and
unchecked; the US1 phase is not fully accepted until the rendered/controller gate passes.

The invoked implementation skill requires phase completion before moving to the next
phase. Implementation stops at this phase validation boundary; later tasks remain open.
Feature scheduling permits isolated later systems while G1 is unavailable, but no such
later phase is claimed implemented at this checkpoint. Full room production remains gated.

## Keyboard playtest defect and fix — DEV-003 (2026-10-08)

**Requirements/tasks:** FR-003, FR-031; US1/AS1; T002/T014/T017/T024.

**Reported setup:** User launched the isolated greybox using the documented command and
a `mktemp -d /tmp/omdb-greybox.XXXXXX` save root. Input: keyboard arrow keys. User platform,
engine/build, hardware, resolution, and repetition count were not reported.
**Expected:** Right Arrow moves screen-right; Left Arrow moves screen-left.
**Actual user report:** Right Arrow moves left; Left Arrow does nothing. Original
playable keyboard result: FAIL. This is defect evidence, not completion of T024.

**Reproduction:** Query the installed Godot 4.7.2 constants and match actual
`InputEventKey` events against the loaded InputMap. `KEY_LEFT` is 4194319 and
`KEY_RIGHT` is 4194321. The serialized left action had 4194321 (Right Arrow), while the
right action had 4194323 (Page Up). UI left/right had the same mistake. The camera-relative
movement function was correct; the earlier tests exercised vectors and movement overrides
and therefore missed the serialized keyboard binding defect.

**Fix:** Correct only the arrow-key entries for `move_left`, `move_right`, `ui_left`,
and `ui_right` in `project.godot`. Preserve WASD and controller bindings. Add
`tests/state/test_keyboard_input.gd` to send actual key events through InputMap and
`tests/physics/test_keyboard_movement.gd` to drive actual CharacterBody3D motion with
those events, with movement overrides disabled. Project settings remain authoritative;
no runtime remapping was added.

**Regression setup:** Agent Linux environment and hardware as recorded above; engine
4.7.2; headless real Jolt simulation at fixed 60 Hz; synthetic keyboard events; isolated
engine caches and game save roots. Fresh reusable physics fixture/player for each motion
trial; use the actual orthographic camera's projected screen positions for assertions.

| Check | Actions / expected result | Actual result | Repetitions | Status |
| --- | --- | --- | ---: | --- |
| Before-fix keyboard regression | New state tests with actual Left/Right key events, exclusivity, UI arrows, diagonals and opposing keys | Exit 1; 90 failures, 2,159 passes; reproduces the user report without script/import errors | 10 per state scenario | Confirmed defect |
| Correct movement bindings | Press/release each arrow and WASD key; exactly the intended movement action and vector, zero on release | All pass | 10 per key | PASS (synthetic input) |
| UI navigation arrows | Each arrow matches exactly its corresponding UI direction | All pass | 10 per arrow | PASS (binding only; menus still planned) |
| Combined keys | Diagonal normalized; opposite horizontal keys cancel; releasing one preserves the remaining direction | All pass for arrows and WASD | 10 per category per key set | PASS |
| Real player motion | From safe fixture spawn, press each key for 12 physics frames; projected displacement >1 pixel along intended screen axis, perpendicular displacement <0.1 pixel; release and await 20 frames to stop | All pass with `use_movement_override=false` | 10 fresh fixtures per key (80 total) | PASS (scripted playable components) |
| Existing affected regressions | Full state/physics/root-isolation suite, including ten fresh bridge rebuilds, support-loss settling, death/cap/oldest/visual checks | Exit 0; 35 resources compile/load; 3,486 assertions pass, zero fail (state 2,249; physics 1,229; recovery 8) | Existing required scripted trials plus new trials | PASS |

Commands:

```sh
# New regression tests were run before editing the bindings:
python3 scripts/checks/run_checks.py --suite state --save-root /tmp/omdb-keyboard-red
# Final verification after the binding fix:
python3 scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-keyboard-fixed
```

**Fixed-build identity:** same source-path/byte hashing procedure as the earlier checkpoint:
`18bb05d9a2ca5424c7acbb2493552e2b1904184b1ca7ae5478bee2112186537a`. Earlier checkpoint records are historical; this recheck
supersedes their affected input/bridge regression evidence.

**Remaining:** Human confirmation of the corrected arrow controls is UNVERIFIED. User
must close and relaunch the scene to load the updated InputMap, then check all four arrows,
WASD, releases/diagonals, and jumps. Controller comfort, native platforms, camera/readability,
and the rest of T023/T024 remain unverified. No tuning or acceptance thresholds changed.
DEV-003 is fixed in code and regression-verified; manual retest is pending.

## Carry, contacts, FIFO, saw, and anvil checkpoint (T025–T048)

**Status:** T025–T034, T037–T042, and T045–T047 implemented and regression-verified.
41/105 implementation tasks are complete. Required playable checks remain unchecked.
The user said the keyboard playtest was “good” and requested continued implementation
following DEV-003. This is informal feedback; no controller, resolution, ten-trial manual
placement, or character acceptance was reported. Earlier manual-pending records remain
historical; this feedback does not complete T024 or T044.

**Build identity:** SHA-256 `28ed0dad094a8b9cb969b6ed82a8f34e2ba225ad67458c2f6edc1f8f885eae62`.
Sorted `path + NUL + bytes + NUL` for `project.godot`, `.godot-version`, and every file
under scripts/tests/scenes/resources/assets excluding `.uid`, `.md`, and `.import`.
No Git commit was created. Same engine/hardware as the header; headless Dummy rendering,
Jolt, fixed 60 Hz physics, scripted input, disposable engine XDG and injected save roots.
No rendering/physical-controller or native-platform performance claim.

```sh
# Behavioral expectations before saw/anvil implementation:
python3 -u scripts/checks/run_checks.py --suite state --save-root /tmp/omdb-saw-red
python3 -u scripts/checks/run_checks.py --suite physics --save-root /tmp/omdb-anvil-red
# Final integrated verification:
python3 -u scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-systems-final
python3 -u scripts/checks/check_harness.py
```

Saw RED: 20 behavioral failures (unique contributors and remaining jam), 2,609 passes.
Anvil RED: 30 behavioral failures (warning, impact, repeat), 1,979 passes. Both wrappers
returned nonzero as expected; minimal unimplemented interfaces compiled. Earlier US2
expectations likewise failed before carry/contact implementation. Final run: exit 0,
57 resources compile/load, **4,716 assertions pass, zero fail** (state 2,649; physics 2,059;
recovery 8), with no engine/script errors. The recovery assertions still establish only
save-root isolation, not SaveStore or production restart/resume. Negative harness:
all 12 intentional faults rejected, exit 0; the injected process timeout prints its
expected failure message. Faults were confined to disposable project copies.

| Requirements / tasks | Setup and actions | Expected and actual | Repetitions | Result |
| --- | --- | --- | --- | --- |
| T025/T030/T032; EC-03–EC-05 | New state/physical room; missing/second pickup, stale release, oldest/newer held at five; die and replace | One held ID, unchanged age/count, disabled world physics; carrying death releases before FIFO; oldest removed, newer survives, one replacement — pass | 10 per state case; 10 per held age in real physics | PASS (scripted) |
| T026/T028/T034; SC-006 | Fresh player at hatch, body centre (-3.7,.245,0), facing +X; floor, settled body (-3.4,.245,0), and local spike supports | Same evaluator ghost/commit; full volume clear, accepted collision restored; centre within .04m vertically and horizontal preview difference <.03m after settle — pass | 10 each surface | PASS (physics) |
| T026/T034; SC-006 | Reach/player/world/body overlap, transport wall, removed floor, incomplete footprint and moving support; stale preview before E intent | Rejection reason correct; stale/invalid interaction keeps held identity, frozen collider, queue age/count — pass | 10 per defined category | PASS (scripted; manual interaction review pending) |
| T027/T029/T034; EC-06–EC-07/EC-15 | Two direct bodies on two-unit plate, upper stack, live player, pickup/removal; close occupied door at (5,0,0) | Unique direct units only; upper contributes nothing; held excluded immediately; unsupported upper settles; safe entry-side retreat, live player, reserved anchor — pass | 10 fresh setups | PASS (physics) |
| T037/T040/T041; EC-02–EC-07/EC-14 | Five bodies, oldest held/supporting/plate/saw; sixth death; inspect carry marker, collider/contact removal and burst | Count stays five, indicated oldest removed in every role; carry clears, plate/saw lose contributor immediately, unsupported stack settles to floor within .04m; burst has no collision objects — pass | 10 per role, state and physics | PASS |
| T038/T039; EC-14 | Two released bodies overlap jam box; wait 600 fixed frames; hold one, remove final with live player already in rotor volume | Jam has no timeout; first removal leaves jam; final removal reactivates and kills existing live contact exactly once; stopped rotor has no solid obstruction; bodies survive — pass | 10 fresh setups, each ≥10 simulated seconds jammed | PASS (physics; human route readability pending) |
| T038/T040; EC-07 | Three bodies directly on widened two-unit plate; remove one then another | Weight 3→2 keeps door open, 2→1 closes; immediate reconciliation — pass | 10 real physics setups plus 10 state trials | PASS |
| T045–T047; EC-08–EC-09 | Player and settled corpse under actual anvil component; inspect warning at .5s, impact after 1s, repeat at 4s; retire and wait | One-second warning, three-second repeat cycle; impact kills player with one replacement; corpse remains stable and intact, no impulse; retirement cancels future impacts — pass | 10 fresh setups | PASS (physics; warning readability pending) |
| Prior US1 regressions | Full suite including arrow events/motion, duplicate deaths, ten fresh spike bridge rebuilds and rig/collider integrity | Existing affected regressions remain passing | Existing ten-trial loops rerun | PASS (scripted) |

**Defects found and resolved:**

- US2 pickup fixture initially overlapped the player capsule, pushing it and changing
  the intended preview/support alignment. Body centre moved to -3.7; support/reach
  thresholds and assertions were preserved.
- Static save-root storage retained `save_paths.gd` at engine shutdown. An attempted
  static-unload annotation did not resolve it. Session data now lives in SceneTree
  metadata, preserving isolation validation; clean shutdown and root checks pass.
- A new saw test referenced a nonexistent death counter. The runtime error aborted its
  cleanup and left a fixture floor present, causing later missing-support failures.
  Correcting the test to assert actual subject/replacement identity restored clean
  cleanup and both suites pass. No placement tolerance or expectation was weakened.

**Still UNVERIFIED:** T024 human controls/jump/framing; T035 manual placement with
both devices; T036 manual stack/bridge traversal; T043 twenty active-play mixed/held
hazard deaths timed to restored control; T044 the integrated keyboard/controller and
one-player/five-cow visual/performance gate; T048 human warning/jam/door checks. Tests
use accelerated simulation, so their tick counts do not establish active-play latency.
No graphical/controller access is available here. Full six-room production remains
blocked by T044; isolated recovery/menu work remains unimplemented. New station steps
are in `quickstart.md`. No tuning values or acceptance requirements changed.

## Recovery, menus, controller mapping, and representative exports (T049–T067)

**Final scope:** 58/105 tasks implemented. T049–T056, T058–T064, T066–T067 complete
isolated recovery/representative flow work. T057/T065 human checks remain unchecked,
alongside the earlier greybox/character tasks. The catalogue intentionally maps all six
valid IDs to the same reusable greybox; no six-room teaching sequence is authored.
T044 and T065 are the hard entry gate for Phase 8.

**Setup:** same Linux/engine/CPU as the header, Compatibility selected, fixed 60 Hz Jolt,
headless Dummy rendering/audio, synthetic keyboard and joypad events (including device
42), separate disposable save/engine paths. Child-process reopen tests run the same exact
Godot executable against the recovery fixture. No physical controller/display/native OS.

```sh
# Save expectations before behavior:
python3 -u scripts/checks/run_checks.py --suite recovery --save-root /tmp/omdb-save-red
# Corrected interfaces, before room transactions:
python3 -u scripts/checks/run_checks.py --suite recovery --save-root /tmp/omdb-reset-behavior-red
# Menu/audio expectations before behavior:
python3 -u scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-menu-red
# Device-independent controller expectations before binding fix:
python3 -u scripts/checks/run_checks.py --suite state --save-root /tmp/omdb-controller-red
# Final checks:
python3 -u scripts/checks/run_checks.py --suite all --save-root /tmp/omdb-final-flow
python3 -u scripts/checks/check_harness.py
python3 -u scripts/checks/export_fixture.py --template-dir /tmp/omdb-export-templates/4.7.2.stable
python3 -u scripts/checks/check_package.py
```

Behavioral RED results: saves 150 fail/128 pass; reset transactions 20 fail/358 pass;
menu/audio 40 fail/5,646 pass; device-42 binding and pause 20 fail/2,799 pass. These runs
compiled and returned nonzero for unmet expectations, not empty tests. Final integrated
regressions: **5,976 pass, zero fail** (state 2,829; physics 2,059; recovery 1,088), 82
resources compile/load, exit 0 with no engine errors. All 12 negative harness probes
are rejected; its deliberately injected process-timeout message is expected.

| Requirements / tasks | Setup/actions | Expected and actual | Repetitions | Result |
| --- | --- | --- | --- | --- |
| T049/T051; EC-11–EC-12 | Separate version-1 progress/settings in injected roots; six IDs, missing/corrupt/unsupported schemas, invalid room values, unknown fields, partial/non-finite/bool/string/out-of-range volume values | Valid IDs retained; fallback room 1; independent field defaults; finite numbers clamped; malformed reads do not overwrite; no production-root fallback — pass | 10 per category, all six IDs | PASS (Linux) |
| T049/T051; EC-12 | Real root-path write failure; controlled temporary-write and checked-rename failures after valid destination exists | Nonzero result; previous progress byte-identical and loadable; prior settings retained; only owned temporary files cleaned — pass | 10 per failure category | PASS |
| T050/T052/T053/T055; EC-09–EC-10 | Held oldest, queued death, committed feedback/pending replacement callback, saw jam, queued placement; restart before/after another activation | Old epoch retired immediately; fresh room/player/queue/carry/machinery; initial anvil phase restored at activation; exactly one hosted room; stale commands/callbacks rejected; restart targets committed room — pass | 10 per scenario | PASS |
| T053; EC-10–EC-11 | Bad candidate root after valid room 3, invalid arbitrary path and duplicate catalogue | Prior playable room/progress retained; lookup rejected; no invalid candidate committed — pass | 10 per category | PASS |
| T054/T056; VR-005 | Each valid ID, settings .12/.88; populate/hold body, close; run a separate Godot process to reopen | One live subject, zero bodies/carry, original plate/door/saw state, correct room/settings, no engine errors — pass | 10 × 6 independent process reopen trials | PASS (fixture IDs, not authored rooms) |
| T055; FR-026 | Actual physical R key and North face-button events on device 42 during death feedback | Fresh room/epoch, one player, zero bodies, brief restart feedback; no stale replacement — pass | 10 per method | PASS (synthetic events) |
| T058/T061/T063 | Title/Continue; Escape and joypad pause events; queued death feedback and movement while paused; Settings/Back; Quit to Title/Continue | Opening event consumed; simulation/feedback frozen; Resume focused; Settings Music focused; previous Settings control restored; reentry fresh — pass | 10 per flow | PASS (headless controls) |
| T058/T062 | Stick noise .1 then active .7; key E; active-device disconnect/reconnect and application focus loss; replace HUD then change method | Noise ignored; generic controller/key prompts switch; active disconnect/focus loss pauses; reconnect retains focus; freed HUD subscriptions do not run — pass | 10 each | PASS (synthetic; physical hardware unverified) |
| T059/T060/T064; SC-010 | Live Music/SFX slider changes/mute, Back save, restart, fixture final-room completion, Replay, Quit to Title; forced settings-save failure | Separate buses and live mapping/mute; previous save survives failure while current volumes stay active; failure shown briefly; room 6 retained at completion, Replay saves fresh room 1 and retains volumes — pass | 10 each | PASS (headless; audibility unverified) |

**Resolved defects and evidence limits:**

- ConfigFile's parser logs engine errors for malformed quoted values. The reader now
  parses only contract scalar fields with JSON's non-logging parser, checks structural
  lines/schema, ignores unknown fields, and preserves per-field defaults. Missing fields
  are tested before `get_value` so null defaults do not trigger Godot diagnostics.
  The harness still rejects unexpected engine errors; no output errors are filtered out.
- Every original joypad binding targeted device 0. Device-42 tests failed for Pause;
  bindings now use device -1 for all gameplay/UI joypad actions. Pause and restart pass.
  Actual controller comfort, mapping/disconnect behavior and native input remain unverified.
- Retired rooms now skip deferred commits/contact reconciliation, preventing obsolete
  puzzle updates after cancellation. New rooms initialize off the prior physics footprint,
  commit once, restore authored position, and save only after success.
- macOS Universal 2 export initially failed because ETC2/ASTC imports were disabled.
  Enabling `textures/vram_compression/import_etc2_astc` resolved the observed prerequisite.
  No gameplay tuning, engine choice, or acceptance threshold changed.
- The rapid packaged smoke test exposed active preview audio retained at shutdown;
  Explicit stop/clear on exit alone did not resolve the Dummy-backend retention.
  Headless checks now retain streams/bus routing without starting inaudible playback;
  normal graphics sessions still play previews. Native audibility/shutdown remains
  unverified. Final package checks shut down cleanly; no engine diagnostics are filtered out.

### Template provenance and export evidence

Matching standard templates were obtained from the
[official Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/).
The full 1.22 GiB download timed out; a range reader retrieved only the needed release
members and checked their ZIP CRCs and exact `4.7.2.stable` version. Per-member SHA-256
is retained in `export-template-source.json`; no full-archive checksum is claimed.
All template data is outside the repository under `/tmp/omdb-export-templates`.

Windows x86_64 and macOS Universal 2 exports succeed. Windows PE architecture, required
PCK header, and macOS fat-binary x86_64/arm64 entries are checked. Automated test runners
and source art are excluded; the representative menu/greybox fixtures remain included.
The exporter restores `res://scenes/main.tscn` after temporary fixture selection and keeps
unrelated project edits. Exact final artifact sizes/hashes are recorded below and in
`builds/fixture-manifest.json`; `builds/` is ignored. The macOS app is unsigned/unnotarized.
Linux headless PCK checks pass and prove packaged resources/menu/recovery behavior;
they do not run native binaries or establish VR-006 acceptance.

**Remaining:** Actual keyboard/controller placement/traversal and Stage 1/2 playable
checks (T023–T024, T035–T036, T043–T044, T048, T057, T065), character/camera review and
measured performance, six-room authoring/solutions/progression, final presentation/audio,
Windows/macOS native input/launch/signing, and first-time-player acceptance. Required
physical/display checks cannot run here. Phase 8 remains blocked by its explicit gate;
no complete-slice or release acceptance is claimed.

### Final build and packaged smoke results

**Final build identity:** SHA-256 `81c9ecf09fbac7df9e7be87a8fcfe95a6ecf9fc436273b8bf76db0fb5ee3769c` of sorted `path + NUL + bytes + NUL`
for project/version/export presets/default bus layout and every file under scripts/tests/
scenes/resources/assets excluding `.uid`, `.md`, `.import`, `.pyc`, and `__pycache__`.
This includes runtime and verification tooling. No Git commit was created.

Final full run `/tmp/omdb-final-flow.log`: 82 imports, 5,976 assertions, zero failed,
exit 0, no engine errors. Final export `/tmp/omdb-final-export.log`: both presets succeed,
exact 4.7.2 templates, normal main-scene wiring restored. Final package smoke
`/tmp/omdb-package-final.log`: **Windows and macOS PCK flows PASS**, clean exit 0 and
no engine errors. Linux checks use an empty source fallback directory, load the exported
Title/Continue/Pause/Settings/Quit-to-Title/fresh-Continue flow, validate retained volumes,
and confirm excluded automated runners are absent. This is not native binary execution.

| Artifact | Bytes | SHA-256 | Acceptance |
| --- | ---: | --- | --- |
| `builds/windows/over-my-dead-body.exe` | 109,127,680 | `4a9eaded8955ef789ab02651ed9d2dde80328fbb342bd2a6db4db33e86305668` | Native launch UNVERIFIED |
| `builds/windows/over-my-dead-body.pck` | 307,112 | `dc004e821d461562cdece972eda668b8521f3304ba3d69c47c81f04fa55cd044` | Required companion; Linux PCK smoke PASS |
| `builds/macos/over-my-dead-body.zip` | 59,889,152 | `33af55a92dc2c999311a279e61ee318ffc4e940edc8dcdcba0a9c3eb24ccee75` | Native launch UNVERIFIED |

The macOS application contains x86_64 and arm64 executable slices. The Windows executable
is x86_64 PE and has its separate valid PCK. Neither package has native visual/input,
signing, downloaded-launch, or release acceptance. They require a temporary `--save-root`
and contain representative fixtures, not the six-room slice. Full room production remains
blocked by T044/T065.

## Extension hooks

`.specify/extensions.yml` is absent at both pre-execution and post-execution checks.
No before/after hooks are configured; both dispatch stages were skipped as required.

## Release acceptance

NOT READY. Remaining implementation, gates, native checks, and playtests are required.
No files have been published or deployed.

## Table placement playtest correction — DEV-004 (2026-10-08)

**Reported defect:** “placing objects on the table is not intuitive enough — feels like
we're blocked when we shouldn't be”. The precise on-screen rejection reason was not
provided. Repeatable tests reproduced overly narrow edge/diagonal placement and a raised
table's edge blocking its own transport ray. No rendered observation is claimed here.

**Setup:** Godot 4.7.2.stable.official.ed1daf0bf, Jolt at 60 Hz; physics fixture player
at (-5, 0, 0), held 1.8 × 0.45 × 0.9 m body. A real 3.8 × 2.0 m pressure plate is offset
so nominal aim straddles its edge; test straight and diagonal facing. Raised table is a
2.2 × 1.0 × 2.2 m static box. Second-body trial uses two released direct contributors,
with the new aim slightly intersecting the existing body. Negative trials use a 3 m wall,
a 0.3 m support, and an obstacle added after a valid preview. Each arrangement is rebuilt
ten times in `tests/physics/test_placement_assistance.gd`; the existing floor trial now
also checks that valid nominal aim stays unchanged.

| Scenario | Expected outcome | Actual result |
| --- | --- | --- |
| Straight/diagonal table edge | Find supported spot within 0.6 m; preserve continuous facing; preview matches release | PASS, ten rebuilt trials each |
| Raised tabletop | Lift above edge; release at stable supported height | PASS, ten rebuilt trials |
| Second body on plate | Find adjacent clear spot; both settle and contribute two direct units | PASS, ten rebuilt trials |
| Wall/undersized support | Reject; retain held identity, freeze and disabled solid shape | PASS, ten rebuilt trials each |
| Stale valid preview | Added obstruction causes fresh release rejection; retain held body | PASS, ten rebuilt trials |
| Already valid floor aim | Horizontal candidate remains at nominal 1.6 m aim | PASS, ten rebuilt trials |

**Implementation:** A valid nominal candidate remains unchanged. Otherwise, eligible
support/occupied-body failures trigger nearby box support projections and alternatives,
ordered by distance and bounded to 0.6 m. Every alternative retains the existing reach,
normal/height/velocity support, endpoint volume, and protected-space checks. Explicit
target queries stay strict. Transport rays follow a lift/traverse/lower path from the
1.2 m carry anchor. Invalid ghost height reflects its centre support; HUD feedback now
directs players to step back, approach the middle, or move around an obstacle.

**Behavioral evidence:** RED `/tmp/omdb-placement-assist-red.log`: 180 failed, 2,279 passed.
First implementation left 40 diagonal failures near reserved spawn space; nearby safe
alternatives resolved them without removing the reservation. Physics GREEN
`/tmp/omdb-placement-assist-green2.log`: 2,459 passed, zero failed. Final full run
`/tmp/omdb-placement-final.log`: 83 imports, **6,386 passed, zero failed** (state 2,829,
physics 2,469, recovery 1,088), exit 0, no engine errors. The full run emitted one Jolt
job-capacity warning at shutdown after the passing summary; standalone physics and
package checks did not emit it. Rendered query cost remains unverified under T109.

**Current source identity:** SHA-256 `ea5cd903a0d611c29f26a5185f1cdc1ce9fb17bbbf4e1758775dc76a0c411e34`,
using the preceding checkpoint's sorted path/NUL/bytes/NUL procedure. This supersedes
the preceding source identity for the placement correction. No Git commit created.

**Refreshed representative packages:** `/tmp/omdb-placement-export.log` passes both
exports using exact 4.7.2 templates; project main-scene wiring restored.
`/tmp/omdb-placement-package.log` passes both Windows/macOS PCK flows on Linux without
source fallback or engine errors. These are fixture packages; native execution and
six-room release acceptance remain unverified. Current package identities:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `builds/windows/over-my-dead-body.exe` | 109,127,680 | `4a9eaded8955ef789ab02651ed9d2dde80328fbb342bd2a6db4db33e86305668` |
| `builds/windows/over-my-dead-body.pck` | 310,104 | `2eafd4eca0b47be51b7007c49edb31b839c20cbd26e2d98a1f384d111d35851c` |
| `builds/macos/over-my-dead-body.zip` | 59,891,730 | `814fe39507f9bb0ed92c0bb7bf146f07339e61173f4d5dd93d3bc93b111e22e3` |

**Task status:** T106–T108 complete. T109 remains UNVERIFIED: keyboard/controller
placement feel, ghost readability, and rendered physics/frame costs require display and
physical controller access. Relaunch the original greybox command in `quickstart.md` to
retest. Earlier manual gates, native acceptance, and full room production remain open.
Requirements checklist remains 16/16 complete. `.specify/extensions.yml` is absent at
post-execution; no hooks are configured. Release remains NOT READY.

## Reusable presentation and playtest preparation (2026-10-08)

**Scope:** T023/T084/T085/T087/T088/T089/T094/T110 complete; total 69/110 tasks. These are independent
asset/system/protocol preparations allowed before room authoring. No full-room production
or final presentation gate is claimed. T044, T065, T091 and native/release checks remain open.
The user's “ok thats better” feedback confirms informal improvement after DEV-004; it does
not supply T109's ten trials, controller review, or rendered cost evidence.

**Setup:** Godot 4.7.2.stable.official.ed1daf0bf, Jolt 60 Hz, real physics fixture with held
corpse and separate visual rig. Ten rebuilt trials cover visual isolation, forty consecutive
cosmetic requests, muted death flow, named saws, jam transitions, anvil warning/impact, and
retired rooms. Twenty rebuilt overlapping-death trials check one replacement/body creation
and control restoration within 120 active physics frames. No display/speakers/controller
acceptance is inferred from the headless setup.

| Check | Expected outcome | Actual result |
| --- | --- | --- |
| Imported Idle/Move/Hurt plus carrying | Player/corpse shapes and held eligibility stay unchanged | PASS, ten trials |
| Forty mixed death/eviction bursts | At most 24 visible fragments; no collision nodes or queue/support mutations; effects expire after 0.6 active seconds | PASS, ten trials |
| Twenty overlapping death reports | One committed death and visible feedback; one replacement by two active seconds | PASS, twenty trials |
| Music and cue resources | Looping >10-second music; six distinct short sounds; one Music/four bounded SFX voices | PASS, ten trials |
| Muted death and custom `blade_west` ID | Deduplicate deaths; classify unique hazard ID by component type; preserve respawn | PASS, ten trials |
| Persistent saw jam | Sound once on first transition; no per-tick repeats | PASS, ten trials |
| Anvil cycles including lethal impact | Warning at each cycle start; one clang per drop, without lethal-commit duplication | PASS, ten trials |
| Retired room | No subsequent presentation cues | PASS, ten trials |

**Changes:** Original eight-bar 132 BPM swing music and six original sample-free cartoon
sounds replace the settings-only previews. The generator and source/cue inventory are in
`assets/audio/SOURCE.md`. PCM WAV paths replace initially proposed Ogg files using built-in
Godot import because no external encoder is available. Source measurements: music
641,498 bytes / 14.545442 seconds; six effects total 113,600 bytes / 0.22–0.65 seconds;
all PCM peaks 0.749992, with no clipping. Actual musical style, loop seam, balance and
speaker/headphone audibility remain T091 UNVERIFIED.

Room presentation requests bind to the same audio service in both application and isolated
greybox contexts. Hazards retain their visual signals when muted. Death and eviction now
share non-colliding cosmetic feedback capped at 24 fragments; cosmetic expiration does
not drive the respawn transaction. Captions distinguish spike, saw and anvil deaths by
type even with custom IDs. `playtest.md` prepares five unrun session records, neutral cue
questions, active timing/intervention/non-completion rules, 80% scoring and follow-up
procedures; no participant results have been fabricated (T095/T096 remain open).

**Behavioral RED/GREEN:** An initial test syntax error was corrected before establishing
behavioral RED. `/tmp/omdb-presentation-red2.log`: 85 imports, 11 failed / 2,579 passed,
missing mapped audio and bounded feedback. `/tmp/omdb-presentation-green.log`: 89 imports,
2,759 physics assertions passed. After strengthening custom-ID and lethal-impact tests,
`/tmp/omdb-presentation-full.log`: **6,776 passed, zero failed**, state 2,829 / physics 2,859 /
recovery 1,088; 89 imports, exit 0, no engine errors. The full run again logs the existing
Jolt job-capacity warning at shutdown after the passing summary; no such warning appears
in the standalone GREEN or exported-package checks. Rendered performance is unverified.

**T087 asset inventory:** Original `room_dressing.tscn` and shared stone/ink materials
prepare a low miniature plinth/frame for later authored rooms. Final engine inspection
`/tmp/omdb-art-inventory.log`: 18 meshes, 248 triangles, zero collision nodes, lights or
shadow casters; exit 0. The temporary inspection script needed an explicit Node3D type
before its successful run. Art is not applied to the greybox or substituted for missing
room gates. `/tmp/omdb-presentation-art.log` passes 92 imports and all 2,859 physics
assertions, also logging the known shutdown job-capacity warning. Final export imports
the last material/mesh dimension adjustment. Actual readability, foreground occlusion,
frame/physics cost and final room integration remain T090–T092 UNVERIFIED.

**Current source identity:** SHA-256
`2759dc0d8e466744428c7909b54085c04e501d97dd6a63b70dafc20bd5d6e653`, using the prior sorted
path/NUL/bytes/NUL procedure. This supersedes the DEV-004 build for current playback.
No Git commit created; prior user working-tree edits retained.

**Exports:** `/tmp/omdb-presentation-final-export.log` succeeds for both exact-version template
presets, restoring the original project main-scene wiring. `/tmp/omdb-presentation-final-package.log`
passes Windows/macOS PCK flows on Linux without source fallback or engine errors. Native
binary launch, control/audio/rendered performance, signing and six-room acceptance remain
unverified. These are refreshed representative fixtures, with current identities:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `builds/windows/over-my-dead-body.exe` | 109,127,680 | `4a9eaded8955ef789ab02651ed9d2dde80328fbb342bd2a6db4db33e86305668` |
| `builds/windows/over-my-dead-body.pck` | 485,580 | `cc07dfe66ee41f691c89e4a344fca264822481c186e6520c21277efc0e5e4f25` |
| `builds/macos/over-my-dead-body.zip` | 60,041,625 | `72955468cd197fd8d59bdd0e61ae5cecdafc0c562aa9231649231f5037ec3307` |

**Remaining checks:** T091 rendered/muted review, T109 physical-controller placement and
query costs, and earlier G1/G2 checks remain UNVERIFIED. Relaunch the same greybox command
to see/hear this increment; use the flow fixture for saved settings. Requirements checklist
remains 16/16 complete. `.specify/extensions.yml` is absent at pre/post execution, so hooks
are skipped. Release remains NOT READY.

## Stacked plate weight correction — T110

Setup: Godot 4.7.2 headless physics suite, fixed 60 FPS, ten repetitions of the pressure
plate fixture. Each repetition placed two released bodies directly on a two-unit plate and
then a third released body directly above the first body; the test then removed the second
direct contributor and picked up the lower stacked body.

Expected: every released body in a stable support chain reaching the plate contributes one
unit; removing or holding a contributor immediately removes only that body's unit and lets
the remaining stack settle. Held bodies, side-by-side bodies, and bodies resting on an
ineligible support remain excluded.

Actual: `FR020.stacked_bodies_each_count` passed in all ten repetitions. The stacked plate
reported three units while all three bodies were released, two after removing the unrelated
direct contributor, and two after picking up the lower stack body once the upper body settled
onto the plate. The linked door state stayed open whenever the requirement remained met.
The final standalone physics runner reported 2,859 passed, zero failed. Earlier attempts
included corrected assertions, sandbox log/socket errors, a full-suite watchdog, and
60 failed subprocess-reopen checks in the sandbox; those attempts were not clean full
regression evidence. No display or physical controller was
available, so rendered placement feel remains unverified under T109.

## User acceptance and development continuation — 2026-10-09

The user states "all good, carry on with implementation. I have verified as much as I
need to." Record this as acceptance of their playtest and authorization to proceed with
US5 implementation beyond the prior G1/G2 scheduling boundary. Earlier reported defects
have automated corrections. The user did not report trial counts, hardware/controller
details, measured jump reach, three-resolution framing, or performance data. Keep those
manual verification tasks unchecked and preserve the release matrix. This supersedes
the earlier instruction to stop development at the unavailable manual-review boundary.

## Exit traversal and progression — T070 / partial T068

Setup: Godot 4.7.2, Linux, Compatibility/Jolt, fixed 60 Hz headless physics, real player,
door and room components, isolated storage. Ten trials each cover open forward crossing,
duplicate crossing, absent crossing evidence, closed door, outside-passage motion,
dead subject, simultaneous death, retired room, reverse travel and closure before commit.
Ten fixture-catalogue runs cross all six room IDs, verify fresh-room activation and saved
progress, reach Completion retaining room 6, reopen room 6, activate Replay via its button
retaining volumes, and cancel a queued crossing with restart.

Expected: one live-only transition per room, death/restart priority, no state carried into
the next room, save only after activation, room 6 retained at Completion and room 1 saved
on Replay. These fixtures do not prove authored-room solutions or native input behavior.

Behavioral RED: `/tmp/omdb-exits-red.log` fails the new open-crossing/duplicate assertions
before implementation. First GREEN passes 2,889 physics assertions. Subsequent full checks
revealed a reverse-crossing fixture teleported through the doorway before testing reverse
travel; set its initial position on the far side before observation. No runtime crossing
rule was weakened. Sandbox editor socket errors required the strict wrapper to be run
outside the sandbox; game saves and engine XDG directories remain disposable and isolated.

Final actual result: `/tmp/omdb-exits-final.log` passes the strict import and all-suite
wrapper: **7,016 passed, zero failed** (state 2,869; physics 2,969; recovery 1,178).
All ten repetitions of each new scenario pass, along with earlier carry, death, FIFO,
plate, support, hazard, settings and separate-process reopen regressions. T070 is complete;
T068 remains open for actual authored-room coverage, since its six IDs currently reference
the recovery fixture. No authored six-room solution is claimed.

`/tmp/omdb-exits-export.log` refreshes both desktop packages and restores main-scene
wiring. `/tmp/omdb-exits-package.log` passes both PCK smoke checks without source fallback.
Windows executable remains 109,127,680 bytes, SHA-256
`4a9eaded8955ef789ab02651ed9d2dde80328fbb342bd2a6db4db33e86305668`; its current
PCK is 488,300 bytes, SHA-256
`942f902cd0f0090383321615fbaf222ee6759ecd9be26cb671d34351e1a2e267`.
macOS ZIP is 60,044,516 bytes, SHA-256
`1dd1d330d5e32ecf0e47f749842475fe551bc71a33b4119705ce2aafe9e30f2e`.
Native launch and release acceptance remain unverified. Requirements checklist remains
16/16 complete; extension configuration is absent before/after implementation, so hooks
are skipped. Existing user changes are preserved; no commit created.

## First authored room — T069/T071, partial T078/T079 — 2026-10-09

Setup: Godot 4.7.2 standard, Linux, Compatibility/Jolt, headless fixed 60 Hz with
isolated XDG/save roots. New production chamber/room scenes use the same real components
as the proved greybox; they do not inherit test fixtures. `room-solutions.md` distinguishes
six proposed allocations from room 1's actual solution. The authored test catalogue
contains only room 1; it is not a substitute for T077's complete production catalogue.

Expected: one hazard-created corpse supports repeatable traversal without carrying;
unaided jumps and outer-edge approaches cannot bypass spikes; current-method teaching
changes after first death; one real forward exit crossing completes the room.

Actual: ten fresh one-body solutions/exit completions; ninety empty-room bypass attempts
across three launch positions and centre/both edges; thirty actual ledge/coyote-window
jump measurements all pass. Maximum observed same-height reach is 3.000001 m against a
3.6 m exposed strip. Ten repetitions each of pre-death teaching, post-death body support
teaching and controller prompt updates pass. No corpse was inserted or repositioned by
the solution test. Exact actions/geometry are in `room-solutions.md`.

Verification: `/tmp/omdb-rooms-red.log` fails the missing-authored-catalogue expectation
before authoring (one failed assertion, 2,969 passed). `/tmp/omdb-room01-check.log` passes
3,129 physics assertions after authoring; `/tmp/omdb-room01-final.log` passes **7,206,
zero failed** across state 2,869 / physics 3,159 / recovery 1,178, with clean imports.
The final full run logs the previously observed Jolt shutdown job-capacity warning after
the passing summary; standalone room checks do not. This is not a rendered benchmark.

T069/T071 are complete; T078 is implemented for room 1 but remains open for all six
definitions. T079 remains open for rooms 2–3 and formal playable observations. T072–T077
and subsequent room acceptance are outstanding. Display/controller/native acceptance
is not inferred from the user's authorization or these scripted trials. No tuning
value changed. Requirements checklist remains 16/16 complete; extension hooks absent.

Desktop preparation: `/tmp/omdb-room01-export.log` refreshes both representative
packages; `/tmp/omdb-room01-package.log` passes Windows/macOS PCK smoke on Linux.
These packages still launch the representative menu/greybox flow, not a finished
six-room game. The source launcher in quickstart opens the authored first room.
Current Windows PCK: 503,484 bytes, SHA-256
`9015ca4959d1afbc3a797a8b0bf3b71d0103b6c7864491639b4681e0b7584b70`;
macOS ZIP: 60,048,909 bytes, SHA-256
`80c659c18a9f61d246dbd1da23568f3f1e9cd509347c31857cb092f46da7a1e1`.
Windows executable identity is unchanged from the preceding record. No commit created.

## CAM-01 — Four compass views and exit visibility — 2026-10-09

User-reported defect: the authored room's doorway cannot be seen from its angle. The
user explicitly requests North/South/East/West camera rotation, amending the original
stationary-camera scope. Constitution 1.1.0, PRD, feature spec/plan/controls/data model,
AGENTS and the spec/plan/tasks templates now permit four stationary elevated compass
presets. Free camera orbit remains excluded.

Implementation: preserve the authored default until selection; Q/C and LB/RB cycle
North/East/South/West, with 1/2/3/4 direct keyboard selection. Preserve camera radius,
height and orthographic size. Movement uses the same camera instance's new basis.
Hide only camera-facing perimeter meshes, leaving solid boundaries unchanged. Open
doors now retain a green frame because the earlier open state hid their whole mesh.
HUD shows selected view and current-method controls. Camera selection belongs to the
room, surviving ordinary respawn but resetting with room reconstruction; it is not saved.

Setup: Godot 4.7.2, Linux, Compatibility/Jolt, isolated storage/XDG, fixed 60 Hz headless.
Expected: all four compass positions and corresponding screen movement, constant zoom,
unchanged registry/collision, wrap from West to North and a visible open exit frame.
Actual: ten repetitions of every new assertion pass. Full strict wrapper in
`/tmp/omdb-camera-final.log`: **7,386 passed, zero failed** (physics 3,339 / state 2,869 /
recovery 1,178); 104 clean imports. An initial missing type annotation on the direction
array was corrected before the passing run. The known Jolt job-capacity shutdown warning
appears after the passing summary. No rendered benchmark is claimed.

`/tmp/omdb-camera-export.log` refreshes both representative packages;
`/tmp/omdb-camera-package.log` passes both PCK smoke checks on Linux. Windows PCK:
513,032 bytes, SHA-256 `3f6ef82700c4830f8e6adc1a695865fa5edcbe8996d82d181c82e49b2d0d455e`.
macOS ZIP: 60,051,831 bytes, SHA-256
`c9941e10f2383e408ecddd53d78c0c482f17f10faead098ba6227a9eefd73cce`.
Windows executable identity remains unchanged. T111/T112 complete; T113 rendered
four-view/controller/three-resolution review remains unverified. Checklist 16/16;
extension hooks absent before/after implementation. No commit created.

## Connected authored sequence — 2026-10-09

Scope authorized: the user explicitly requests the remaining rooms and connected
progression after accepting their earlier playtest. This continues development under
their recorded G1/G2 scheduling direction; it does not mark unreported manual checks passed.
Requirements checklist: 16/16 complete. No extension hooks are configured before/after.

Implemented: Rooms 2–6 and their definitions; an exact six-room production catalogue;
normal Title/Continue, live-only forward exits, fresh next rooms, Completion, saved Replay;
contextual keyboard/controller teaching; shared gothic dressing and real metadata/geometry
validation. The authored validation launcher now runs the connected sequence immediately.
Practice/exit plates have distinct captions and required weights. The early Room 4 ledge
proposal was revised to a body-assisted observation shelf with an ordinary return route:
entrance respawn after evicting a mandatory entry support would otherwise strand the clone.
No checkpoint, death quota, new hazard, creation button or cap/tuning change was added.

Setup: Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility/Jolt, Linux headless,
fixed 60 Hz, isolated temporary saves/XDG. Expected: all six intended routes complete
repeatedly within five simultaneous bodies; Room 4 creates six and evicts its unneeded
oldest step; unaided obstacle bypasses fail; recovery reconstructs fresh actual rooms;
only the live forward exit crossing advances and saves; Replay preserves settings.

Actual: all six solutions complete ten consecutive times from fresh scenes. Room 1
uses one body; Room 2 two; Room 3 one; Rooms 4–6 retain five. Room 4 completes with
subject #7 after six real anvil deaths and removal of the first step body. Full solutions
use actual controller motion/jumps, hazard deaths and pickup/placement; no subject/body
teleport, injected corpse or manually changed hazard state is used. Independent diagnostic
trials rebuild the later arrangements ten times with real hazard-created bodies and real
interactions, staging only the subject with contacts disabled across the teleport. Every
bridge is traversed and every actual exit is crossed. Positions/order and tick ranges are
recorded in `room-solutions.md` and emitted per trial as `OMDB_SOLUTION` lines.

Anti-bypass: ninety existing fresh Room 1 launch/edge attempts, thirty prior real ledge
reach measurements, and ten repetitions of each centre/edge attempt against Rooms 2–6
spike/saw/closed-door partitions pass. Additional isolated closed-exit checks cover Rooms
2/4/5/6, including the final offset passage; both combined saws are independently tested
so later obstacles cannot mask their bypass. Reliable lower-body-count alternatives are
allowed. The 8.4 m / 5.2 m combined spike widths were selected after correcting repeatable
lethal far-bank landings, retaining broad standing-jump landings and the unchanged tuning.

Recovery: ten fresh activation/reset trials per actual room; ten repetitions each of
pending death, death feedback, held oldest, jammed saw and pending placement resets in the
authored combined room; restart before/after activation and old epoch/token rejection;
sixty real separate-process reopen checks (six actual IDs × ten) from held/partly solved
arrangements; ten actual-sequence progression/Completion/Replay checks, including retained
volumes and completed saves reopening a fresh Room 6. Fixture regressions also remain.
Lifecycle tests stage arrangements or door state to isolate recovery; they are distinct
from the no-staging physical solution checks.

Before authoring, `/tmp/omdb-sequence-red.log` fails the missing-production-catalogue
expectation (1 failed, 1,178 passed); later physical/packaged failures drove the geometry
and ownership corrections recorded below.

Final strict command:

```sh
python3 scripts/checks/run_checks.py --godot /usr/local/bin/godot --suite all --save-root /tmp/omdb-six-rooms-accepted
```

`/tmp/omdb-six-rooms-accepted.log`: **10,796 passed, zero failed**, state 2,869 / physics
6,049 / recovery 1,878; **124 clean imports**. The strict wrapper accepts the nonempty
summary and rejects engine/script diagnostics. The previously recorded Jolt job-capacity
warning appears only at shutdown after the passing summary; it remains an engine warning,
not a measured runtime benchmark. `/tmp/omdb-room01-metrics.log` separately repeats ten
Room 1 solutions and ninety bypasses to record timing; its 160 assertions pass.

| Affected rules | Repeatable evidence |
| --- | --- |
| FR-004–FR-006, EC-01; one death/replacement, support | State/physics lifecycle, bridge/support, full authored walkthroughs |
| FR-007–FR-012, EC-02/EC-03/EC-08; carry, invalid/assisted placement, carrying death | Carry lifecycle, placement/assistance and real authored deliveries |
| FR-013–FR-016, EC-04–EC-07; FIFO in every role, held count/eligibility | State/physics FIFO-role/contact tests plus Room 4 sixth creation |
| FR-017–FR-022, EC-14/EC-15; plate chains, jams, warned anvil, door closure | Contacts/surplus weight/hazards/anvil/combined-room and isolated bypass tests |
| FR-023–FR-025, EC-13; single live exit, six-room sequence | Exit-crossing, hazard ownership, authored walkthrough and actual-catalogue progression |
| FR-026–FR-030, EC-09–EC-12; restart, save/resume, completion/replay | Authored catalogue/lifecycle, reset/input/activation/save failures, separate-process reopen, actual exit progression |

Resolved defects/setup issues:

- Wider planned strips caused repeatable lethal far-bank landings: corrected geometry
  using physical trials, without changing cap, movement, grace or body dimensions.
- A diagnostic character teleport imparted artificial impulses to props: only the
  diagnostic setup disables contacts across staging; full walkthroughs never teleport.
- Retired/foreign hazard signals could kill a new room's player: ownership/epoch/live
  guards now reject them. `/tmp/omdb-hazard-red.log` fails 20 assertions before the fix;
  `/tmp/omdb-hazard-green.log` passes all 20 afterward, and integrated regressions pass.
- Compiled exports lost nested inherited shape overrides, expanding the Room 2 supply
  sensor across its spawn. Package inspection observed 3.6 × 11.9 instead of 2 × 2.
  Root geometry properties configure shapes/meshes equally in source and export; metadata
  verifies actual floor/spike geometry. Both final packages now start every room fresh.
- The original 45 s whole-suite budget was insufficient for authored trials: bounded
  runner/process limits are now 180/240 s. Strict test IDs were corrected to contain no
  whitespace; an untyped conditional test array was corrected. The wrapper rejected both
  invalid runs despite passing assertions elsewhere. `check_harness.py` was updated and
  its copy filter corrected: ignoring every directory named `art` also removed runtime
  `scenes/art`, causing unrelated import failures in the earlier negative runs. A valid
  temporary-project positive control now must pass before the 12 fault/unsafe-root/timeout
  cases run. The final positive control passes and all 12 injected faults/unsafe inputs/
  timeouts are rejected in `/tmp/omdb-connected-harness-final.log`; empty-suite and
  watchdog cases have their specific expected diagnostics. The earlier
  `/tmp/omdb-connected-harness.log` is not accepted as fault-specific evidence. No fault
  injection remains in the working project.

Desktop preparation: `export_fixture.py --production` creates the actual main-scene
Windows EXE/PCK/ZIP and macOS Universal 2 ZIP, excluding all tests/check scripts/source
art. `/tmp/omdb-connected-candidate-export.log` succeeds;
`/tmp/omdb-connected-candidate-package.log` passes both PCK smoke checks from empty source
directories using Linux Godot. Checks include six actual definitions/geometries, menus,
settings/mute, fresh activation/Continue, Completion and saved Replay. Exact hashes and
native status are in `release.md` and `builds/game-manifest.json`.

T068/T072–T081/T090/T093/T097 are complete. Human rendered three-resolution/four-view
review, controller feel, full manual flow, first-time duration/cue recognition, native
Windows/macOS input matrix, signing/download behavior and target performance remain
**UNVERIFIED** (including T082/T083/T091/T095/T098–T105/T113 and earlier human gates).
Scripted active timing is not the 20–30 minute first-playthrough measurement. No commit
or publication was performed. Requested room/progression implementation is complete;
overall release readiness is not claimed.

## CAM-02 — Preserve isometric perspective while rotating — 2026-10-09

User correction: cardinal-axis presets changed the intended isometric perspective.
All selections now rotate the authored camera transform in 90° yaw steps between
South-east, South-west, North-west and North-east. The initial view is South-east;
Q/C and LB/RB immediately rotate to adjacent corners, and 1–4 select those corners.
The original basis is rotated intact, preserving pitch, elevation, distance,
orthographic projection and zoom. Both camera-facing perimeter meshes cut away while
every solid boundary remains active. HUD and governing/dependent artifacts agree.

Setup: Godot 4.7.2, headless fixed 60 FPS, isolated `/tmp/omdb-isometric-check` saves;
`run_checks.py --godot /usr/local/bin/godot --suite physics --save-root
/tmp/omdb-isometric-check`. Log: `/tmp/omdb-isometric-check.log`.
Expected: ten trials in each of the six actual rooms, four independent diagonal
position expectations, direct input selection, immediate ±90° cycling from startup,
wrap-around, invariant camera pitch/elevation/distance/projection/zoom, screen-relative
movement, visible exit frames and unchanged puzzle state/solid collision.
Actual: 124 imported scripts/resources checked with zero failures; **9,289 physics
assertions passed, zero failed**, including the expanded camera regression. T114 is
complete. Prior CAM-01 cardinal labels/default-until-selection behavior is superseded.
Rendered three-resolution readability, physical-controller feel and native platform
acceptance remain **UNVERIFIED** under T113 and existing review tasks.
Local production Windows/macOS archives were refreshed successfully in
`/tmp/omdb-isometric-export.log`; both exported PCK smoke checks passed using Linux Godot
in `/tmp/omdb-isometric-package.log`. Current hashes are in `release.md` and
`builds/game-manifest.json`. These are not native platform or rendered-camera checks.

## JUMP-01 — Jump aiming and surface reference — 2026-10-09

Playtest finding: the user reports difficulty aiming jumps precisely after accepting
the isometric camera correction. Improve air correction/release braking and depth cues
under FR-003; preserve manual jumping and the authored puzzle routes.

Setup: Godot 4.7.2, 60 Hz fixed-step headless physics, isolated temporary saves.
`run_checks.py --godot /usr/local/bin/godot --suite physics --save-root
/tmp/omdb-jump-aim`; log `/tmp/omdb-jump-aim.log`. Ten repeats per isometric view use
real ground acceleration and queued jumps, then release or reverse input in flight.
Expected: stop within 0.18 m after release at full speed; reverse direction within
eight physics frames; footprint follows ground/body support, disappears on landing
and never adds collision. Existing room solutions, support and hazard-bypass checks
must pass. Jump speed/gravity/top speed remain 6/20/4.5 in metre/second units.

Actual: 125 scripts/resources import cleanly; **9,529 physics assertions pass, zero
failures**, including all existing authored walkthroughs, bridges/stacks and bypass
checks. Maximum coyote-inclusive reach is 3.000000715 m (unchanged). Air acceleration
42 m/s² and braking 60 m/s² stop within 0.133334 m in all four views. A yellow,
unshaded, non-colliding ring supplements the ground shadow while airborne; it marks
the current surface under the feet, not a predicted landing trajectory. Room 1 teaching
and quickstart explain release-to-brake and the ring.

Expanded focused support checks: `/tmp/omdb-jump-focused.gd` runs only the jump aiming
regression. `/tmp/omdb-jump-focused.log` passes **320 assertions**, including ring height
on real solid corpses and ignoring disabled corpse support. An isolated legacy-response
comparison retains the tuning resource and sets both air rates to the prior 24 m/s²
without modifying project files: `/tmp/omdb-jump-baseline.log` fails the 80 braking/
reversal assertions as expected, measuring 0.36 m travel over eight frames with residual
velocity. An initial comparison did not retain the modified resource and therefore
measured new tuning; that run is superseded by this corrected comparison.

T115 implementation/automated checks complete. The user reports that the yellow ring
works well enough as an indicator. Device, input method and resolution were not recorded,
so broader keyboard/controller feel, readability at all three resolutions and manual
body-bridge landing checks remain **UNVERIFIED**. Automated response improvement and this
single indicator confirmation do not establish full usability acceptance. Native
acceptance remains open. Export/package evidence and current artifact hashes are recorded
in `release.md`.
