# Contract: Gameplay Commands and Scene Integration

**Version**: 1 | **Date**: 2026-10-08

This contract joins the state model, scene components, UI, and validation runner. The
player-facing interface is in [player-interface.md](player-interface.md). Entity fields
and transition ordering are defined in [the data model](../data-model.md).

## Command boundary

Only RoomController commits room mutations. Every command carries the current room epoch;
player commands also carry the subject ID. Requests for removed bodies, retired rooms,
dead actors, or prior epochs return a rejection and do not mutate state.

| Command | Inputs | Result / invariant |
| --- | --- | --- |
| `request_death` | Epoch, subject ID, hazard ID, observed death transform | First valid request latches one death; repeated requests return `IGNORED_DUPLICATE` or `IGNORED_STALE`. |
| `request_pickup` | Epoch, subject ID, target body ID | `ACCEPTED` only for an in-reach, unobstructed released body and empty hands; preserve age. |
| `request_place` | Epoch, subject ID, held body ID | Recompute placement from current facing/space; return `ACCEPTED` or the placement rejection reason. Do not trust a UI-supplied transform. |
| `request_restart` | Current session and active room identity | Invalidate old epoch, replace active room once, and reject all old callbacks. Available during death feedback. |
| `request_exit` | Epoch, subject ID, exit ID | Require an alive subject, open exit, actual crossing, and unused exit latch; corpses cannot invoke it. |
| `observe_contacts` | Epoch, component ID, distinct candidate actor IDs, support/contact evidence | Filter eligibility, resolve stable corpse support chains for plates, and update plate or jam membership; duplicate observations do not add weight. |
| `advance_feedback` | Current epoch/token and elapsed active time | At feedback completion spawn one replacement, unless restart/departure superseded the token. |

Command results use `ACCEPTED`, `INVALID_STATE`, `OUT_OF_REACH`, `BLOCKED_PATH`,
placement-specific reasons, `IGNORED_DUPLICATE`, or `IGNORED_STALE`. Expected rejections
are normal gameplay outcomes, not fatal errors. Invalid scene configuration is a test
failure and an actionable error during development.

## Mutation and publication

1. Contact callbacks latch eligibility changes and enqueue intents; they do not change
   physics shapes, free nodes, or instantiate a replacement inside contact dispatch.
2. Process queued commands in the priority from the data model. Compute the registry/carry
   changes as one batch, including eviction before activating a new sixth corpse.
3. Apply collision disable/enable, one-shot transforms, and scene add/remove operations
   outside locked physics callbacks. Use deferred commits or the next safe physics boundary.
   Zero velocities when releasing; never continuously steer a simulated released prop.
4. Remove invalid contact contributions explicitly; wake bodies affected by lost support.
   Refresh queries after the physics server has synchronized. Do not read an Area overlap
   cache immediately after moving a prop and assume it describes the new placement.
5. Publish one coherent count/oldest/carry/contact snapshot. Suppress transient door,
   plate, or jam feedback between the individual operations of one batch.

The world must not simulate another player movement step with a logically removed body
still providing support or a held body still jamming a saw. Snapshot consistency is a
regression-test assertion, not an assumption about signal order.

## Notifications

| Notification | Data | Consumers |
| --- | --- | --- |
| `room_snapshot_changed` | Epoch, phase, active subject ID, ordered body IDs, held ID, oldest ID | HUD, prompts, diagnostic tests |
| `placement_preview_changed` | Body ID, candidate pose, validity/reason | Placement ghost, prompt, tests |
| `puzzle_state_changed` | Component ID, weight/requirement or jam/open state | Door/saw visuals, audio, HUD, tests |
| `death_committed` | Epoch, dead subject ID, hazard ID, new body ID, optional evicted ID | Caption/effects and telemetry |
| `room_completed` | Epoch, room ID | Game progression owner; one event per room instance |

Consumers cannot mutate the snapshot to change game state. HUD body count and oldest
marker are derived from the same ordered registry; no independent UI counters exist.

## Collision and detection matrix

Project layer names and numeric bit values:

| Object | Layer | Mask | Meaning |
| --- | ---: | ---: | --- |
| Static world/doors/plate support | World = 1 | Player + Corpse = 6 | Solid surfaces and blockers |
| Live player | Player = 2 | World + Corpse = 5 | Move against solid geometry and released bodies |
| Released corpse | Corpse = 4 | World + Player + Corpse = 7 | Solid supporting prop |
| Held/removed/dead actor physics | 0 | 0 | Disabled collision; no sensor contribution |
| Spike/anvil/active saw lethal Area | Sensor = 8 | Player = 2 | Lethal only to current live subject |
| Saw jam Area | Sensor = 8 | Corpse = 4 | Detect released bodies; set membership deduplicated |
| Plate candidate Area | Sensor = 8 | Player + Corpse = 6 | Candidates still require direct-support validation |
| Exit/door passage Area | Sensor = 8 | Player = 2 | Live crossing and safe closure handling |
| Ghosts, captions, gore, carry visual | 0 | 0 | Presentation only |

Queries for placement use World, Player, and Corpse solids, not sensor volumes. Pickup
uses nearest eligible body within reach and an unobstructed path; tie-break by distance
then creation order. Collision-shape resources are not unintentionally shared when a
scene changes their dimensions.

## Placement and hazard geometry

Use one placement evaluator for preview and release. Its ordered checks are identity,
horizontal reach, support, final three-dimensional reach, unobstructed transport path,
full-volume overlap, and protected entrance/doorway space. Start with a centre probe and
four inset footprint-corner probes on a near-horizontal surface. Require centre support
and all four corners supported within the tuning height tolerance, permitting multiple
coplanar supports. This conservative rule allows stable bridges on spike beds and stacks;
do not require unsupported balancing as an intended solution. Query a small surface
clearance, then let gravity settle the released body.

A valid nominal candidate stays exactly 1.6 m ahead. If nominal support is missing,
uneven, or occupied by another body, try nearby BoxShape3D support rectangles in order
of distance, bounded to a 0.6 m horizontal adjustment. Project the full rotated footprint
into each rectangle and check nearby alternatives/edges; every candidate passes the same
support, reach, path, overlap, and reserved-space rules. Explicit target queries remain
strict. The transport centre rises from the 1.2 m carry anchor, crosses above the chosen
surface, then lowers to the candidate; ray queries reject obstacles on every leg.
Preview and release recompute this identical search using current physics state.

The candidate preserves continuous player-facing yaw. It does not snap to a grid or
rotate in response to decorative animation. Geometry around intended death sites must
allow a held prop and a new corpse to settle separately. Test death releases independently
of normal valid-preview placement; they cannot silently discard a prop.

A spike bed has a solid supporting base and a shallow player-only lethal volume. Test
that standing on a corpse clears that volume while touching exposed spikes kills. A saw's
visual rotor and lethal volume stop when jammed; the route must have no remaining solid
rotor blocker. An anvil uses a telegraphed visual drop and player-only kill volume, without
an additional crushing rigid body that destabilizes existing corpses.

Plate support tests require direct resting contact or a stable downward corpse support
chain, excluding held bodies, jump-over overlaps, and bodies stacked on non-contributing
or held bodies. Count one unit per eligible identity regardless of mass or contact count.
The linked door's state
tracks the resulting weight. Safe entry-side anchors must be outside lethal volumes and
protected from body placement so closure can displace an occupying player without a new
hazard or a bypass.

## Validation harness interface

`tests/run_tests.gd` is a SceneTree runner supporting project-defined arguments after `--`:

| Argument | Accepted values / behavior |
| --- | --- |
| `--suite` | `state`, `physics`, `recovery`, or `all`; unknown/missing values fail with usage information |
| `--save-root` | Absolute temporary directory, injected before any save read/write; normal player-save roots are rejected for tests |

Emit per-scenario ID/result/repetition counts and one final `OMDB_TEST_RESULT` summary
with passed/failed counts. Exit 0 only when the requested nonempty suite completes and all
checks pass; exit nonzero for failure, invalid arguments, missing fixtures, or a watchdog
timeout. The calling check must also reject engine parse/import errors or a missing final
summary even if the engine itself exits 0. Use a bounded watchdog for awaited physics
frames so a deadlocked fixture cannot hang validation indefinitely.

Pure-state cases exercise registry and lifecycle ownership. Physics fixtures instantiate
the real components and await actual physics frames; they assert tolerances and invariant
outcomes rather than exact trajectories. Recovery fixtures use temporary files and verify
that old epochs cannot change a reset room. No suite writes to normal player progress.

`scripts/checks/run_checks.py` is the development-only caller. Its command-line options
are `--godot` (executable name/path), `--suite` (the four runner choices above), and
`--save-root` (required absolute temporary root). It imports/checks the project, invokes
the runner with the corresponding user arguments, captures diagnostics, requires the final
summary, enforces a process timeout, and propagates failure through its own exit code.
It uses Python's standard library only. Imported resources and game code remain GDScript.

## Presentation event isolation

Room `presentation_cue(cue)` carries an audio request without mutating gameplay state.
Committed deaths include `hazard_kind` alongside the unique `hazard_id`; type lookup
must work for authored IDs such as `greybox_saw`. Emit spike/saw death cues once after
death deduplication, saw-jam cues only on false-to-true transitions, anvil warning at
cycle start and drop once at impact (not again at lethal commit), and body-pop on removal.
Retired rooms emit no new cues. Sessions and isolated validation contexts bind room cues
to the same AudioController, with four SFX voices and one Music voice; both bus controls
apply independently. Headless runs resolve streams and requests without audible playback.

Death/eviction fragments contain no physics nodes, register no body identities, and use
only cosmetic timers. Share a room budget of 24 visible fragments, removing oldest
cosmetic feedback to admit a new burst. Effects last 0.6 seconds of active play, pause
with their room, and disappear when it is replaced; they never govern respawn timing.
