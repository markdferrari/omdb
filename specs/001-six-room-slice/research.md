# Research: Six-Room Puzzle Slice

**Date**: 2026-10-08 | **Feature**: `001-six-room-slice`

This completes Phase 0. Decisions below resolve the draft plan's runtime, physics,
asset, verification, and measurement questions. Initial tuning values are experiments
for implementation, not measured gameplay results. No game project has been implemented.

## R1. Runtime, renderer, and export baseline

**Decision:** Pin Godot **4.7.2**, standard GDScript build, Compatibility renderer
(`gl_compatibility`), and built-in **Jolt Physics**. Require matching 4.7.2 export
templates. Target Windows x86_64 and macOS Universal 2, distributed as desktop packages.

**Evidence:** `/usr/local/bin/godot --version` reports
`4.7.2.stable.official.ed1daf0bf`. Installed help supports `--import`, `--script`,
`--scene`, and `--export-release`. The default export-template directory is empty.
The inspected development host has an AMD Ryzen 5 220, Radeon 740M, and approximately
29 GiB usable RAM. This session cannot open its X11 display and exposes neither
`/dev/dri` nor `/dev/input`. No rendered benchmark or physical-controller test was run.

**Rationale:** Use the installed stable runtime and built-in physics rather than adding
an engine upgrade or physics extension dependency. Simple lighting and modest room
geometry fit Compatibility; use meshes/particles for splat effects rather than a feature
that requires another renderer. Jolt is built into this engine version and is selected
explicitly in project settings. [Renderer comparison](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html),
[Jolt configuration](https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html).

**Alternatives considered:** Forward+ adds rendering capabilities the slice does not
require. Mobile remains a possible measured renderer change. Godot Physics is a fallback
only if a reproducible Jolt problem survives simple-shape tuning; changing backend requires
rerunning all physics acceptance trials. Third-party Jolt is unnecessary.

## R2. Scene ownership and lifecycle authority

**Decision:** One persistent `Game` scene owns menus, audio, saving, and a `RoomHost`.
Each instantiated room has one `RoomController` and its `RoomState`/`CorpseRegistry`.
Keep registry decisions independent of scene nodes for repeatable tests. Room components
report events; they do not independently spawn players, evict corpses, or switch rooms.
No global event bus or autoload is needed for this six-room scope.

**Rationale:** Death, cap eviction, carrying, hazard eligibility, and restart have shared
invariants. A single mutation owner makes their ordering explicit. Every callback carries
a room epoch and subject/body identity; obsolete callbacks cannot affect a replacement
room or clone. Logical changes are immediate, while physics/scene mutations are committed
outside physics contact callbacks. This is a project design derived from the state rules.
Godot's scene guidance favours independently usable scenes and explicit dependencies.
[Scene organisation](https://docs.godotengine.org/en/4.7/tutorials/best_practices/scene_organization.html).

**Alternatives considered:** Several gameplay autoloads would distribute ownership;
letting every hazard spawn corpses would duplicate deaths. Reconstructing the room on
restart is simpler and more reliable than manually resetting every component.

## R3. Solid corpses, player movement, and contacts

**Decision:** Use `CharacterBody3D` for the live subject and one `RigidBody3D` with one
box shape for each corpse. Lock corpse rotation, permit translation and gravity, and use
zero restitution. Visual squash, poses, and effects belong under a separate visual node.
Released bodies can sleep normally, but are not permanently frozen; explicitly wake
nearby supported bodies when removing their support. The player does not apply deliberate
push impulses or inherit platform launch velocity when jumping off a body.

**Rationale:** Flat, rotation-locked props reduce accidental tipping while still allowing
stacks to fall when support disappears. Godot exposes rotation lock and freeze separately;
frequent direct transform changes on an active rigid body are discouraged. Freeze only
for the held state or a short placement transaction, and do one deliberate transform
change before returning to simulation. [RigidBody3D](https://docs.godotengine.org/en/4.7/classes/class_rigidbody3d.html).

**Alternatives considered:** Jointed ragdolls violate scope. Making released bodies static
would prevent physical settling. Full custom integration and continuously forcing settled
transforms would add complexity and hide contact defects.

**Contact decision:** A plate counts unique actors directly supported by its top surface,
plus each released corpse in a stable support chain above a contributing corpse, not every
body in a tall detection volume. Combine shallow candidate detection with a
footprint/support test. A corpse resting on a non-contributing or held corpse adds no plate
unit. A saw
holds a set of released body IDs at its jam point; it runs only when that set is empty.
Pickup/removal explicitly invalidates contributions in the same logical transaction.
Do not wait for an exit signal from a node being disabled or freed. Reconcile actual
contacts on subsequent physics steps because Area3D overlap lists update on physics
steps, not immediately after a teleport. [Area3D](https://docs.godotengine.org/en/4.7/classes/class_area3d.html).

## R4. Carrying and placement

**Decision:** Keep a held body's physics node in the room with collision layer/mask zero,
its shape disabled, and simulation frozen. Hide its world visual and show a non-colliding
visual under the player's carry anchor. The registry still contains the same body ID.
This avoids parenting an active rigid body under the moving player.

Placement uses the player's last nonzero screen-relative facing direction; no mouse
cursor, throwing gesture, or grid is required. Probe for a nearby support surface, set a
flat yaw-aligned candidate pose, check its footprint support, and test the full box for
penetration against the player, walls, and other bodies. Check reach and a clear path
from the player to prevent placement through walls. Revalidate on release against the
current physics state; an invalid result leaves the body held.

**Rationale:** The ghost and the committed pose share one validation function. A motion
cast alone cannot reject a shape already overlapping at its starting point, so include
an endpoint overlap query. Perform space queries during the physics step and queue a
release intent from input handling. [Physics space queries](https://docs.godotengine.org/en/4.7/classes/class_physicsdirectspacestate3d.html),
[Ray-casting and space access](https://docs.godotengine.org/en/4.7/tutorials/physics/ray-casting.html).

**Alternatives considered:** Grid snapping conflicts with the PRD; free dropping or
force-based throwing undermines predictable placement. Treating the preview as authority
without a release-time check permits stale placements.

## R5. Character candidate and asset workflow

**Decision:** Use **cow** as the provisional first-greybox character. Copy the selected
runtime asset into `assets/characters/cow/`; retain copies of its original and rigged
sources in `art/characters/cow/` with `.gdignore`. Record provenance in
`assets/characters/cow/SOURCE.md`. Do not modify the source project.

Read-only source inventory and GLB metadata inspection produced:

| Candidate | GLB bytes | Meshes | Primitive vertices | Triangles | Materials | Joints | Clips |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Cow | 351,196 | 31 | 4,475 | 6,540 | 10 | 7 | 20 |
| Crow | 429,484 | 40 | 5,628 | 8,152 | 10 | 7 | 23 |
| Lion | 522,528 | 61 | 6,931 | 9,670 | 9 | 7 | 23 |
| Plates | 305,472 | 19 | 3,533 | 5,464 | 7 | 7 | 23 |

All four have one skin, no embedded images, and named `Idle`, `Move`, `Hurt`, and
`KnockedOut` clips; no named `Jump` or `Carry` clip was found. Counts sum mesh primitives,
not runtime draw calls. Cow position-accessor bounds span approximately 2.085 units in Y;
these are local geometry bounds, not a validated animated world-space size.

Selected source files:

- `/home/mark/projects/streets-of-rock/assets/characters/cow-crow/runtime/cow.glb`
- `/home/mark/projects/streets-of-rock/assets/characters/cow-crow/cow.blend`
- `/home/mark/projects/streets-of-rock/assets/characters/cow-crow/runtime/cow-rigged.blend`

The inspected cow GLB SHA-256 is
`9b8227157dc6439efebccf6867ddd1faef873af46f918685cf495af3509b8909`.
Recompute it when copying, since the source can change independently.

**Rationale:** Inspection of the existing portraits shows a compact cow silhouette with
a light face and dark clothing. This is a provisional visual-fit judgment for dark rooms,
not proof of isometric readability. It is lighter than crow/lion; crow's extended wings
would require additional work to reconcile its silhouette with a compact support prop.
Plates is lighter still but has a less conventional humanoid corpse silhouette.

**Implementation consequence:** Test the cow's actual import, materials, scale, and all
four required actions at the room camera. Add or adapt jump/carry presentation and a flat
corpse pose if needed. Pause the corpse visual in its pose; never animate the physics box.
Use runtime GLB imports; retaining editable sources separately avoids requiring Blender
for every project import. [3D import formats](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).

**Alternatives considered:** Crow for gothic association, plates for cost, lion for a
strong face silhouette. Reconsider the candidate if the camera proof fails. No character
has yet been played or benchmarked in this game.

## R6. Input, UI, audio, and persistence

**Decision:** Use named InputMap actions and explicit Control focus navigation, with
screen-relative `Input.get_vector` movement. Keep gameplay and UI actions separate.
Use Music and SFX buses, normalized volume settings, and explicit mute at zero. Store
versioned progress and settings in separate local ConfigFile documents so broken progress
does not unnecessarily discard usable settings. Save temporary files and check rename
results; this protects ordinary replacement failures, not every possible power loss.

**Rationale:** The complete flow must work without a mouse. Focus needs an initial target
and a restored target after closing a submenu. Save data contains only a stable room ID
and settings, not physics nodes or transient arrangements. The exact interface and
validation rules are in [player interface](contracts/player-interface.md) and
[save format](contracts/save-format.md).
[Controller guidance](https://docs.godotengine.org/en/4.7/tutorials/inputs/controllers_gamepads_joysticks.html),
[UI navigation](https://docs.godotengine.org/en/4.7/tutorials/ui/gui_navigation.html),
[ConfigFile](https://docs.godotengine.org/en/4.7/classes/class_configfile.html),
[DirAccess](https://docs.godotengine.org/en/4.7/classes/class_diraccess.html).

**Alternatives considered:** Mouse-only menus fail the requirement. Saving room instances
or corpse transforms conflicts with fresh-room resume. Cloud saves, profiles, and input
remapping are not needed for this slice.

## R7. Verification and packaging

**Decision:** Use a project-owned GDScript `SceneTree` test runner, deterministic state
checks, scripted physics fixtures, and manual playable trials. No third-party test plugin
is needed initially. The runner has explicit failure reporting, timeout handling, and a
nonzero exit code on failure. Test saves use an injected temporary root before any I/O.

**Rationale:** Registry, lifecycle, save validation, and event ordering can be tested without
human input. Physics outcomes require scene checks, and controls/readability still require
people. Headless success cannot establish visual or native-platform acceptance.
[Command-line reference](https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html),
[SceneTree](https://docs.godotengine.org/en/4.7/classes/class_scenetree.html).

**Alternatives considered:** A plugin-based test framework can be adopted if the suite
outgrows this small runner. Manual-only validation would make duplicate-death and reset
regressions difficult to repeat. Snapshot-perfect physics across operating systems is not
required; invariant and tolerance-based outcomes are.

Export Windows x86_64 and macOS Universal 2 packages with named presets and matching
templates. Native full-flow tests remain required. For macOS, record the signing method
and test an actual downloaded package; ad-hoc export alone does not prove a friction-free
distribution experience. Do not assume signing credentials exist.
[Windows export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_windows.html),
[macOS export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html).

## R8. Initial tuning and measurement decisions

These are explicit starting hypotheses. Store them in `resources/gameplay_tuning.tres`,
record changes and measured outcomes, and rerun affected trials when changing them.
One world unit is one metre. Do not market these as measured minimum hardware requirements.

| Area | Initial value or budget | Validation that can change it |
| --- | --- | --- |
| Physics | 60 ticks/s, Jolt, physics on main thread | State/physics fixtures, ten independently rebuilt traversals. |
| Player | 4.5 m/s; 24 m/s² acceleration; 20 m/s² gravity; 6 m/s jump speed | Screen-relative traversal and landing clarity; nominal jump height 0.9 m and same-height range 2.7 m before grace effects. |
| Forgiveness | 0.10 s coyote time, 0.12 s jump buffer, 0.18 m floor snap | Broad landing trials; exclude grace from any bypass calculation only after measuring actual maximum reach. |
| Player shape | Capsule 1.5 m total height, 0.32 m radius | Fit chosen visual and paths; broad landings at least 1.2 m wide initially. |
| Corpse | Box 1.8 × 0.45 × 0.9 m (X/Y/Z); 20 kg; rotation locked; friction 1.0; bounce 0; linear damping 0.5 | Ten-trial stacks/bridges, support removal, no uncontrolled sliding. Scale visual independently. |
| Pickup / placement | 2.2 m pickup reach; preview centre 1.6 m ahead; maximum centre reach 2.2 m; bounded 0.6 m support adjustment; 0.02 m surface clearance | Surface, wall, player, occupied-body, and out-of-reach categories; no through-wall pickup/placement. |
| Support | Upward normal dot Y at least 0.95; support-height tolerance 0.04 m | Centre plus inset-corner probes must support the planned footprint; no accidental ledge balancing. |
| Camera | 45° yaw, approximately 35.3° downward angle, orthographic | Fit full room plus 10% margin; preserve view at 16:9, 16:10 and 4:3 using letterboxing when necessary. |
| Respawn / anvil | 0.6 s feedback before replacement; 1.0 s anvil warning and 3.0 s cycle | Twenty deaths each at most two seconds; warning recognition, restart cancellation, safe entrance. |
| Input | Circular stick deadzone 0.2 | Keyboard and controller trials; adjust from measured drift/comfort. |
| Character | At most 7,000 triangles, 32 mesh surfaces, 10 materials, 8 bones; runtime asset initially under 512 KiB | Cow metadata fits initial geometry/material budget; verify import surfaces and added animations. |
| Representative room | At most 100,000 visible triangles, 450 reported draw calls including shadows; one shadowed key light; at most 24 simultaneous cosmetic effect instances | Actual-camera profiling with one player and five corpses; budgets may change with documented measurements. |
| Frame target | 60 fps at 1920×1080; 95th-percentile frame time at most 16.7 ms; physics at most 4 ms at the 95th percentile | Release build, 30 s warmup plus 120 s representative play, one player/five bodies and all room hazards/effects. |

Development reference hardware is the inspected Ryzen 5 220/Radeon 740M host, once a
real graphics session is available. Release measurement targets are Windows on comparable
Radeon 740M-class hardware with 16 GiB RAM and macOS on Apple M1 with 8 GiB RAM, at the
same resolution and settings. These are chosen validation targets, not available machines
or measured results. Record actual CPU/GPU/RAM, OS, renderer, build, resolution, and any
substitution in `validation.md`; stronger hardware does not prove the intended baseline.

## Research completion

All planning questions have a chosen approach and an acceptance experiment. No scope
clarification is needed. Remaining work is implementation evidence: greybox interactions,
camera validation, jump/carry animation suitability, benchmarks, export templates, native
platform runs, and playtests. These are scheduled gates, not claims of completed validation.

## DEV-004. Observed placement precision failures

The fixed aim rejected ordinary pressure-plate edges and diagonal approaches because
inset support probes landed at two heights. A ray from 0.8 m above the player also hit
a 1.0 m raised table edge although the carried body can be lifted above it. New tests
first produced 180 failed/2,279 passed physics assertions. Bounded support projection
and a lifted transport route fix these cases while retaining continuous yaw, full endpoint
volume, 2.2 m reach, safe entrance/doorway reservations, and fresh release validation.
Nearby alternatives are needed when the closest projection touches reserved space or
another direct plate contributor. The 0.6 m assist is provisional for rendered feel;
headless regressions do not establish player acceptance or performance targets.
