# Presentation Contract

**Date:** 2026-10-09 | **Plan:** [plan.md](../plan.md)

This defines the player-visible interface and the owner-to-visual integration boundary.
The [existing gameplay contract](../../001-six-room-slice/contracts/gameplay-state.md),
[player controls](../../001-six-room-slice/contracts/player-interface.md) and
[save format](../../001-six-room-slice/contracts/save-format.md) remain authoritative.
No network API or new save interface is introduced.

During the representative trial, optional cosmetic scene assignments select the new
wrappers only in `tests/scenes/art_validation.tscn` and its room fixture. Production
defaults adopt them after the plan's Stage B gate. The candidate chamber assembly is
`scenes/art/gothic_chamber.tscn`; the accepted shared dressing entry point remains
`scenes/art/room_dressing.tscn`. This staging does not add gameplay or persistence state.

## C1. Ownership and isolation

RoomController remains responsible for registry, death/carry transactions and contact
reconciliation; each hazard retains its current identity and relevant state. Hazard roots
remain direct room children so ownership checks continue to work. Visuals read state and
never call lethal handlers, write registry/carry/plate state or apply impulses.

Every imported/adapted visual is beneath a cosmetic Node3D root. Its subtree contains no
CollisionObject3D, CollisionShape3D, Area3D, character controller, vendor script, camera or
light. No imported name suffix may generate collision. Static art and animation have no
physical support role. Existing World=1, Player=2, Corpse=4 and Sensor=8 layers are retained.

Shared base materials are immutable. Per-instance state styling cannot change a different
saw or room. Visual initialization reads current state, including a room created with a
known fixture arrangement. Cosmetic updates run with gameplay pause and retire with the
room; no free-running timer or retained callback can restore an earlier warning/jam.

## C2. Spikes

Preserve the existing support and lethal boxes; `bed_size` remains the authored dimension
source. The visual configuration accepts `Vector2 bed_size` independently of mesh type.
It must work for the default 3.6×11.9 m, 2×2 m supply bed, 8.4×11.9 m Room 4 route and
5.2×11.9 m combined-room routes, including source and exported instances.

| Element | Existing local envelope |
| --- | --- |
| Solid bed | X/Z from bed_size; height .2 m centered Y=-.1; top Y=0. |
| Lethal sensor | Same X/Z; height .16 centered Y=.09; vertical range .01–.17. |
| Visual target | Spike tips initially Y=.16, never above .17; base aligned/recessed at the support surface. |

Use the separate KayKit spike mesh as adaptation input; its stock 2 m height is invalid
for this contract. Adjust height/spacing and repeat within the bed with clipped/omitted
edge instances rather than stretching the hazard root. The bed outline identifies the
entire dangerous footprint, including decorative spaces between spikes. Floor skins must
not suggest safe walking lanes through that footprint. A body route must visibly cover
its underlying danger without protruding spikes above the body's usable top.

The existing physical sizing path must stop assuming that the visual is a BoxMesh.
Automated checks compare final shapes to authored dimensions and verify visual extents;
playable checks decide whether shallow points still read as spikes.

## C3. Bladed wheel

Preserve lethal box (.7,1.8,2.4) centered at (0,.9,0), and jam box (.5,.7,2.4) centered
at (0,.35,0). The rotor has no solid collider. Eligible released-body contributors alone
control `jammed()`; there is no timeout.

The visual wrapper accepts `set_jammed(jammed: bool, contributor_count: int)` from the
owner and rotates only its rotor while active. Use local X as the axle, wheel in YZ,
center Y=.9 and initial outer radius .85 m, including teeth. Normalize source disc axes
and center before export. Keep total visual thickness inside X±.35; begin with ≤.16 m.
The initial active angular speed is the established 9 rad/s.

A circular wheel does not represent the corners of the rectangular contact area. Add a
clear machinery danger track/frame matching X±.35 and Z±1.2 on the floor, plus readable
active/jammed text or symbol. It must not resemble a physical barrier when the saw stops.
Jamming stops motion immediately and retains the cue; removing the final eligible body
restores motion and danger immediately. One remaining contributor retains the jam.

Acceptance includes muted audio, colour-independent cues, two differently staged saw
instances, body pickup/eviction, passage through the stopped route and reactivation while
the player is already in the danger region. Visual model changes cannot alter those outcomes.

## C4. Anvil cycle

Preserve the live-only impact box 2×2×2 m centered Y=1: X/Z ±1 and Y=0–2.
Warning remains 1 s and cycle 3 s. The owner strikes once at phase ≥1 s in each cycle;
visual animation does not trigger or delay that query. Corpse props receive no impulse.

Use a bottom-centered normalized anvil, initially 1.8 m along its longest horizontal
axis, with horn/face/waist/foot visible and both horizontal extents within the 2×2 footprint.
The wrapper accepts the authoritative cycle phase and timing values; pose is a function
of that phase rather than an independent AnimationPlayer completion or timer.

| Phase within current 3 s cycle | Visual behavior |
| --- | --- |
| 0–.85 s | Suspended, bottom Y=2.7; square footprint and warning/countdown visible. |
| .85–1 s | Short cosmetic descent while the existing warning remains active. |
| At 1 s | Bottom reaches Y=0 on the same owner update that performs the strike. |
| 1–1.2 s | Brief impact pose; footprint/state indicates reset rather than a new strike. |
| 1.2–2.2 s | Return to suspended bottom Y=2.7. |
| 2.2–3 s | Suspended/resetting until the next warning starts. |

The .15 s descent is an initial presentation choice within the unchanged one-second
warning; validate it at real frame rates. For a phase skipped by a long frame, choose the
correct current pose without replaying missed impacts. Square outline/markings show the
actual footprint; any outer decorative glow is visually secondary. Existing sound cues
remain tied to owner events and are not duplicated by the wrapper.

## C5. Chamber and camera

Cosmetic floor skins follow existing floor height (top within .005 m of the support plane)
and do not draw across danger markings or imply steps, pits or new support. Existing
plate top/footprint and door opening/blocker geometry remain unchanged. Exit framing and
state cues persist while open. Entrance decoration uses a closed hatch/grate at the safe
spawn and does not suggest a fall-through hole.

RoomCameraViews retains its authored transform, 90° view cycling, direct selections and
screen-relative movement. Each perimeter side registers one cosmetic root plus its
persistent low boundary trim. Toggle the entire nested root on view change; apply the
initial view explicitly even if the initial signal occurred before registration. The
existing dot-product near-side rule remains valid. Collision siblings are never hidden,
disabled or scaled by this operation.

Keep opposite sides in separate MultiMesh batches. Internal gate garnish must not hide
player, bodies or labels; simplify or cut away that garnish without hiding live door/saw
state. Camera changes never alter the room snapshot, contact sets, support or save data.

Required visible information: live/held/released bodies, placement valid/invalid cue, ground
shadow, yellow airborne surface ring, body count/oldest marker, plate requirement/current
state, saw state, anvil warning and open exit. Neon accents and signage must not compete
with these. No new player input is required.

## C6. Asset adoption and delivery

Before production adoption, every runtime file has an AssetRecord with archive/file
identity, creator/source, free-edition evidence, licence, credits, modifications and exact
runtime dependency closure. Preserve vendor originals and editable adaptations under
`art/`; export only selected models/materials/textures and necessary licence/credit records.
Maintain attribution even when optional as project provenance. Do not claim paid vendor
Blender sources are included in the free KayKit edition.

Clean imports must reject missing buffers/textures, unsupported materials, generated
colliders and script/resource errors. Wrapper scripts must load in source and compiled
packages. The trial-selected sources remain provisional until Stage B acceptance; any
custom replacement requires its documented coverage/suitability gap.

## C7. Evidence and regression obligations

Extend existing tests for visual subtree isolation, all spike-size overrides, saw axle and
state motion, anvil phase/impact agreement, nested cutaways and independent instance state.
Keep existing deaths/carry/FIFO/placement/support/room solution/recovery tests active.
Record ten fresh trials for affected state/physical scenarios. Do not count an asset preview
or headless geometry test as a recognition or playable-frame acceptance result.

Player reviews use the exact spec thresholds and window matrix. Native builds must retain
all selected assets/credits and complete existing flows on both input methods. Unrun checks
remain UNVERIFIED; acceptance defects require correction and affected retests.
