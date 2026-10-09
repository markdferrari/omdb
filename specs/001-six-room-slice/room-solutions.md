# Authored room solutions

The user accepted the greybox and authorized room production on 2026-10-09. All six
routes below now have ten consecutive fresh scripted completions within the cap. Rooms
2–6 use actual movement, jump input, hazard deaths, pickup and validated placement with
no subject staging or corpse injection/teleports. Separate contact-safe diagnostic trials
independently rebuild the arrangements. Scripted checks do not establish controller feel,
rendered readability or first-playthrough pacing.

| Room | Recorded actions and allocation | Peak bodies | Bypass checks |
| --- | --- | ---: | --- |
| 1 | Jump into the spike route; respawn, jump onto the resulting body, cross its top and jump to the far bank. Carrying is unnecessary. | 1 | Empty-bank jumps at different launch positions; both boundary edges; full spike width. |
| 2 | Stand on the one-unit practice plate, then leave it; create and carry two bodies onto the remote two-unit exit plate. | 2 | A player standing alone cannot hold the remote door; walking around closed door is blocked. |
| 3 | Create one body at the saw; retrieve from its safe side to observe reactivation, replace to jam indefinitely, cross stopped route. | 1 | Active saw blocks the entire corridor; jump and boundary walk cannot avoid it. |
| 4 | First anvil body assists the observation shelf, with a normal floor return; two newer bodies weigh the plate and three cross the spike route. Sixth creation evicts the visible, unneeded step body. | 5, six created | No death quota or irreversible entrance ledge; unaided spike jumps fail; eviction preserves allocated bodies. |
| 5 | Two bodies form the broad bridge/step route, two hold the exit plate, one jams the saw. | 5 | Test jumps, outer boundaries and closed exit around every obstruction. |
| 6 | Repeat the taught five-body allocation on a distinct route through a warned anvil area; final exit reaches Completion. | 5 | No new mechanic or required timed jump; full-route and closed-exit bypass checks. |

Production definitions live in `resources/room_catalogue.tres`, separate from the repeated
recovery fixture and the older Room-1-only diagnostic catalogue. Reliable alternatives
using fewer bodies remain valid; these allocations are recorded solutions, not minimum
death requirements or hidden exit quotas.

## Room 1 — A valuable contribution

Implemented in `scenes/rooms/room_01.tscn` with production-only component dependencies
and definition `resources/rooms/room_01.tres`. The shared chamber has a 16 × 12 m floor,
solid perimeter/cutaway foreground, spawn (-5, 0.05, 0), and stationary orthographic camera
size 21 at (12, 12, 12). The spike strip spans x=-1.8..1.8, z=-5.95..5.95. The open exit
is at (6.2, 0, 0). No plate, saw or anvil is introduced here.

Actual scripted solution: approach to x≥-2.65 at full speed, jump toward the centre and
die to the real spike sensor. Wait for respawn; repeat the approach and jump onto the
hazard-created body's top. Walk to x≥0.45 on that support, jump to the far bank and
continue through the open exit. Never pick up, inject, move or freeze the corpse. Creation
order is one hazard-created body; peak count is one; subject #2 completes alive.

Actual results (2026-10-09): ten consecutive fresh rebuilds and real exit completions
pass. Ninety fresh empty-room jumps (ten repetitions of three launch positions at three
Z positions, including both outer edges) all die without completing. Thirty real ledge
measurements, including delays of 0/3/5 physics frames before jump, yield maximum
same-height reach 3.000001 m; delay results are about 2.775, 2.925 and 3.000 m. The full
strip is wider than this measured bound. Ground collision forgiveness is exercised by
the actual controller and the separate real-spike bypass attempts.

The onboarding initially explains sacrifice, then explains jumping onto the remaining
body after respawn. It changes Space to South for controller prompts. All three cue
checks pass in each of ten trials. Rendered readability/controller feel, human completion
time and three-resolution checks remain unverified under T082/T083.

## Rooms 2–6 — Recorded physical solutions

Rooms 2–3 use the 16 × 12 m chamber and camera size 21. Rooms 4–6 use a 24 × 12 m
chamber, entrance (-10, 0.05, 0) and camera size 28 at (16, 16, 16), preserving the
same elevated angle. Root `floor_width`, `bed_size` and `passage_offset` authoring
properties configure actual colliders/meshes equally in source and compiled exports.
All weighted exits have a full-height partition reaching both perimeter boundaries.

**Room 2 — Dead weight.** Walk/jump onto the practice plate at (-5, 0, 3.5): the live
player contributes 1/1, then leaving restores 0/1. It is explicitly marked PRACTICE
PLATE, distinct from the remote two-unit EXIT PLATE at (-1, 0, 3.5). Walk into the
2 × 2 m spike supply at (-5, 0, -3.5); respawn and collect the resulting body from its
safe side. Carry through the clear central floor, jump onto the empty plate, face left
and place the first contributor. Repeat the sacrifice, approach the right of the plate
and place the second. Walk away and through the remote exit at (6.2, 0, 0). Actual direct
contributors settle near (-1.95, 0.345, 3.439) and (-0.05, 0.345, 3.439); creation order
is left contributor then right contributor; peak/retained count 2. No live-player weight
is needed at the final crossing. Existing stack regressions also count both stacked bodies.

**Room 3 — Please stop the machinery.** Walk from the entrance into the active saw
at (0, 0, 0), producing one corpse that jams it. After respawn approach x=-2.2, retrieve
that same body from outside the blade volume and observe immediate reactivation. Walk
to x≈-1.6, face right and replace it at x≈-0.042. The stable released body keeps the
saw stopped without a timer. Jump onto/across it, walk through the corridor, then cross
the open exit at x=6.2. No plate or anvil is introduced; peak/retained count 1. Partitions
span both sides of the 2.2 m passage, preventing floor walk-arounds and unaided jumps.

**Room 4 — Out with the old.** The anvil at (-7, 0, -3.5) provides all six deaths, with
its existing 1 s warning and 3 s repeat. Carry body #1 to (-11.5, 0.225, 3.5), oriented
along Z. Jump onto it, then onto the 1.3 m high observation shelf centred at (-10, 0.65,
3.5), and return over ordinary floor. The originally proposed mandatory one-way entry
ledge would have prevented returning after its support was evicted and the clone respawned
at the entrance. This shelf avoids that recovery conflict; reliable routes can omit it.
Bodies #2/#3 go directly on the plate at (-7, 0, 3.5), near x=-7.95/-6.05, y=0.345.
Bodies #4/#5/#6 form the route at approximately x=-2.696/-0.159/2.237, y=0.225, z≈0.
Carry later bodies across the previously placed supports, jumping between their tops;
return across those same supports to collect the next body. The sixth creation removes
#1 while the plate and bridge contributors remain. The strip spans x=-3.2..5.2 and the
full Z width. Jump to the far bank and cross the exit at x=9. Actual result: six creations,
subject #7 completes, five retained, oldest step removed, no hidden death quota.

**Room 5 — A modest staffing budget.** Create five bodies at the warned anvil, with
no extra deaths. #1/#2 hold the plate at (-7, 0, 3.5), #3 jams the saw at x=-3 in its
partition passage, and #4/#5 form stepping supports across the strip x=-0.6..4.6. The
observed poses are plate x≈-7.95/-6.05, jam x≈-3.068, bridge x≈-0.601/1.941, z≈0.
Ferry #4 over the jam body and place from its far edge; ferry #5 over the jam and first
bridge body, then place from that support's far edge. The jam stays in place on every
return. Jump between supports and onto the broad far bank; walk through the plate-held
exit at (9, 0, 0). Peak/retained count 5, including the body held during delivery.

**Room 6 — The final experiment.** Repeat that taught five-body allocation with the
anvil at (-7, 0, 3.5), the plate at (-7, 0, -3.5), and the final exit at (9, 0, 2.5).
The mirrored supply/weight route and far-bank turn change the route without introducing
a mechanic. The exit partition has spans [-6, 1.4] and [3.6, 6], with the closed doorway
between them. Cross the final passage to reach Completion; Replay saves a fresh Room 1
while retaining audio settings. Peak/retained count 5.

The first wider route attempts produced repeatable lethal far-bank landings. Final widths
are 8.4 m in Room 4 and 5.2 m in Rooms 5–6, corrected using real standing/running jumps
without changing movement, grace, corpse dimensions or the five-body cap. Both strips
remain wider than the measured 3.000001 m unaided same-height reach. Smaller-body-count
alternatives are permitted; no allocation is enforced as an invisible exit condition.

## Trial and timing record — 2026-10-09

`test_room_solutions.gd` completes Room 1 ten times. `test_authored_walkthrough.gd`
completes Rooms 2–6 ten times each with actual movement and no diagnostic teleports.
`test_combined_rooms.gd` independently rebuilds the remaining physical arrangements ten
times using actual hazard-created bodies and real pickup/placement; only the subject is
staged with collision disabled during teleport to avoid artificial kinematic impulses.
Every completed room keeps its budget and uses a real forward crossing. Independent
empty-room checks cover centre and both edges of every spike/saw partition, plus closed
exit partitions (including Room 6's offset opening) and each combined saw.

| Room | Fresh completions | Created / retained | Scripted active ticks at 60 Hz | Simulated seconds |
| --- | ---: | ---: | ---: | ---: |
| 1 | 10/10 | 1 / 1 | 290 | 4.833 |
| 2 | 10/10 | 2 / 2 | 1,106 | 18.433 |
| 3 | 10/10 | 1 / 1 | 389 | 6.483 |
| 4 | 10/10 | 6 / 5 | 3,289 | 54.817 |
| 5 | 10/10 | 5 / 5 | 2,732–2,733 | 45.533–45.550 |
| 6 | 10/10 | 5 / 5 | 2,750–2,751 | 45.833–45.850 |

Timing begins after the fixture's 30-frame settling period and includes scripted deaths,
feedback, anvil waiting and ferrying. It excludes human planning/help and is not evidence
for the 20–30 minute first-playthrough target or a rendering benchmark. Setup: pinned
Godot 4.7.2, Linux headless, Jolt, fixed 60 Hz, isolated temporary saves. Exact per-trial
ticks/poses are emitted as `OMDB_SOLUTION` lines in the validation logs. Readability,
three-resolution review, physical-controller feel, native flow and first-time timing
remain unverified under T082/T083/T091/T095/T098–T103/T113.
