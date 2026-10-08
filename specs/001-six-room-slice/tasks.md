---
description: "Dependency-ordered implementation and validation tasks for the six-room slice"
---

# Tasks: Six-Room Puzzle Slice

**Input**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), and [quickstart.md](quickstart.md).
**Governing documents**: [constitution](../../.specify/memory/constitution.md) and [PRD](../../PRD.md).
**Date**: 2026-10-08. All tasks start uncompleted; document generation proves no gameplay behavior.

**Verification**: Spec VR-001–VR-008 explicitly require regression, playable, asset,
recovery, native-platform, and first-time-player checks. Define automated expectations
before implementing missing behavior and demonstrate a meaningful failing case first.
Import errors alone are not a useful failing behavioral test. Use minimal explicit
unimplemented interfaces where needed; never substitute passing fixtures or empty suites.
Run playable checks after integration. Every verification task records setup, build,
hardware/input, requirement/scenario IDs, actions, expected and actual outcomes, repetitions,
metrics, and defects in `specs/001-six-room-slice/validation.md`.

## Format and Path Conventions

- Tasks use `- [ ] Tnnn [P?] [USn?] Description with exact file paths`.
- `[P]` means the task belongs to an explicitly listed batch with different writable files.
  Its prerequisites must already be satisfied; it does not mean all marked tasks can run together.
- Story labels retain the specification's numbering. US6 precedes US5 because both are
  P2 and room production benefits from complete controls and recovery.
- Paths are relative to the repository root. Additional named test/helper files below
  refine the plan's layout without adding runtime dependencies.
- The default order is numerical. The dependency section identifies work that can continue
  if graphical/native validation is unavailable. Never check off an unperformed check.
- Each affected state scenario requires **at least ten repetitions** (VR-001/VR-005).
  Every bridge/stack and intended room solution requires **ten consecutive fresh rebuilds
  and traversals** (VR-002). A change invalidates affected earlier evidence until rechecked.

## Phase 1: Setup — Shared Infrastructure

**Purpose**: Establish the pinned project, inputs, tuning, source assets, and evidence format.

- [ ] T001 Initialize the Godot project and planned directories with `project.godot`, a minimal `scenes/main.tscn`, `.godot-version`, and `.gitignore`; pin Godot 4.7.2, Compatibility rendering, built-in Jolt, 60 Hz main-thread physics, and the contract's collision layers; ignore `.godot/`, `builds/`, and temporary test output.
- [ ] T002 [P] Configure the exact keyboard/controller InputMap actions and 0.2 initial stick deadzone in `project.godot` from `specs/001-six-room-slice/contracts/player-interface.md`, including restart and complete UI navigation without a mouse (FR-003, FR-026, FR-031–FR-032).
- [ ] T003 [P] Define `scripts/state/gameplay_tuning.gd` and `resources/gameplay_tuning.tres` with all research R8 starting values for movement, forgiveness, body dimensions, placement, camera, timing, and budgets; keep these labelled as unmeasured defaults until playable evidence exists.
- [ ] T004 [P] Copy the three selected cow files from the exact source paths in research R5 into `assets/characters/cow/cow.glb`, `art/characters/cow/cow.blend`, and `art/characters/cow/cow-rigged.blend`; add `art/.gdignore` and `assets/characters/cow/SOURCE.md` with provenance and recomputed hashes, retaining the source project unchanged.
- [ ] T005 [P] Create `specs/001-six-room-slice/validation.md` with scenario/trial records, defects, tuning history, greybox/asset gates, six-room solutions, four native input combinations, performance, and first-time playtest sections; link reproducible procedures in `specs/001-six-room-slice/quickstart.md` and mark all unrun checks unverified (VR-001–VR-008).

## Phase 2: Foundational — Blocking Prerequisites

**Purpose**: Establish ownership and a test harness before implementing gameplay rules.

- [ ] T006 Build `tests/run_tests.gd` with `state`, `physics`, `recovery`, and `all` suites, per-case counts, bounded waits, and a final nonempty `OMDB_TEST_RESULT`; parse user arguments after `--`, reject the production save root, and inject the absolute test root through `scripts/app/save_paths.gd` before any game save access; missing cases, assertions, or fixtures must fail.
- [ ] T007 Implement `scripts/checks/run_checks.py` using Python 3.12 standard library only; import-check the project, invoke T006, capture engine/script errors, enforce a process timeout, require the final passing summary and nonempty requested suites, and return nonzero on any failure even when Godot exits zero.
- [ ] T008 [P] Define shared identity/value types and explicit interfaces in `scripts/state/room_state.gd`, `scripts/state/corpse_registry.gd`, and `scripts/rooms/room_definition.gd`: epoch/subject/body identities, lifecycle modes, immutable creation age, room metadata, and command/result shapes from `specs/001-six-room-slice/data-model.md`; leave story behavior for its tests and implementation below.
- [ ] T009 [P] Build reusable floor, walls, safe spawn, fixed orthographic camera, and configurable support surfaces in `tests/scenes/physics_fixture.tscn` and `tests/scenes/greybox_validation.tscn`; add isolated launch wiring in `scripts/checks/validation_context.gd`, using the tuning resource and no saved seventh progression room.
- [ ] T010 Establish the persistent Game/RoomHost composition in `scripts/app/game.gd` and `scenes/main.tscn`, and the sole room mutation boundary in `scripts/rooms/room_controller.gd`; define epoch-tagged event handling, deferred physics commits before subsequent player movement, and explicit component signals without global state ownership or a global event bus.
- [ ] T011 Exercise the runner and wrapper with empty/missing suites, an intentional assertion failure, import/script errors, a missing summary, a watchdog timeout, and an unsafe save root; record the actual nonzero outcomes and exact reproduction commands in `specs/001-six-room-slice/validation.md` and `specs/001-six-room-slice/quickstart.md`, then remove intentional fault injections.

**Checkpoint**: Clean imports, explicit ownership/interfaces, and a harness that rejects
false success. All story work depends on this foundation; no playable gate is passed yet.

## Phase 3: US1 — Turn Death into a Traversable Route (P1, MVP)

**Goal**: Move and jump from the fixed view, die once per lethal event, and use the resulting
solid body to cross spikes with unlimited retries.

**Independent test**: In the isolated greybox, a fresh subject dies on spikes, exactly one
body and replacement appear, previous puzzle state survives, and the rebuilt corpse route
supports ten consecutive traversals. Exercise screen directions and landings with each input.

### Verification definitions

- [ ] T012 [P] [US1] Add creation-order, cap, duplicate-lethal-contact, replacement-latch, stale-subject, and repeated-death cases in `tests/state/test_registry.gd` and `tests/state/test_lifecycle.gd`, with ten repetitions each and persistent-room-state assertions (US1/AS2, AS4; FR-004–FR-006, FR-013; EC-01–EC-02; VR-001).
- [ ] T013 [P] [US1] Add real-frame support and spike cases in `tests/physics/test_support.gd`: floor/body support, a body-supported spike crossing, lethal exposed contact, existing-body survival, and physical settling after support removal; assert invariants/tolerances rather than identical cross-platform transforms (US1/AS3; EC-06, EC-08, EC-14; VR-001–VR-002).
- [ ] T014 [P] [US1] Add camera-ground-basis tests in `tests/state/test_movement.gd` for all four screen directions, normalized diagonals, preserved analog magnitude, and a single buffered jump rather than key-echo repetition (US1/AS1; FR-003; player-interface contract).

### Implementation and playable verification

- [ ] T015 [US1] Implement `scripts/state/corpse_registry.gd` and `scripts/state/room_state.gd` creation/death transactions: unique epoch-qualified IDs, immutable creation order, five-body capacity with eviction before a sixth active insertion, one accepted death per subject, one pending replacement, and unchanged unrelated room state; make T012 pass.
- [ ] T016 [P] [US1] Create `scenes/corpses/corpse.tscn` and `scripts/corpses/corpse.gd` with one rotation-locked translating RigidBody3D box, research R8 mass/friction/damping, hazard immunity, ordinary sleep plus support-removal wake-up, and a separate collapsed cow visual that never drives collision transforms.
- [ ] T017 [P] [US1] Implement `scenes/player/player.tscn` and `scripts/player/player_controller.gd` with CharacterBody3D motion, projected camera-relative input, jump buffer/coyote time/floor snap, retained facing, ground shadow, and no deliberate corpse push or platform launch impulse; make T014 pass.
- [ ] T018 [P] [US1] Implement `scenes/hazards/spike_bed.tscn` and `scripts/hazards/spike_bed.gd` with a solid corpse-supporting bed and shallow live-player lethal volume; report identity-tagged contacts to the room owner without spawning or freeing actors directly.
- [ ] T019 [US1] Integrate accepted death, safe-boundary corpse creation/eviction, immediate loss of dead-player collision, and the epoch-checked replacement countdown in `scripts/rooms/room_controller.gd`; place the body at death, respawn one clone at the safe entrance, preserve other state, and allow unlimited retries (FR-004–FR-006).
- [ ] T020 [US1] Add `scripts/player/character_visual.gd` and `assets/characters/cow/presentation.tres` for movement, jump, hurt/death, and a flat corpse pose; wire `scenes/player/player.tscn` and `scenes/corpses/corpse.tscn` so all squash/pose changes affect visuals only, documenting missing imported animation coverage in `assets/characters/cow/SOURCE.md`.
- [ ] T021 [US1] Compose the actual player/corpse/spike components in `tests/scenes/greybox_validation.tscn`; provide a safe entrance, broad body-assisted crossing, cutaway foreground walls, and stationary whole-room framing, with exposed geometry that cannot be bypassed by an unaided jump or walking around it.
- [ ] T022 [US1] Implement the initial state-snapshot HUD in `scripts/ui/hud.gd` and `scenes/ui/hud.tscn`, showing body count, actual oldest body, zero-body clearing, and subject/death feedback without a failure limit; connect it through `scripts/rooms/room_controller.gd`.
- [ ] T023 [US1] Run T012–T014 and the greybox death/support trials, recording ten repetitions per state scenario and ten fresh bridge traversals in `specs/001-six-room-slice/validation.md`; time the available death cases now and retain the full twenty-trial mixed-hazard/held-death requirement for T043 (VR-001–VR-003; SC-003–SC-005).
- [ ] T024 [US1] Measure maximum unaided jump reach including forgiveness, inspect shadow/landing clarity and four-direction movement with keyboard and controller, and check 1920×1080, 1280×800, and 1024×768 framing; record observations and any revised `resources/gameplay_tuning.tres` values in `specs/001-six-room-slice/validation.md`, rerunning affected T023 checks after tuning.

**Checkpoint**: US1 is the playable MVP once its checks pass. It does not establish the
complete greybox/character gate or release readiness.

## Phase 4: US2 — Carry and Place Bodies Deliberately (P1)

**Goal**: Carry one body and place it at a trustworthy nearby ghost on floors, spikes, or
other bodies, including using direct plate weight to hold a door open.

**Independent test**: Prepare bodies and valid/invalid surfaces in the greybox. Every
valid ghost produces the shown pose/contact, invalid releases preserve the held body,
and death while carrying releases the existing body and adds exactly one new body under the cap.

### Verification definitions

- [ ] T025 [P] [US2] Extend `tests/state/test_registry.gd` and `tests/state/test_lifecycle.gd` for single-body pickup, unsuccessful pickup with unchanged state, retained age/count, held ineligibility, and death while carrying both the oldest and a newer body at capacity (US2/AS1, AS5; EC-03–EC-05; VR-001).
- [ ] T026 [P] [US2] Add `tests/physics/test_placement.gd` cases for floor/body/spike supports, player/wall/body overlap, out-of-reach and blocked paths, missing/unstable support, and a preview made stale before release; request ten attempts per valid surface and rejection category with unchanged held state on failure (US2/AS2–AS3; SC-006).
- [ ] T027 [P] [US2] Add direct-support contributor and linked-door cases in `tests/state/test_contacts.gd`: player/released-body units, held-body exclusion, no indirect stacked weight, threshold changes, contributor removal, and safe entry-side closure while occupied (US2/AS4; FR-020–FR-021; EC-06–EC-07, EC-15).

### Implementation and playable verification

- [ ] T028 [P] [US2] Implement `scripts/player/placement_evaluator.gd` using physics-step support probes, full-box endpoint overlap, reach and unobstructed path checks; return a single pose/reason result for both ghost and commit, excluding only the held body's own collider and using research R4/R8 support tolerances.
- [ ] T029 [P] [US2] Implement `scripts/puzzle/pressure_plate.gd`, `scenes/puzzle/pressure_plate.tscn`, `scripts/puzzle/exit_door.gd`, and `scenes/puzzle/exit_door.tscn`; count unique direct supports, expose current/required weight, open exactly at threshold, and reserve safe entry-side retreat anchors so closure cannot kill, trap, or carry the player through the blocked exit.
- [ ] T030 [US2] Implement pickup and release transactions across `scripts/rooms/room_controller.gd`, `scripts/state/corpse_registry.gd`, `scripts/corpses/corpse.gd`, and `scripts/player/player_controller.gd`: reachable nearest pickup, one held identity, frozen world physics with disabled shape/layer/mask, immediate contributor removal, and release-time revalidation followed by restored simulation at the accepted pose.
- [ ] T031 [US2] Add the non-colliding carry visual, adapted carry pose, and valid/invalid ghost to `scenes/player/player.tscn` and `scripts/player/character_visual.gd`; expose outline/icon plus colour and invalid-reason feedback through `scripts/ui/hud.gd`, keeping the carried body's registry identity unchanged.
- [ ] T032 [US2] Extend death handling in `scripts/rooms/room_controller.gd` with the contract's nonpenetrating held-body release search, reserved new-corpse space, capacity eviction, and cleared carry ownership before replacement; preserve the released held body unless creation-order eviction legitimately removes it.
- [ ] T033 [US2] Add floor, corpse, and spike placement stations plus plate/door geometry to `tests/scenes/greybox_validation.tscn`; protect retreat/spawn space from placement, provide death-while-carrying clearance, and reconcile post-commit contacts without relying on a just-teleported Area3D overlap cache.
- [ ] T034 [US2] Run state and physics suites for T025–T027 with at least ten repetitions per case, including collision-layer restoration and immediate loss of support/weight; record actual results and defects in `specs/001-six-room-slice/validation.md` (VR-001; SC-004, SC-006).
- [ ] T035 [US2] Perform keyboard and controller placement trials with ten valid attempts on each of floor/body/spikes and ten invalid attempts per rejection category; confirm the displayed ghost matches the committed result and record exact setups in `specs/001-six-room-slice/quickstart.md` and outcomes in `specs/001-six-room-slice/validation.md` (VR-003; SC-006).
- [ ] T036 [US2] Rebuild and traverse each added stack/bridge ten consecutive times, remove support and verify settling, and exercise held-body death with both oldest/newer identities; record pose/support observations, cap/carry outcomes, and required fixes in `specs/001-six-room-slice/validation.md` (VR-001–VR-003; EC-04, EC-06).

**Checkpoint**: US2 is independently testable on the prepared greybox after US1. Plate and
safe-door foundations are implemented here because deliberate placement already uses them.

## Phase 5: US3 — Allocate Five Bodies Across Hazards (P1)

**Goal**: Make FIFO eviction predictable across held/support/plate/saw roles, combine
multiple direct contributors correctly, and introduce a visibly warned anvil.

**Independent test**: Prepare five bodies across a held slot, stack, plate, and jam point.
The sixth creation removes the indicated oldest and updates all effects; extra eligible
contributors remain effective. Test exposed and protected hazard routes and repeat anvil drops.

### Core verification definitions and implementation

- [ ] T037 [P] [US3] Extend `tests/state/test_registry.gd` and `tests/state/test_lifecycle.gd` with eviction in every body role, pickup/release without reordering, visible-snapshot agreement, held-oldest clearing, and rapid deaths at capacity (US3/AS1–AS2, AS6; EC-02–EC-06; VR-001).
- [ ] T038 [P] [US3] Extend `tests/state/test_contacts.gd` and add `tests/physics/test_hazards.gd` for indefinite and multiple-body saw jams, removal of one versus the final contributor, surplus plate weight, exposed contact after reactivation, traversable jammed routes, and occupied-door closure (US3/AS3–AS4; EC-07, EC-14–EC-15).
- [ ] T039 [US3] Implement `scripts/hazards/buzzsaw.gd` and `scenes/hazards/buzzsaw.tscn` with a released-body ID set, no jam timeout, active-only live-player lethality, a safely reachable jam point, and visibly distinct running/jammed states that allow traversal of the designated stopped route.
- [ ] T040 [US3] Complete explicit eligibility invalidation in `scripts/rooms/room_controller.gd`, `scripts/puzzle/pressure_plate.gd`, and `scripts/hazards/buzzsaw.gd`; atomically clear removed/held IDs, recompute remaining contributors and doors, wake unsupported bodies, and reject stale epochs before subsequent player movement can use obsolete state.
- [ ] T041 [US3] Complete oldest-body feedback for held and released bodies in `scripts/ui/hud.gd` and `scenes/ui/hud.tscn`; add a visible non-colliding eviction burst in `scenes/effects/eviction_burst.tscn` and `scripts/effects/eviction_burst.gd`, with zero collision and no contribution to body count, support, or contacts (FR-014–FR-016).
- [ ] T042 [US3] Integrate saw routes, single/multi-unit plate stations, cap-role arrangements, and all live/corpse hazard feedback in `tests/scenes/greybox_validation.tscn`; use the actual reused character and the same room components as production, with no special physics shortcuts.
- [ ] T043 [US3] Run the core state/physics scenarios ten times each, including EC-01–EC-07 and EC-14–EC-15, and measure twenty active-play deaths including overlapping hazards and both held-body age cases; require one corpse/replacement, count ≤5, no stale effects, and control restored within two seconds in every timed trial, recording results in `specs/001-six-room-slice/validation.md` (VR-001; SC-004–SC-006).
- [ ] T044 [US3] Record the Stage 1 gate in `specs/001-six-room-slice/validation.md`: demonstrate all VR-003 interactions together with keyboard and controller, and inspect cow materials/scale, movement/jump/carry/death, corpse silhouette/support agreement, framing, and performance observations with one player plus five bodies (VR-004; SC-009); resolve observed gaps, update measured tuning/provenance, and rerun affected checks before marking this gate passed.

### Complete the remaining hazard system

- [ ] T045 [US3] Extend `tests/physics/test_hazards.gd` with warned/repeating anvil cycles, player death under impact, spike/saw/anvil corpse immunity, and stable existing-body arrangements after impact, each repeated ten times (US3/AS5; EC-08; VR-001).
- [ ] T046 [US3] Implement `scripts/hazards/anvil.gd` and `scenes/hazards/anvil.tscn` with an initially one-second visual warning and three-second cycle, epoch-aware cancellation, visual impact animation, and a live-player kill area that applies no destructive impulse to corpse props.
- [ ] T047 [US3] Extend `tests/scenes/physics_fixture.tscn` with anvil timing, corpse-immunity, surplus-weight, multi-jam, and protected door-retreat setups, and reproduce these interactions in `tests/scenes/greybox_validation.tscn` for normal-camera review with audio muted.
- [ ] T048 [US3] Run the complete hazard/contact regressions and playable warning, jam, support-removal, and door-closure checks, at least ten repetitions per applicable scenario; record outcomes and defects in `specs/001-six-room-slice/validation.md` (US3/AS1–AS6; VR-001; EC-01–EC-08, EC-14–EC-15).

**Checkpoint**: US3 systems pass their own tests. **Full room production remains blocked
until T044 has actual passing VR-003/VR-004 evidence.** If graphics/controllers are
unavailable, isolated anvil, recovery, and menu implementation can continue; the gate stays unverified.

## Phase 6: US4 — Recover and Resume a Puzzle (P2)

**Goal**: Restart a completely fresh active room and reopen the saved room fresh while
preserving independently valid settings, even after interrupted actions or invalid saves.

**Independent test**: Use a temporary save root and recovery catalogue fixtures to restart
mid-death/carry/transition and reopen partially solved rooms. Compare with fresh-entry state:
one player, zero bodies/carry/queue, initial machinery, correct room and settings.

### Verification definitions

- [ ] T049 [P] [US4] Add `tests/recovery/test_save_store.gd` for all six allowed IDs, missing/corrupt/unreadable/out-of-range/unsupported-schema documents, unknown fields, independently valid settings, per-field defaults, finite numeric clamping and rejected bool/string/NaN/infinity values, temporary-write/rename failures, and absence of production-root access (save-format contract; US4/AS2–AS4; EC-11–EC-12).
- [ ] T050 [P] [US4] Add `tests/recovery/test_room_reset.gd` for restart during death feedback, held-oldest carry, jams, placement, and both sides of activation commit; assert epoch cancellation, reset/departure priority, fresh-state equivalence, one active room/player, and no stale bodies/contacts/timers after delayed callbacks (US4/AS1, AS5; EC-09–EC-10; VR-005).

### Implementation and playable verification

- [ ] T051 [US4] Implement `scripts/app/save_store.gd` using separate version-1 `progress.cfg` and `settings.cfg` documents beneath the injected root, exact contract validation/fallback rules, checked sibling-temp writes and replacement without deleting the valid destination first, independent failure results, and no eager overwrite after malformed reads.
- [ ] T052 [US4] Implement whole-room retirement/reconstruction and monotonic epochs in `scripts/app/game.gd` and `scripts/rooms/room_controller.gd`; make restart target the currently committed room, cancel old callbacks/feedback, dispose the old instance, and restore one fresh player with zero corpses/carry and original puzzle state.
- [ ] T053 [US4] Add `tests/scenes/recovery_room.tscn` and `tests/scenes/recovery_catalogue.tres` with isolated valid-ID test definitions; implement candidate initialization, validated catalogue lookup, one-shot activation commit, and save-after-success in `scripts/app/game.gd`, retaining prior valid progress if candidate activation fails.
- [ ] T054 [US4] Wire fresh saved-room startup, independent settings loading, temporary-root arguments, and failure notifications into `scripts/app/game.gd` and `scenes/main.tscn`; save only room ID/volumes, preserve them through ordinary death/restart, and never serialize body or machinery state.
- [ ] T055 [US4] Route keyboard/controller restart intents through `scripts/player/player_controller.gd` and `scripts/rooms/room_controller.gd`, including during death feedback; verify consumed/stale action intents cannot mutate the replacement room and expose restart feedback in `scripts/ui/hud.gd` (FR-026).
- [ ] T056 [US4] Run the recovery suite with ten repetitions per US4 scenario and applicable EC-09–EC-12 cases, including real process reopen against disposable roots, checked write failures, and fresh-state comparison for each valid test room ID; record outcomes in `specs/001-six-room-slice/validation.md` (VR-005; SC-004).
- [ ] T057 [US4] Perform the same recovery actions in the playable fixture, including held-oldest restart and partly solved reopen, and document exact reproduction steps in `specs/001-six-room-slice/quickstart.md` with actual room/player/body/carry/hazard/settings results in `specs/001-six-room-slice/validation.md`; leave authored-room/completion coverage for T081 and native coverage for T098–T101.

**Checkpoint**: US4 works independently through the recovery fixtures. No fixture is a
production room or evidence that all six authored rooms already work.

## Phase 7: US6 — Play the Entire Slice with Either Input Method (P2)

**Goal**: Complete every game/menu operation without a mouse, with clear focus/prompts and
independent persistent music/SFX controls. This P2 story supplies the flow used to test US5.

**Independent test**: From the representative fixture, use keyboard alone and controller
alone to exercise Title, play, Pause, Restart, Settings, Completion, Replay, and Quit.
Fixtures may invoke the final-room completion event; native six-room acceptance follows later.

### Verification definitions

- [ ] T058 [P] [US6] Add `tests/state/test_input_flow.gd` covering UI focus entry/restore, menu-event consumption, blocked gameplay while paused, paused feedback timers, controller disconnect/window-focus pause, reconnection focus, last-active-method prompts, deadzone noise, and keyboard/controller action parity (US6/AS1–AS2; player-interface contract).
- [ ] T059 [P] [US6] Add `tests/recovery/test_audio_settings.gd` for independent live volume changes/mute, defaults, save failures, and retention through restart, replay, Quit to Title, and process reopen using the isolated root (US6/AS3; FR-033; SC-010).

### Implementation and playable verification

- [ ] T060 [P] [US6] Add `default_bus_layout.tres` and `scripts/app/audio_controller.gd` with separate Music/SFX buses, normalized volume mapping, explicit mute at zero, defaults 0.7/0.9, and audible preview sources so both controls can be evaluated before final audio production.
- [ ] T061 [P] [US6] Implement `scripts/ui/menu_controller.gd` and `scenes/ui/title.tscn`, `scenes/ui/pause.tscn`, `scenes/ui/settings.tscn`, and `scenes/ui/completion.tscn` with the contract's operations, visible focus, explicit navigation, initial/restored focus, and no hover dependency.
- [ ] T062 [US6] Implement current-input prompts/generic controller glyph fallback in `scripts/ui/input_prompts.gd` and `scenes/ui/hud.tscn`; connect active-method detection and controller/window-focus events through `scripts/player/player_controller.gd`, ignoring incidental stick noise and preserving usable focus after reconnection.
- [ ] T063 [US6] Wire MENU/PLAYING/PAUSED/SWITCHING/COMPLETE/EXITING flows in `scripts/app/game.gd` and `scenes/main.tscn`; consume menu-opening events, freeze room simulation/countdowns while UI remains active, support fresh Continue/Quit-to-Title, keep completion saved at room 6, and have Replay activate/save room 1 with settings retained.
- [ ] T064 [US6] Bind Settings controls to `scripts/app/audio_controller.gd` and `scripts/app/save_store.gd` through `scripts/ui/menu_controller.gd`; apply changes audibly, show values/mute, persist on leaving settings/quitting, and surface save failures without blocking play or falsely claiming success.
- [ ] T065 [US6] Run input/settings regressions and the representative full menu/play/restart/reopen/completion/replay flow separately with keyboard and a physical controller, including ten relevant settings/recovery repetitions; record Stage 2 results in `specs/001-six-room-slice/validation.md` (VR-005; US6/AS1–AS3; SC-010), keeping native six-room acceptance unverified until T098–T101.
- [ ] T066 [US6] Configure `export_presets.cfg` with exact `Windows Desktop` x86_64 and `macOS` Universal 2 presets, excluding source art and the automated test runner while allowing the representative fixture for this early build; obtain matching Godot 4.7.2 export templates and record reproducible setup and any unavailable prerequisites in `specs/001-six-room-slice/quickstart.md`.
- [ ] T067 [US6] Export the representative Game/menu flow using `tests/scenes/greybox_validation.tscn` as its playable test room to `builds/windows/over-my-dead-body.exe` and `builds/macos/over-my-dead-body.zip`, retaining a required Windows PCK; record temporary fixture wiring, export outcomes, and available native smoke checks in `specs/001-six-room-slice/validation.md`, restoring normal project wiring afterward and retaining missing native runs as unverified release work.

**Checkpoint**: The representative flow passes with both input methods. Export/native
availability does not substitute for T065's playable controls check and does not pass VR-006.

## Phase 8: US5 — Learn and Complete Six Experiments (P2)

**Goal**: Author the six teaching rooms, ensure a repeatable solution under the cap for
each, and advance only through live-player open exits to Completion and Replay.

**Hard entry gate**: T044 and T065 must have passing playable evidence; US3 hazard and
US4 recovery checks must pass. Native release tests may still be outstanding. The six
room tasks cannot be started merely because the greybox files exist.

**Independent test**: From fresh room 1, learn each rule before combining it, solve each
room within five simultaneous bodies, reach Completion, and Replay into a fresh saved
room 1 with settings retained. Each recorded solution and support arrangement passes ten trials.

### Verification definitions

- [ ] T068 [P] [US5] Extend `tests/state/test_lifecycle.gd` and `tests/recovery/test_room_reset.gd` for closed/corpse/dead exits, duplicate boundary events, simultaneous death versus exit, restart before/after activation, six valid authored-room resumes, completion reopening room 6, and Replay saving room 1 with retained settings (US5/AS3–AS5; FR-023, FR-027–FR-030; EC-09–EC-13).
- [ ] T069 [P] [US5] Create `specs/001-six-room-slice/room-solutions.md` with proposed actions, body order/peak count, bridge/stack setups, anti-bypass cases, and the plan's six room budgets; define catalogue-driven solution/support checks in `tests/physics/test_room_solutions.gd` before room authoring, keeping proposed solutions distinct from actual playable results (VR-002; SC-001, SC-003).

### Implementation and playable verification

- [ ] T070 [US5] Connect `scripts/puzzle/exit_door.gd`, `scripts/rooms/room_controller.gd`, and `scripts/app/game.gd` so only a current live subject crossing an open exit can latch one transition; enforce reset/departure then death then exit then interaction priority, save only successfully activated rooms, and route the sixth exit to Completion.
- [ ] T071 [P] [US5] Author `scenes/rooms/room_01.tscn` and `resources/rooms/room_01.tres` for one sacrifice and body-assisted spike traversal without carrying; use measured unaided jump reach to prevent bypasses, a broad remaining landing, and a one-body intended solution.
- [ ] T072 [P] [US5] Author `scenes/rooms/room_02.tscn` and `resources/rooms/room_02.tres` for pickup/preview/placement and a separated plate-held exit; teach single contribution and multi-unit requirements before later combinations, with space for direct contributors and a solution using at most two bodies.
- [ ] T073 [P] [US5] Author `scenes/rooms/room_03.tscn` and `resources/rooms/room_03.tres` for a one-body persistent saw jam, safe retrieval to demonstrate reactivation, and re-jamming to cross; make both hazard states readable and block floor walk-arounds.
- [ ] T074 [P] [US5] Author `scenes/rooms/room_04.tscn` and `resources/rooms/room_04.tres` with a visible early support body and one-way ledge, warned anvil supply, two direct plate bodies, and a three-body spike route; the intended sixth creation evicts the unneeded entry body while count stays at five, without an invisible death quota.
- [ ] T075 [P] [US5] Author `scenes/rooms/room_05.tscn` and `resources/rooms/room_05.tres` around two bridge/step bodies, two direct plate bodies, and one saw-jam body; combine taught rules with broad landings, death/carry clearance, and no precision or timed-jump requirement.
- [ ] T076 [P] [US5] Author `scenes/rooms/room_06.tscn` and `resources/rooms/room_06.tres` with the same five-body allocation across a distinct final route and warned anvil area; introduce no new mechanic, keep the entire puzzle visible, and designate the final exit for Completion.
- [ ] T077 [US5] Populate and validate `resources/room_catalogue.tres` with exactly the six authored definitions, stable room IDs/next links, valid entrances/camera frames/plate-door links, and initial hazard states; wire it into `scenes/main.tscn` and reject fixture or arbitrary-path progression entries through `scripts/rooms/room_definition.gd`.
- [ ] T078 [US5] Implement contextual teaching in `scripts/ui/onboarding.gd` and the six `resources/rooms/room_01.tres` through `resources/rooms/room_06.tres` definitions; show current-method controls and explain each interaction before a required combination, retaining movement and unobscured puzzle decisions (FR-025, FR-032).
- [ ] T079 [US5] Complete rooms 1–3 from fresh state ten consecutive times each and independently rebuild/traverse every intended support arrangement ten times; record actual actions, poses, body order, peak count, time, and bypass attempts in `specs/001-six-room-slice/room-solutions.md` and results/defects in `specs/001-six-room-slice/validation.md` (VR-002; SC-001, SC-003).
- [ ] T080 [US5] Apply the same ten-trial room and support checks to rooms 4–6, including six total creations but at most five retained bodies in room 4 and each combined allocation; correct geometry within the existing cap and rerun failed trials, recording results in `specs/001-six-room-slice/room-solutions.md` and `specs/001-six-room-slice/validation.md`.
- [ ] T081 [US5] Run T068 and the recovery suite against the actual six-room catalogue, with ten repetitions per applicable US4/EC-09–EC-13 case including partly solved/held-body reopen and completed/replayed saves; record fresh-state equality, settings, and zero stale callback effects in `specs/001-six-room-slice/validation.md` (VR-005; SC-004, SC-010).
- [ ] T082 [US5] Inspect every authored room at the three quickstart resolutions for whole-room framing, live/oldest/held body visibility, landing/preview clarity, and muted hazard/plate/exit cues; test boundary walks and maximum jump reach including grace, then record geometry/camera corrections and rechecks in `specs/001-six-room-slice/validation.md` (FR-002–FR-003, FR-022, FR-024).
- [ ] T083 [US5] Traverse the complete teaching sequence with keyboard alone and controller alone, confirm live-only single transitions, fresh next rooms, Completion, fresh saved Replay, and volume retention; record outcomes in `specs/001-six-room-slice/validation.md`, retaining the separate native release matrix as outstanding (US5/AS1–AS5).

**Checkpoint**: Six actual repeatable solutions, fresh-room recovery, and full teaching/
completion flow have passing evidence. T069's proposed budgets alone never establish this.

## Phase 9: US7 — Read the Puzzle Through Dark Slapstick (P3)

**Goal**: Finish the gothic miniature presentation, reused character, comic deaths, and
cheerful/cartoon audio while preserving solid support, fast respawn, and readable cues.

**Independent test**: At the normal room camera, review all four character actions with
five corpses visible, then repeat with both audio buses muted. Required decisions stay
visible, animation never changes support, and the final effects do not delay respawn.

### Verification definitions

- [ ] T084 [P] [US7] Add `tests/physics/test_presentation_isolation.gd` to compare collider transforms/eligibility through character animations and cosmetic effects; define actual-camera action, silhouette, caption, mute, and feedback-timing review steps in `specs/001-six-room-slice/quickstart.md` (US7/AS1–AS4; FR-034–FR-037; SC-005, SC-009).
- [ ] T085 [P] [US7] Inventory or produce suitable cheerful music and cartoon trap/death cues, documenting selected sources, reuse permissions, and required attribution in `assets/audio/SOURCE.md`; specify the concrete Music/SFX cue mapping in `resources/audio_cues.tres` for implementation in T088.

### Implementation and playable verification

- [ ] T086 [P] [US7] Finish any measured cow animation/scale/material gaps in `assets/characters/cow/presentation.tres`, `scripts/player/character_visual.gd`, `scenes/player/player.tscn`, and `scenes/corpses/corpse.tscn`; preserve retained Blender sources/provenance when re-exporting `assets/characters/cow/cow.glb`, maintain a readable flat corpse pose, and keep clone identity and all physics shapes unchanged.
- [ ] T087 [P] [US7] Create reusable gothic miniature dressing in `scenes/art/room_dressing.tscn` and ink/high-contrast materials in `resources/materials/gothic_room.tres` and `resources/materials/ink_surface.tres`; retain simple lighting, broad readable surfaces, and the research R8 geometry/light budgets.
- [ ] T088 [P] [US7] Add the selected music and cartoon effects as `assets/audio/music/cheerful_loop.ogg`, `assets/audio/sfx/spike_hit.ogg`, `assets/audio/sfx/saw_jam.ogg`, `assets/audio/sfx/anvil_drop.ogg`, and `assets/audio/sfx/body_pop.ogg`; connect `resources/audio_cues.tres` in `scripts/app/audio_controller.gd` with Music/SFX routing and update attribution in `assets/audio/SOURCE.md`.
- [ ] T089 [US7] Finish non-colliding neon death/eviction feedback in `scenes/effects/death_feedback.tscn`, `scripts/effects/death_feedback.gd`, and `scenes/effects/eviction_burst.tscn`; enforce the initial 24-instance cosmetic budget and add humorous subject/death captions through `scripts/ui/hud.gd` without covering decisions, adding failure conditions, or extending the replacement deadline.
- [ ] T090 [US7] Apply the reusable art/lighting to `scenes/rooms/room_01.tscn` through `scenes/rooms/room_06.tscn`, preserving validated collision geometry, stationary framing, ground shadows, plate requirements, and active/jammed/warning distinctions; keep foreground dressing outside essential sightlines.
- [ ] T091 [US7] Run presentation-isolation checks and review movement/jump/carry/death with five corpses, all three aspect ratios, audio muted, independent audio categories, and twenty timed deaths after final effects; record actual visuals, cue readability, collider stability, ≤2-second respawns, and fixes in `specs/001-six-room-slice/validation.md` (VR-004; US7/AS1–AS4; SC-005, SC-009).
- [ ] T092 [US7] Profile a rendered release build after 30 seconds warmup and 120 seconds representative play at 1920×1080 with player/five corpses/hazards/effects; record hardware, frame/physics percentiles, draw calls, triangles, stutters, and budgets in `specs/001-six-room-slice/validation.md`, applying measured presentation optimizations through `resources/gameplay_tuning.tres` and affected art resources and rerunning changed checks.

**Checkpoint**: US7 presentation works in the final scenes. Early character proof was
required by T044; this later polish phase cannot retroactively justify starting rooms early.

## Phase 10: Polish, Playtests, and Release Validation

**Purpose**: Close cross-story acceptance with real evidence and prepare reviewable free
desktop release materials. Export generation does not establish native compatibility.

- [ ] T093 Run `scripts/checks/run_checks.py` with the complete state/physics/recovery suites on the integrated slice, require every requested case and repetition to appear, and reconcile FR-004–FR-030 plus EC-01–EC-15 coverage in `specs/001-six-room-slice/validation.md`; correct defects and rerun affected checks before accepting the build.
- [ ] T094 Prepare `specs/001-six-room-slice/playtest.md` with a consistent first-time protocol, active-time start/stop rules, non-completion/help recording, jump/placement observations, and each SC-008 cue recognition question; link sessions and defects to `specs/001-six-room-slice/validation.md` (VR-007).
- [ ] T095 Conduct at least five first-time playtests with people who have not seen the solutions; record every session, active completion time including deaths/restarts, help, misunderstandings, jump judgments, placement frustration, and cue recognition without facilitator explanation in `specs/001-six-room-slice/playtest.md`, and summarize actual median/80% recognition results in `specs/001-six-room-slice/validation.md` (SC-007–SC-008).
- [ ] T096 Resolve playtest findings through the affected `scenes/rooms/room_01.tscn` through `scenes/rooms/room_06.tscn`, `scripts/ui/onboarding.gd`, and `resources/gameplay_tuning.tres`; record the pacing review if median active time is outside 20–30 minutes, run required follow-up playtests and affected regression/solution trials, and retain evidence and unresolved defects in `specs/001-six-room-slice/playtest.md` and `specs/001-six-room-slice/validation.md`.
- [ ] T097 Set `export_presets.cfg` to include the production six-room catalogue and exclude development fixtures/runners/source art; export the final candidate to `builds/windows/over-my-dead-body.exe` and `builds/macos/over-my-dead-body.zip`, package the Windows executable plus required PCK as `builds/windows/over-my-dead-body.zip`, and create `specs/001-six-room-slice/release.md` with hashes, engine/template versions, included resources, and build identity for all subsequent native checks.
- [ ] T098 On native Windows x86_64, run the exact T097 candidate with keyboard alone through six rooms, menus/settings, independent mute, restart, quit/reopen, Completion, and Replay; record OS/hardware/input/build, saved-room freshness, and volume retention in `specs/001-six-room-slice/validation.md` (VR-006; SC-002, SC-010).
- [ ] T099 On native Windows x86_64, repeat the full T098 flow with a physical controller alone and no mouse/keyboard assistance; record controller model, focus/prompts, every outcome, and defects in `specs/001-six-room-slice/validation.md` (VR-006; SC-002, SC-010).
- [ ] T100 On native macOS, run the exact T097 candidate with keyboard alone through six rooms and the full menu/settings/recovery/completion/replay flow; record OS, architecture/hardware, input/build, saved-room freshness, and independent volume/mute retention in `specs/001-six-room-slice/validation.md` (VR-006; SC-002, SC-010).
- [ ] T101 On native macOS, repeat the full T100 flow with a physical controller alone and no mouse/keyboard assistance; record device/focus/prompts, architecture/build, every outcome, and defects in `specs/001-six-room-slice/validation.md` (VR-006; SC-002, SC-010).
- [ ] T102 Test native launch on both advertised macOS Universal 2 architectures and launch an actually downloaded candidate package; record signing/notarization method, download/launch steps, actual restrictions, and any distribution defects in `specs/001-six-room-slice/release.md`, resolving acceptance blockers without assuming signing credentials exist.
- [ ] T103 Measure the final release candidate on the selected Windows Radeon 740M-class/16 GiB and macOS M1/8 GiB targets using the research R8 30-second warmup/120-second test at 1080p; record p95 frame ≤16.7 ms and physics ≤4 ms outcomes, actual hardware or substitutions, and optimizations/rechecks in `specs/001-six-room-slice/validation.md`, leaving unavailable baselines unverified.
- [ ] T104 Prepare `release/itch-page.md` and `release/README.md` with the six-room description, controls, Windows/macOS package instructions, required attribution, feedback instructions, actual gameplay screenshots, and a free listing with no required purchase price; link the verified artifacts and distribution notes from `specs/001-six-room-slice/release.md` without publishing as part of this task list.
- [ ] T105 Audit every FR/VR/SC acceptance row and outstanding defect in `specs/001-six-room-slice/validation.md`, verify evidence matches the final artifact hashes in `specs/001-six-room-slice/release.md`, and update `specs/001-six-room-slice/quickstart.md` with proven commands; mark release readiness only when required checks pass, preserving all unverified checks and obtaining fresh affected evidence after any final build change.

**Checkpoint**: Release readiness requires passing acceptance evidence, all four native
input combinations, first-time findings addressed, and reviewable free-release packages/listing.
No task authorizes public publishing. Missing hardware/participants leaves its checks open.

## Dependencies and Execution Order

### Story dependency graph

```text
Setup T001–T005 → Foundation T006–T011
  → US1 T012–T024 (playable MVP)
    → US2 T025–T036
      → US3 core T037–T044 ──→ G1: T044 passes VR-003/VR-004
        → US3 anvil T045–T048
          → US4 T049–T057
            → US6 controls/flow T058–T065 ──→ G2: T065 passes
              → US6 export preparation T066–T067

G1 + G2 + passing US3/US4 systems → US5 T068–T083
  → US7 T084–T092
    → integrated checks/playtests T093–T096
      → candidate T097 → native matrix T098–T102 + profiling T103
        → release materials T104 → acceptance audit T105
```

These are incremental, independently testable stories, not independent codebases. US2
uses US1's actors, US3 uses their carry/plate interactions, and recovery wraps that state.
US6 and US5 share priority P2; the selected order avoids testing authored rooms with
incomplete input/menu flow. The reused-character minimum required by US7/FR-035 is
deliberately delivered early in T004/T020/T031/T044; US7 finishes presentation later.

### Gate and scheduling rules

| Boundary | Required prerequisites | Work allowed if evidence is unavailable |
| --- | --- | --- |
| Story implementation | Foundation; preceding required implementations and regression checks | Repair failures and build isolated dependent systems; do not mark a story verified. |
| Early integration gate G1 | T023–T024, T034–T036, T043–T044 actual playable results | T045–T064 isolated systems/recovery/menu work can continue. No T071–T076 room production. |
| Room production | G1, passing T048 and T056–T057, representative keyboard/controller G2 | Export preparation/native availability does not block authoring; missing G1/G2 does. |
| US7 final presentation | Six-room implementation and applicable US5 checks | Independent asset preparation may occur earlier; final scene acceptance requires the rooms. |
| Final native runs | T097 candidate after playtest corrections | Document blocked hardware; exported files are not native test evidence. |
| Release readiness | All applicable FR/VR/SC checks and corrected acceptance defects | Preparation can continue; T105 must not claim readiness with missing acceptance. |

Safe closure is implemented with the first plate/door in T029 and stress-tested during
US3, slightly ahead of the plan's Stage 2 boundary. This prevents the earlier placement
increment from shipping a trapping door. Anvil work still follows the core greybox proof
attempt; a failed/unavailable visual gate blocks expansion, not isolated implementation.

Within a batch, complete its common prerequisites first. Unmarked tasks run serially;
in particular, no simultaneous edits to `room_controller.gd`, `game.gd`, shared fixtures,
`project.godot`, `quickstart.md`, or `validation.md`. Automated case discovery avoids each
parallel test author editing the shared runner. Full room scenes share read-only components;
any required shared component/tuning change exits the authoring batch for serial integration.

### Parallel execution examples

| Phase/story | Tasks that can run together | Common prerequisites and file separation |
| --- | --- | --- |
| Setup | T002, T003, T004, T005 | T001; project inputs, tuning, asset copies, and evidence documents are separate. |
| Foundation | T008, T009 | T006–T007; identity/schema scripts versus fixture/context scenes. |
| US1 | T012, T013, T014 | Foundation; registry/lifecycle, support, and movement test files. |
| US1 | T016, T017, T018 | T012–T015; corpse, player, and spike components in separate files. |
| US2 | T025, T026, T027 | US1; state/lifecycle, placement, and contact test files. |
| US2 | T028, T029 | T025–T027; placement evaluator versus plate/door components, before T030 wiring. |
| US3 | T037, T038 | US2; registry/lifecycle versus contact/hazard test files, before T039–T042 integration. |
| US4 | T049, T050 | US3 systems; save-format versus scene-reset test files. |
| US6 | T058, T059 | US4; input-state versus audio/recovery test files. |
| US6 | T060, T061 | T058–T059; audio buses/controller versus menu scenes/controller, before T062–T064 wiring. |
| US5 | T068, T069 | G1/G2 and US3/US4 checks; transition/recovery tests versus solution worksheet/physics tests. |
| US5 | T071, T072, T073, T074, T075, T076 | T068–T070 and gates; each owns only its room scene and definition; T077 integrates the catalogue afterward. |
| US7 | T084, T085 | US5; presentation tests/procedures versus audio selection/cue resources. |
| US7 | T086, T087, T088 | T084–T085; character presentation, reusable room art, and final audio use separate writable files. |

The examples identify safe task scheduling; they do not request automatic agent delegation.
Trials writing shared evidence remain serial. If separate operators later run native
trials concurrently, collect separate raw logs and integrate them through one evidence writer.

## Requirement and Verification Coverage

Ranges below are inclusive. Each implementation task's check must use the contract and
acceptance scenarios cited by the specification, not just the happy path.

| Requirements | Primary implementation | Primary evidence |
| --- | --- | --- |
| FR-001 | T071–T078 | T079–T083, T098–T101 |
| FR-002–FR-003 | T002–T003, T017, T021, T071–T076 | T014, T024, T079–T082, T095 |
| FR-004–FR-006 | T015–T020, T032 | T012–T013, T023, T036, T043, T048, T091 |
| FR-007–FR-012 | T028–T033 | T025–T027, T034–T036, T043 |
| FR-013–FR-016 | T015, T030, T032, T040–T042 | T025, T037–T038, T043–T044, T048 |
| FR-017–FR-022 | T018, T029, T039–T042, T046–T047 | T013, T027, T038, T043, T045, T048, T082, T095 |
| FR-023–FR-025 | T070–T078 | T068–T069, T079–T083, T095 |
| FR-026–FR-029 | T051–T055, T063 | T049–T050, T056–T057, T068, T081, T098–T101 |
| FR-030 | T063, T070, T076–T077 | T059, T065, T068, T081, T083, T098–T101 |
| FR-031–FR-033 | T002, T054, T060–T066, T078 | T058–T059, T065, T083, T098–T101 |
| FR-034–FR-037 | T004, T020, T031, T041, T085–T090 | T044, T084, T091–T092, T095 |
| FR-038 | T066–T067, T097, T104 | T098–T103, T105 |

| Required verification / success outcomes | Explicit execution tasks |
| --- | --- |
| VR-001; SC-004 state portion; EC-01–EC-08, EC-14–EC-15 | T023, T034–T036, T043, T048, T093: ten per applicable scenario. |
| VR-002; SC-001, SC-003 | T023, T036, T079–T080: ten fresh rebuilds/traversals of every arrangement and every room solution. |
| VR-003 / VR-004; SC-009 | T024, T035–T036, T043–T044 early hard gate; T091 final presentation recheck. |
| VR-005; SC-004 recovery portion; EC-09–EC-13 | T056–T057, T065, T081, T093: ten per applicable recovery scenario; actual authored rooms covered by T081. |
| VR-006; SC-002, SC-010 | T098–T101: all four native platform/input combinations with full six-room/settings/recovery/replay flow. |
| VR-007; SC-007–SC-008 | T094–T096: at least five first-time sessions, actual timings, ≥80% cue recognition, pacing review/follow-up when required. |
| VR-008 | T005 initializes evidence; all check tasks record actual results; T105 audits final traceability and unresolved checks. |
| SC-005 | T043 and T091: twenty deaths each, including overlaps and carrying, every replacement within two seconds of active play. |
| SC-006 | T026, T034–T035: ten valid attempts per allowed surface and ten invalid attempts per rejection category. |
| Plan R8 performance/export requirements | T011, T066–T067, T092, T097, T102–T103; rendered/native measurements remain distinct from headless test results. |

## Implementation Strategy

1. **MVP first — T001–T024:** Build the project/foundation and US1's single playable
   death-to-traversal loop. Validate that increment before expanding interactions.
2. **Prove the core — T025–T044:** Add carry/placement, plates, FIFO roles and saws.
   Pass the shared greybox and representative-character gate with real playable evidence.
3. **Complete systems — T045–T067:** Add the anvil, robust recovery/saves, complete input/
   menus/settings, and export preparation. Pass the representative keyboard/controller flow.
4. **Build six rooms — T068–T083:** Use the proven components and measured reach/geometry;
   validate every intended solution and each new bridge/stack within the five-body cap.
5. **Finish and validate — T084–T105:** Complete presentation, measure it, run first-time
   sessions and follow-ups, then validate fixed release candidates on native systems.

When a validation task finds a defect, fix it and rerun affected checks before closing
that task. Record a dependency block honestly when graphics, hardware, participants, or
other required evidence are unavailable; continue unrelated authorized implementation.
Do not lower thresholds or expand scope silently: changes to acceptance require an
explicit evidence-backed specification amendment and consistent dependent artifacts.
