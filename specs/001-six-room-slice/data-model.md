# Data Model: Six-Room Puzzle Slice

**Date**: 2026-10-08 | **Source**: [spec.md](spec.md)

This is a scene-backed game state model, not a database design. Only progress and audio
settings survive process exit. Physical transforms belong to scene bodies; authoritative
identity, eligibility, order, and lifecycle belong to the room controller's model.

## Ownership

| Owner | Responsibility | Lifetime |
| --- | --- | --- |
| `Game` (`scripts/app/game.gd`) | Application phase, active room ID, monotonic room epoch, menu focus, scene replacement, progress commit | Application |
| `SaveStore` (`scripts/app/save_store.gd`) | Validate/read/write progress and settings through an injected storage root | Application or isolated test |
| `RoomController` (`scripts/rooms/room_controller.gd`) | Accept room commands, coordinate physical commits and actor/contact eligibility, spawn replacement player | One room instance |
| `RoomState` (`scripts/state/room_state.gd`) | Room phase, current subject, carry identity, generation checks, accepted death/exit latches | One room instance |
| `CorpseRegistry` (`scripts/state/corpse_registry.gd`) | Body records in creation order, next ID, oldest selection, logical removal | One room instance |
| Scene components | Movement, rigid-body simulation, sensor observations, visuals, audio | Owning scene |

`Game` passes dependencies to rooms. Nodes communicate through explicit signals/calls;
there is no global gameplay registry. Test scenes use the same composition with an
isolated SaveStore and explicit room definition.

## Entities and validation

### Application session

- `phase`: `MENU`, `PLAYING`, `PAUSED`, `SWITCHING`, `COMPLETE`, or `EXITING`.
- `active_room_id`: one of `room_01` through `room_06`; this changes only when a new room
  has finished initialization and is committed as active.
- `room_epoch`: increasing integer, incremented on restart, departure, or replacement.
- `pending_target_room_id`: transient target while switching; never saved before activation.
- `settings`: validated music/SFX values from the save contract.
- `session_deaths`, `next_subject_number`: transient humorous counters, not failure rules.

A repeated request cannot run two replacements concurrently. Restart during an uncommitted
exit transition cancels that transition and reloads the existing active room. After
activation, restart applies to the newly active room. Completion retains `room_06` as
saved progress; replay commits `room_01` and leaves settings unchanged.

### Room definition

A `RoomDefinition` resource contains:

| Field | Type / rule |
| --- | --- |
| `room_id` | Unique stable ID in the six-room catalogue |
| `title`, `teaching_goal` | Display text and authored teaching purpose |
| `scene` | PackedScene for one authored room |
| `next_room_id` | Following catalogue ID; empty only for room 6 |
| `camera_frame` | Fixed transform, orthographic size, playable bounds, aspect policy |
| `spawn` | Safe entrance transform outside all lethal volumes and door displacement zones |
| `hazard_ids`, `plate_ids`, `exit_id` | Unique identifiers for scene components |
| `onboarding_cues` | Contextual cue IDs tied to first relevant interaction |
| `solution_record` | Reference to validation notes; required before room acceptance |

The catalogue orders six definitions exactly once. The greybox is a validation fixture,
not a seventh progression room. Scene geometry must provide corpse-sized delivery paths,
clear death/drop space, and safe door retreat anchors. Every reset instantiates the same
definition anew; no mutable puzzle state is stored in the definition resource.

### Room state

- `epoch`: matches the active session epoch.
- `phase`: `INITIALIZING`, `ACTIVE`, `DEATH_FEEDBACK`, or `RETIRED`.
- `subject_id`: current subject generation; absent while no subject is controllable.
- `held_body_id`: empty or one existing registry record with mode `HELD`.
- `registry`: ordered body records; `body_count` and `oldest_id` are derived.
- `death_token`: accepted `(epoch, subject_id)` or empty.
- `exit_consumed`: one-shot transition latch for the current room.
- `pending_commands`: short-lived intents, each with epoch and actor identity.

`ACTIVE` has exactly one live player. `DEATH_FEEDBACK` has no controllable player and
exactly one scheduled replacement; that temporary interval is bounded by the spec's
respawn limit. `RETIRED` accepts no new gameplay commands.

### Live subject

- `subject_id`, `epoch`: identify this clone and its room generation.
- `status`: `ALIVE`, `DEAD`, or `RETIRED`.
- `transform`, `velocity`, `grounded`, `last_facing`: movement state on CharacterBody3D.
- `jump_buffer_remaining`, `coyote_remaining`: transient movement forgiveness.
- `carry_anchor`: transform used for the held visual and emergency death release.

The room state is the authority for held identity; the player cannot maintain a separate
independent inventory. Only `ALIVE` subjects contribute one direct plate unit or trigger
an exit. Lethal contacts are ignored after the first accepted death token.

### Corpse record and physical prop

| Field | Type / rule |
| --- | --- |
| `body_id` | Epoch plus increasing creation sequence; never reused within the epoch |
| `creation_index` | Immutable integer; pickup/release never alters it |
| `mode` | `RELEASED`, `HELD`, or terminal `REMOVED` |
| `death_origin` | Original death transform for diagnostics; not a respawn/save point |
| `physics_node` | Controller-owned reference to the room's RigidBody3D; absent after disposal |
| `visual_pose` | Chosen collapsed pose; does not determine collision shape |

`RELEASED` permits physical support, direct plate contribution, and jam contact.
`HELD` remains in the registry but has no collision or puzzle contribution. `REMOVED`
is excluded from every derived view even if node disposal is queued for the frame end.
Released bodies are free to translate under physics with their rotation locked. Sleeping
is a physics optimization; it does not make them permanent static supports.

At any committed state: zero to five non-removed records; zero or one held body; each
body ID appears once. Before activating a sixth prop, retire the oldest, clear its contacts
and collision, and remove its registry membership. There is never a sixth eligible body.

### Placement result

- `epoch`, `subject_id`, `body_id`: the requesting identities.
- `candidate_transform`: flat pose aligned with player facing, above the tested support.
- `valid`: result of reach, line-of-sight, footprint, and overlap checks.
- `reason`: `VALID`, `OUT_OF_REACH`, `BLOCKED_PATH`, `NO_SUPPORT`, `UNSTABLE_SUPPORT`,
  `PLAYER_OVERLAP`, `WORLD_OVERLAP`, `BODY_OVERLAP`, or `STALE_REQUEST`.
- `support_ids`: observed world/body supports; diagnostic, not a permanent weld.
- `sampled_physics_tick`: identifies preview freshness; release always revalidates.

The query ignores only the held body's disabled physics representation. It must still
test the live player and the supporting bodies for penetration. Touching a surface from
above is permitted using the documented clearance; intersecting occupied volume is not.

### Plate, saw, anvil, and exit

| Component | State | Validation / derived behavior |
| --- | --- | --- |
| Pressure plate | ID; required integer weight; set of eligible direct-support actor IDs | Requirement at least 1 and feasible within available player/body allocation; weight equals distinct eligible occupants, not mass or number of signals. |
| Buzzsaw | ID; set of released body IDs at jam point | Jammed iff set is nonempty; no jam timeout. A held/removed ID can never remain eligible. |
| Falling anvil | ID; `WAITING`, `WARNING`, `DROPPING`, `RECOVERING`; cycle time | Lethal volume active during impact/drop; warning precedes each drop; reset cancels the old cycle. Bodies are not destroyed or pushed by a crushing rigid body. |
| Spike bed | ID; player-only lethal volume; solid corpse-support bed | A body-covered route must keep the player's collision shape above the exposed lethal volume. |
| Exit door | ID; optional linked plate ID; open state; passage occupants and entry side; safe retreat anchors | No link means an authored open exit. Otherwise open iff weight meets requirement. Only a live player crossing an open exit consumes room completion. |

Contact observations are deduplicated by actor identity. Eligibility changes synchronously
when a body is picked up or removed; physics observation of a new/placed contact can take
until the next synchronized physics step. The displayed state and physical door/saw state
must converge before the next player movement decision. Geometry must make safe retreat
possible on both sides of each closing door.

### Saved records and validation evidence

Persistent records use the exact schema in [save-format.md](contracts/save-format.md).
Transient bodies, subject state, hazard phases, and contact sets are never saved.

Each validation record includes build/engine version, OS/hardware/input, scenario and
requirement IDs, initial state, actions, expected outcome, actual outcome, repetitions,
observed maxima/timings, pass/fail/unverified, and defects. Actual evidence is written
in `validation.md` during implementation; the planning documents are not that evidence.

## State transitions and event ordering

| Transition | Ordered effect |
| --- | --- |
| Spawn room | Allocate new epoch; instantiate original scene; clear registry/carry; initialize hazards; spawn one subject; enable gameplay; commit current room and save. |
| First lethal contact | Latch death token and disable logical player eligibility immediately; queue one safe physical death transaction. |
| Death commit | Disable old player collision; release held body if any; retire oldest if at cap; create one corpse; refresh affected contacts/HUD; start feedback countdown. |
| Respawn | If epoch/token still current, dispose dead actor and create one replacement at entrance; return to `ACTIVE` within two seconds of lethal contact. |
| Pickup | Validate live subject, body, reach, visibility, empty hands; mark `HELD`; remove contributions; disable/freeze prop; show carry visual; retain creation index. |
| Valid release | Revalidate candidate in physics step; commit pose with zero velocities; restore physical shape and `RELEASED` eligibility; clear carry visual/identity; reconcile contacts. |
| Invalid release | Keep held body, count, creation order, and physics state unchanged; show invalid reason. |
| Eviction | Mark `REMOVED`; clear held identity if needed; remove contact contributions; disable/hide prop and wake affected supports; remove registry record; queue free; play non-colliding effect. |
| Restart/departure | Invalidate epoch before removing scene; cancel pending feedback/actions; discard the entire room and instantiate required fresh scene. |
| Exit | Require current alive subject, open door, and unused exit latch; latch transition and retire room; activate/save next room or show completion. |

Priority for conflicting intents in one epoch: restart/departure cancellation first,
accepted death second, exit third, pickup/release last. A dead subject cannot also complete
a room. Each asynchronous callback validates its epoch and actor token immediately before
mutation. Physics callbacks never directly free bodies or change collision shapes.

Death release is not a voluntary placement attempt. Search non-penetrating positions
near the carry anchor while reserving space for the new corpse, then above that nearby
column so gravity can settle the prop. Preserve its identity and age. All authored lethal
areas must provide clearance for this case; lack of a safe release is a failed room/physics
acceptance check, not permission to delete the body or retain an invisible held item.
