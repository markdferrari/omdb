# Implementation Plan: Six-Room Puzzle Slice

**Branch**: `main` (existing Git branch) | **Feature**: `001-six-room-slice` | **Date**: 2026-10-08 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-six-room-slice/spec.md`

**Status**: Implementation in progress: 90/115 tasks complete. All six authored rooms,
connected production catalogue, contextual teaching, real exit progression, Completion,
Replay, authored recovery and ten-trial solutions/support checks are implemented. Integrated
regressions pass 10,796 assertions; production desktop archives and Linux PCK smoke checks
pass. Human readability/controller/native/playtest/performance acceptance remains open.
The isometric camera clarification passes 9,289 physics assertions (including ten
trials per room); see CAM-02 in `validation.md` for the latest affected-system evidence.
The user accepts their greybox playtest and explicitly authorizes further implementation
(2026-10-09: "I have verified as much as I need to"). This authorizes development beyond
the G1/G2 review boundary. Detailed unreported controller/rendered trials remain unverified
and required for release; they are not retroactively marked passed. See [validation.md](validation.md).
Historical evidence sections below describe earlier checkpoints; the completed Stage 3
record in validation.md supersedes their earlier room-production status.
The feature is resolved through `.specify/feature.json`, independently of Git branch name;
no extension hooks are configured.

## Summary

Build the six-room slice in Godot 4.7.2 with GDScript, built-in Jolt physics, and the
Compatibility renderer. One room controller owns death, carrying, body order, and
hazard eligibility. Corpse props use simple rotation-locked rigid bodies with independent
visuals, while a shared placement evaluator controls both the preview and release.

First prove the entire interaction loop in one greybox using the existing cow character.
Then complete recovery and input coverage, author the six teaching rooms, and validate
presentation and native releases. Production of the full sequence is gated on recorded
greybox and character results, not on the existence of these design documents.

## Technical Context

**Language/Version**: GDScript, Godot **4.7.2** standard build; installed executable reports
`4.7.2.stable.official.ed1daf0bf`. Match export templates to this version.

**Primary Dependencies**: Godot built-ins, Jolt, selected cow GLB and retained editable
sources. No physics extension, external gameplay library, or third-party test add-on.
Python 3.12 is available for the small development-only validation wrapper; the game
runtime has no Python dependency.

**Storage**: Separate version-1 ConfigFile progress/settings documents under `user://`;
current room and music/SFX volumes only. Tests inject a temporary root before access.

**Testing**: A project-owned SceneTree runner for state, physics, and recovery suites;
manual greybox/asset checks; ten-trial room solutions; four native platform/input runs;
five first-time playtests. [Quickstart](quickstart.md) defines commands and evidence.

**Target Platform**: Windows x86_64 and macOS Universal 2, keyboard and controller for all
flows. Free Itch.io desktop release after acceptance.

**Project Type**: Single Godot 3D puzzle-platformer project, one active room at a time.

**Performance Goals**: Initial 60 fps target at 1920×1080, 95th-percentile frame time at
most 16.7 ms and physics time at most 4 ms over 120 s after 30 s warmup, with one player,
five bodies, hazards, and effects. Development reference: inspected Ryzen 5 220/Radeon
740M host. Release targets: comparable Windows hardware with 16 GiB and Apple M1/8 GiB.
These are validation targets, not achieved benchmarks or advertised minimum requirements.

**Tuning and Asset Budgets**: [Research R8](research.md#r8-initial-tuning-and-measurement-decisions)
records initial movement, jump, collision, carry, camera, timing, and rendering budgets.
Jump aiming refinement (2026-10-09 user playtest): retain ground acceleration 24 m/s²,
top speed 4.5 m/s, jump speed 6 m/s and gravity 20 m/s²; use air steering 42 m/s² and
release braking 60 m/s². At 60 Hz the target is at most 0.18 m drift after release at
full speed, reversal within eight physics frames, and a non-colliding yellow footprint
on the actual surface beneath the airborne player. Test all four views ten times,
then recheck authored traversals/bypass protection. Human control feel remains a
playtest judgment; automated measurements do not establish usability acceptance.
Observed: full-speed release drift is 0.133334 m or less in all four views; legacy
24 m/s² air response travels 0.36 m in the same eight-frame window and still has
residual velocity. All 9,529 integrated physics assertions pass; an additional focused
320-assertion run checks the expanded footprint coverage (including released/disabled
corpse support). Maximum coyote-inclusive reach remains 3.000001 m. See JUMP-01.
Room 1 authoring measures 3.000001 m maximum same-height jump reach from a real ledge
over thirty scripted trials including delayed coyote jumps. The 3.6 m spike route also
rejects ninety direct bypass trials. These headless measurements inform geometry;
rendered landing judgment and controller feel remain separate checks.
Cow metadata supports the initial 7,000-triangle/32-surface/10-material/8-bone character
budget. Every other physical or performance value remains a named experiment until
measured in the greybox; record revisions before accepting that milestone.

**Constraints**: Five bodies including held; exactly one corpse/replacement per death;
no support from held bodies; creation-order eviction; four diagonal isometric orthographic views
with 90° yaw steps and fixed authored tilt, elevation, distance and zoom;
full room reset and fresh-room resume. Scope exclusions remain those in the spec.

**Scale/Scope**: Six authored rooms, three lethal hazard types, one/multi-unit plates,
linked exits, one selected character, local saves, and complete menus/settings/replay.

## Constitution Check

*GATE: Reviewed before Phase 0 research and again after Phase 1 design.*

These are design compliance results. They do not mark gameplay or platform tests passed.

| Principle | Before research | After design |
| --- | --- | --- |
| I. Focused Six-Room Slice | PASS — spec scope, teaching table, FR-001/FR-024, and exclusions bound the feature. | PASS — delivery stages and room budget table below keep six rooms and solutions within five simultaneous bodies. |
| II. Reliable Corpse Physics and State | PASS — FR-004–FR-021 and EC-01–EC-08 require shared lifecycle invariants. | PASS — data model and gameplay contract define single ownership, deduplication, eviction, contact invalidation, and physical settling. |
| III. Readable Puzzles and Dependable Controls | PASS — spec movement/preview/camera requirements are explicit. | PASS — selected camera, support/overlap evaluator, input/feedback contract, and VR-003/VR-007 checks cover them. |
| IV. Complete Play Flow and Recovery | PASS — US4–US6 and VR-005/VR-006 cover recovery and platform/input flows. | PASS — fresh scene reconstruction, versioned save contract, menu focus, and native validation matrix implement those boundaries. |
| V. Prove Interactions Before Expanding | PASS — VR-003/VR-004 gate full room production. | PASS — stage 1 exit requires real greybox and asset evidence; headless results cannot substitute for camera/control validation. |

The user-requested camera amendment and isometric clarification (2026-10-09) update constitution 1.1.1,
PRD and dependent artifacts; free camera orbit remains excluded. Unknowns from the draft technical
context are resolved in [research.md](research.md); remaining observations are scheduled
implementation checks with explicit pass criteria.

### Verification and Evidence

- **State regressions:** Registry order/cap, death tokens, carry transitions, contact sets,
  door closure, invalid placement, stale callbacks, and save validation, mapped to
  FR/EC identifiers in the [gameplay contract](contracts/gameplay-state.md).
- **Playable validation:** Rebuild and traverse each intended bridge/stack ten times;
  verify direction, broad landings, actual-camera framing, preview accuracy, and controls.
- **Asset check:** Cow import, visual scale/materials, movement/jump/carry/death coverage,
  and one player plus five corpse visuals. Source metadata and portraits are preliminary
  evidence only; jump/carry clips need assessment or authoring.
- **Input/platform matrix:** Windows/keyboard, Windows/controller, macOS/keyboard,
  macOS/controller, including menus, restart, saved-room resume, completion, and replay.
- **Evidence location:** `specs/001-six-room-slice/validation.md`, created during
  implementation with setup, expected/actual results, trial counts, metrics and defects.
  `quickstart.md` contains reproducible steps. Unperformed checks stay unverified.

## Project Structure

### Documentation (this feature)

```text
specs/001-six-room-slice/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── gameplay-state.md
│   ├── player-interface.md
│   └── save-format.md
└── checklists/
    └── requirements.md
```

Task generation produced `tasks.md`; implementation now records actual results in
`validation.md`. These documents distinguish completed work from unperformed checks.

### Source Code (repository root)

The following is the selected implementation layout. Core systems now exist; authored
room scenes, final dressing, and release acceptance remain planned.

```text
project.godot
export_presets.cfg
.godot-version                         # 4.7.2
scenes/
├── main.tscn                           # Game, RoomHost, UI, audio
├── player/player.tscn
├── corpses/corpse.tscn
├── hazards/{spike_bed,buzzsaw,anvil}.tscn
├── puzzle/{pressure_plate,exit_door}.tscn
├── rooms/room_01.tscn ... room_06.tscn
└── ui/{hud,title,pause,settings,completion}.tscn
scripts/
├── app/{game,save_store,audio_controller}.gd
├── state/{room_state,corpse_registry}.gd
├── rooms/{room_controller,room_definition}.gd
├── player/{player_controller,placement_evaluator}.gd
├── corpses/corpse.gd
├── hazards/{spike_bed,buzzsaw,anvil}.gd
├── puzzle/{pressure_plate,exit_door}.gd
├── ui/{hud,menu_controller,onboarding}.gd
└── checks/run_checks.py                # Development-only process/result checks
resources/
├── gameplay_tuning.tres
├── room_catalogue.tres
└── rooms/room_01.tres ... room_06.tres
assets/
├── characters/cow/{cow.glb,SOURCE.md}
├── audio/{music,sfx}/
└── effects/
art/characters/cow/                    # Retained sources; art/.gdignore
├── cow.blend
└── cow-rigged.blend
tests/
├── run_tests.gd
├── state/{test_registry,test_lifecycle,test_contacts}.gd
├── recovery/{test_save_store,test_room_reset}.gd
├── physics/{test_placement,test_support,test_hazards}.gd
└── scenes/{greybox_validation,physics_fixture}.tscn
builds/                                # Export output; ignored by Git
```

**Structure Decision:** Use one project with explicit scene ownership. Keep model decisions
separate from engine contacts, imported visuals separate from collision, and source art
outside runtime imports. Ignore `.godot/`, builds, and temporary test output; retain
project settings, import options, source assets, and scene resources in version control.

### Runtime design

`Game` composes the long-lived services and swaps whole room instances. RoomController
coordinates its state/registry, player, corpses, sensors, and HUD notifications. A body
has one identity throughout pickup and release. Cosmetic carry/preview/effect instances
have no collision and never count as bodies.

Death first latches the current subject token, then performs one safe transaction:
release held body, retire oldest if needed, create one new corpse, update eligible contacts,
and schedule one replacement. Epoch checks make restart/departure cancel every earlier
callback. Collision mutations are committed outside contact callbacks and before further
movement can observe obsolete support. See [data-model.md](data-model.md) and
[gameplay-state.md](contracts/gameplay-state.md) for the precise boundary.

Plate weight is a set of distinct eligible occupants: a player or corpse directly resting
on the plate contributes one unit, and every released corpse stably stacked on a contributing
corpse contributes one additional unit. Saw jams are a set of released bodies.
Anvils use visual animation and a live-player kill volume without destructive corpse
impulses. Safe door retreat anchors are protected from placement. Authored geometry
provides clearance for death while carrying and makes hazard bypasses testable.

## Delivery Stages and Room Design

### Stage 1 — Interaction and character proof

Implement the project/test foundation and one greybox. Deliver US1's first death/traversal
loop, then US2 carrying/placement and US3 cap/plate/saw interactions in that fixture.
Import cow with separate solid corpse shape. Establish the state/physics regressions and
inspect character movement, jump, carry, and death at the actual camera distance.

**Exit gate:** VR-003 and VR-004 have recorded passing evidence; core state checks pass;
bridge/stack trials and placement categories meet their spec counts; actual tuning and
asset issues are recorded. Missing graphical access leaves this gate unverified and
blocks full room production, while isolated implementation/checks can continue.

### Stage 2 — Complete systems and recovery

Add the telegraphed anvil, safe door closure, complete scene restart, save fallback and
resume, menus, two audio settings, and keyboard/controller flow. Add recovery fixtures
and test stale death/exit events during restart. Establish export presets and obtain
matching templates for native smoke checks.

**Exit gate:** Relevant VR-001/VR-005 scenarios pass; one representative room's complete
menu/play/restart/settings flow works with each input method. Record outstanding native
platform checks explicitly; they still block release.

### Stage 3 — Author the six-room teaching sequence

Use the following intended arrangements as room-design starting points, then record
actual solution steps, dimensions, body order, and ten-trial results. Body requirements
are design targets until tested; a failed arrangement requires revising geometry/tuning,
not increasing the cap. Every listed room starts with an empty body registry.

| Room | Intended arrangement / teaching | Maximum simultaneous bodies |
| --- | --- | ---: |
| 1 | One sacrifice leaves a landing/support body across part of the spike route. Its remaining jump is broad; the full exposed gap exceeds measured unaided reach. No carry is required for the introductory route. | 1 |
| 2 | Generate and carry a body to a plate to keep the separated exit open; show one-unit contribution and required-weight feedback. Demonstrate multi-unit weighting before later combined requirements. | 2 |
| 3 | Leave/place one body at the saw jam point, observe permanent stop, safely retrieve it from outside the lethal volume to show reactivation, then re-jam and cross. | 1 |
| 4 | Use one early body to reach an observation shelf with a return route. Allocate two newer anvil bodies to the plate and three to the spike route. The sixth creation replaces the unneeded oldest step body. The shelf remains optional for alternative solutions; no death quota controls the exit. | 5 (6 total creations) |
| 5 | Allocate two bodies to a bridge/step route, two directly to a plate, and one to a saw; all interactions were introduced earlier. | 5 |
| 6 | Combine the same five-body allocation with a different route and telegraphed anvil area; no new rule or timed jump is required. Reach final completion and Replay. | 5 |

Room 4's early body remains visible beside the observation shelf so its removal is
observable. The proposed one-way entry ledge was replaced during implementation: after
the sixth death, entrance respawn plus FIFO eviction would otherwise prevent returning
to the puzzle. The shelf teaches body support but has a normal floor return; no checkpoint,
new mechanic or death quota was introduced. The final route does not require that body.
Reliable alternative solutions remain valid; there is no invisible death quota on exits.
Plate surfaces must fit all required direct contributors. Spike beds support bodies;
wall/route geometry prevents stepping around the obstacle or bypassing it with the
measured maximum jump, including coyote time and buffering.

**Exit gate:** Six repeatable solutions within the cap, clean room transitions, no new
untaught mechanics, and recorded anti-bypass/landing trials. Do not claim the planned
budget table itself proves solvability.

### Stage 4 — Presentation, playtest, and release validation

Finish gothic room dressing, readable silhouettes/shadows, cow animation gaps, onboarding,
subject captions, neon non-colliding effects, cheerful music/cartoon sounds, and completion
flow. Profile with player/five bodies; resolve measured budget issues. Run all four native
input/platform combinations and at least five first-time sessions. Review 20–30 minute
pacing as a measured target, recording follow-up results where needed.

**Exit gate:** All applicable spec acceptance checks pass, release packages start on
native target systems, settings/recovery work after reopen, and acceptance defects are
fixed. Prepare the free Itch.io listing and record macOS signing/download-launch behavior.
Publishing remains a later release action; this plan makes no deployment.

### Requirement-to-design coverage

| Requirements | Primary design / stage | Validation |
| --- | --- | --- |
| FR-001–FR-003 | Player/camera, room catalogue; stages 1/3 | US1/US5; VR-002/VR-006/VR-007 |
| FR-004–FR-006 | Death tokens, corpse registry, solid support; stage 1 | VR-001/VR-003; SC-003–SC-005 |
| FR-007–FR-012 | Carry state and shared placement evaluator; stage 1 | VR-001/VR-003; SC-006 |
| FR-013–FR-016 | FIFO eviction, snapshots, contact invalidation; stage 1 | EC-02–EC-07; VR-001 |
| FR-017–FR-022 | Hazard/plate/door contracts; stages 1/2 | VR-001; EC-14/EC-15; SC-008 |
| FR-023–FR-030 | Epoch-based scene flow, fresh reconstruction, save contract; stages 2/3 | VR-002/VR-005; SC-001/SC-004 |
| FR-031–FR-033 | Input/menu/audio and save contracts; stage 2 onward | VR-006; SC-002/SC-010 |
| FR-034–FR-037 | Character/effects/audio; first proof then stage 4 | VR-004/VR-007; SC-008/SC-009 |
| FR-038 | Matched export templates, native packages, free listing; stage 4 | VR-006 and downloaded-package launch checks |

## Complexity Tracking

No constitution violations or exceptions. The scene controller plus two small state
objects provides the required shared ownership without an event framework. The small
Python validation wrapper exists only to reject engine failures/missing test summaries
reliably; it is not shipped with the game. Reconsider added dependencies only against a
measured need and document the effect on the gates above.


## Implementation evidence update (2026-10-08)

Following the user's approval to continue after the keyboard playtest, the greybox now
includes carrying/shared placement evaluation, direct-support plates, reserved door
retreats, FIFO contact invalidation and cosmetic eviction, persistent saw jams, and the
warned/repeating anvil. Automated tests construct component setups atop the shared
physics fixture; modular test files refine the planned layout without new dependencies.
Save-root injection is owned by SceneTree session metadata rather than static script
storage, avoiding a script-resource leak at engine shutdown. Placement and plate
materials are reused instead of allocated each physics frame.

The full suite passes 4,716 assertions. Exact commands, behavioral RED runs, measured
physics outcomes, and outstanding human checks are in `validation.md`. Research tuning
remains provisional: no graphics/controller acceptance or performance measurement is
inferred. T044 still gates all six-room production; isolated systems are not a passed
Stage 1 gate. Recovery/save/menu implementation remains future work.


## Recovery and representative flow evidence (2026-10-08)

Isolated Stage 2 implementation now includes checked independent version-1 documents,
candidate initialization/activation, epoch cancellation and whole-room reconstruction,
fresh Continue, menu focus/navigation, pause/disconnect handling, active-method HUD prompts,
and independent Music/SFX with generated preview sources. Recovery fixtures reuse the
same greybox for each valid ID; no authored-room work was substituted for the Stage 1 gate.
The scalar save reader consumes ConfigFile-format documents without invoking Godot's
logging parser on corrupt values. Unknown fields are ignored; invalid fields/defaults and
numeric clamping follow the save contract. Writes use ConfigFile and checked sibling-temp
rename without deleting the valid destination. Tests include real filesystem failure and
controlled temporary-write/rename failures retaining previous documents.

Controller event tests found device-0-only bindings. All joypad gameplay/UI actions now
use wildcard device -1; device-42 Pause/Restart tests pass. This is regression evidence,
not a physical-controller comfort check. Representative Windows x86_64/macOS Universal 2
exports use matching official templates; enabling ETC2/ASTC imports resolves the observed
arm64 export prerequisite. Templates stay outside the repo and exports under ignored
`builds/`. Native launch/signing/performance acceptance remains unverified.

T044 and T065 still block full six-room production. Actual manual keyboard/controller,
character/camera and native results remain required. See the final checkpoint in
`validation.md`; earlier implementation evidence sections are historical.

## Table placement correction — DEV-004

User playtest feedback identified excessive placement rejection near table edges.
The nominal 1.6 m facing aim remains unchanged when valid. A bounded 0.6 m adjustment
search projects the full yaw-oriented body footprint into nearby box support surfaces,
then uses the existing evaluator for every alternative. Transport rays follow a lift,
traverse, and lower route from the 1.2 m carry anchor so a raised tabletop does not block
its own placement. Reach remains 2.2 m; support/overlap/reservation checks remain enforced.
This initial assist distance is supported by ten-trial physics regressions, with rendered
control feel and query-cost measurements still awaiting playable validation (T109).

## Independent presentation preparation — T084/T085/T088/T089/T094

Before room-production gates are closed, reusable audio/effects and verification protocols
can be prepared in the established greybox. Original deterministic PCM sources generated
by `scripts/checks/generate_audio.py` replace the initially proposed Ogg files: Godot's
built-in import avoids an external encoder. `AudioCues` selects a 14.545-second original
swing loop and six short cartoon cues. Four bounded SFX voices keep events separate from
Music. Unique authored hazard IDs resolve to types for correct cues/captions; anvil impact
sound is deduplicated from its lethal commit. Cosmetic feedback shares 24 fragments and
expires independently of the unchanged 0.6-second respawn timer. Isolation checks and
first-time testing instructions are prepared; artistic/audio and rendered acceptance remain
T044/T091, and six-room production still requires the existing G1/G2 evidence.

T087 also prepares a reusable 16 × 12 m room frame with shared warm matte stone and
ink materials, 18 primitive mesh instances, low outboard finials, no collision, lights,
or shadow-casting dressing. Its geometric scale is intentionally broad and small;
rendered visibility and frame budgets still require T090–T092 after actual room layout.
The asset is not used to substitute for the greybox/character proof or author rooms early.
