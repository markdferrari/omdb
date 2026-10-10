# Research: Recognizable Hazards and Gothic Atmosphere

**Date:** 2026-10-09. **Scope:** planning experiments and source inspection only.
No production assets, gameplay scripts or room scenes were changed. Candidate selection
below authorizes the representative implementation trial; production acceptance still
requires the playable gate in [plan.md](plan.md).

## R1. Free assets before custom models

**Decision:** Trial KayKit Dungeon Pack Free 1.1 as the dominant chamber/spike kit,
Lucian Pavel's Iron Anvil as the anvil, and Sam Jessup's Saw blade Version 1 as the wheel.
All three have CC0 evidence. No new trap model needs to be made from scratch initially.
Use the current cow and existing game feedback. Custom work is limited initially to
adaptation, hazard boundary markings and experiment signage; reconsider model authoring
only if a documented representative trial fails.

**Rationale and alternatives considered:**

| Candidate | Evidence and coverage | Fit, adaptation and decision |
| --- | --- | --- |
| [KayKit Dungeon Pack](https://kaylousberg.itch.io/kaykit-dungeon-pack), Free 1.1 | Local archive: 211 glTF files, CC0 License.txt, separate spike mesh and architecture/floor/door assets. | Preferred trial. Supplied sample image shows readable chunky stone divisions and arched masonry. Recolour/reduce warm medieval furnishings, add ink accents and testing signage. Import a curated subset, not the entire catalogue. Player-camera fit remains unverified. |
| [Kenney Modular Dungeon Kit](https://kenney.nl/assets/modular-dungeon-kit), 2.1 | Downloaded archive to temporary storage; License.txt confirms version/CC0; modular corridor, gate and metal-bar models. | Viable fallback environment. Whole corridor modules are less convenient for skinning existing open puzzle footprints than separate KayKit parts. Do not rebuild layouts around the kit. Moderate adaptation effort; no reason to mix both primary styles initially. |
| [Kenney Graveyard Kit](https://kenney.nl/assets/graveyard-kit), 5.0 | Downloaded archive; supplied version/CC0 text; walls, pillars, candles and graveyard props. | Reject as the primary environment: its graveyard props do not supply the experiment-room vocabulary as directly. Optional fallback for a specific gothic decoration after a demonstrated gap. |
| [KayKit Platformer](https://kaylousberg.itch.io/kaykit-platformer), Free 1.0 | Local archive: 370 glTF files; CC0 text; no spike/saw/anvil/trap-named files. Publisher places spike traps and sawblades in paid EXTRA. | Reject as the main kit and free trap source: bright platformer pieces require more stylistic adaptation, and the relevant advertised traps are paid. |
| [Quaternius Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html) | Publisher distinguishes free runtime subset from paid Source/Godot scenes. Not downloaded in this planning pass. | Reserve supplemental workshop candidate; free anvil coverage remains unconfirmed. Prefer the exact free anvil already inspected. |
| [Low poly iron anvil — Lucian Pavel](https://opengameart.org/content/low-poly-iron-anvil) | Creator page dated 2016-11-11 identifies CC0. Archive contains Iron Anvil.fbx and diffuse/specular images; 258 triangles confirmed in Blender. | Preferred anvil trial. Preview has face, horn, waist and foot; worn texture is more realistic than KayKit. Use restrained shared metal treatment and normalize pivot/scale. Low geometry adaptation effort. Archive has no licence text: retain dated source-page licence evidence with the source record. |
| [Sawblade — Fluxcapacimator](https://opengameart.org/content/sawblade) | Creator page identifies CC0; archive readme identifies Sam Jessup, Version 1, CC0. Contains sawdisc.blend and sawdiscao.png. Mesh inspection reports 140 triangles. | Preferred wheel trial. Export mesh only, normalize axle, add a readable hub/support wrapper if required. Legacy Blender material and AO paths require repair/replacement; no original game behavior is imported. |

These comparisons satisfy the planning comparison of at least three plausible free
packs. The original [candidate notes](asset-candidates.md) are retained as the discovery
record; this research supersedes their unresolved anvil/saw search, not their unverified
playable status. The [older Godot library package](https://godotengine.org/asset-library/asset/2126)
is Dungeon Remastered 1.0; use the inspected Free 1.1 archive as the source of truth.

### Archive identities

KayKit archives were supplied in the workspace; their original download date/origin was
not observed. Other archives were obtained from the creator/publisher links during this
planning pass on 2026-10-09. Temporary files are research inputs, not runtime dependencies.

| Archive | SHA-256 |
| --- | --- |
| KayKit_Dungeon_Pack_1.1_FREE.zip | `6acb859d1aefae074f937d1e6f13656a7312b2bdb6d9f1232ebdade8d93d6a1c` |
| KayKit_Platformer_Pack_1.0_FREE.zip | `7e140ee01abf99a5896cf93a02ff3dc6a23a7222109fd04854821f44a3a3adeb` |
| Kenney Modular Dungeon Kit 2.1 (`dungeon.zip` in research) | `dd0aa6776db8912283cdca60161dee6a8839bbda3558eba2ea501419eb5b4623` |
| Kenney Graveyard Kit 5.0 (`graveyard.zip`) | `1a93613f2e5675f3310acf49ec9ef13ae7adeb756ac3b205bfb6cc9311a81062` |
| Iron Anvil Low poly.zip (`anvil.zip`) | `ca277c6420f38ac02e66cc98cbecea7dce7c41d67f9e777efc2fa2668339d691` |
| sawblade.zip | `cda4a17891df5727d512dcfbb0485deddf0a76e25fabbfb045addce678b709c1` |

## R2. Runtime format and source retention

**Decision:** Use curated glTF/GLB assets with all referenced buffers/textures. Retain
vendor originals, supplied licences and adaptation sources under ignored-from-import
`art/`; put only runtime exports under `assets/`. Use Blender 5.2.2 LTS
(`d13f752e3b9c`, locally verified) for the FBX/legacy Blender normalization/export.
Routine project import must work without Blender. No third-party runtime plug-in.

**Rationale:** Godot recommends glTF and supports separate buffers/textures; direct
Blender import invokes Blender as a dependency. Wrapper scenes keep project materials,
pivots and visual controls outside vendor files. Source files are loaded with automatic
script execution disabled; exported visuals have no scripts, physics, cameras or lights.
[Godot formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html),
[import configuration](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/import_configuration.html).

**Alternatives considered:** Wholesale Godot asset-library installation adds unused
content and does not guarantee the current pack version. Direct .blend runtime imports
create unnecessary authoring-tool dependencies. Rebuilding the three trap meshes is
unnecessary unless the trial records a concrete failure.

## R3. Measured source complexity and import experiment

**Decision:** Start with these inspected pieces and retain the existing whole-room
budgets. Import only models actually used by the representative chamber.

| Source file / mesh | Triangles | Surfaces/material slots | Observation |
| --- | ---: | ---: | --- |
| floor_tile_big_spikes.gltf / base | 530 | 1 | Bounds 4 × 0.200004 × 4 m; top near Y=.1. |
| floor_tile_big_spikes.gltf / spikes | 108 | 1 | Separate mesh, bounds 2.2 × 2 × 2.2 m; original spikes are much too tall. |
| floor_tile_large.gltf | 188 | 1 | Candidate floor skin, align to existing surface. |
| wall.gltf | 494 | 1 | Candidate perimeter stone. |
| wall_arched.gltf | 724 | 1 | Candidate gothic motif. |
| wall_doorway.gltf | 1,068 | 2 | Candidate exit surround; adapt to existing clear opening. |
| wall_pillar.gltf | 540 | 1 | Use sparingly, subject to cutaway. |
| torch_mounted.gltf | 278 | 1 | Optional unlit/emissive fixture, no new shadowed light. |
| banner_white.gltf | 97 | 1 | Candidate experiment-sign backing. |
| Iron Anvil.fbx | 258 | 1 | Blender dimensions .958329 × .520326 × .452633 m, Z-up. |
| sawdisc.blend / BezierCircle | 140 | 1 | Blender dimensions 2.4581 × 2.4581 × .06354 m; disc in XY plane. |

KayKit counts came from glTF accessors; supplemental Blender counts describe source mesh
data before any evaluated modifiers or export conversion. A temporary Godot 4.7.2 project loaded the spike
scene and confirmed its two mesh counts/bounds without collision objects. The editor
import emitted sandbox local-socket diagnostics despite exit zero; subsequent scene load
was clean. This is resource-load evidence, not a strict clean-import pass. Blender opened
both supplemental models and printed the listed metrics with auto-execution disabled;
legacy UI conversion/audio shutdown diagnostics occurred, and processes were interrupted
after metrics. Clean conversion/import is an implementation acceptance task.

The supplied KayKit room sample and anvil preview were visually inspected. They justify
trying the silhouettes and palette adaptation; they do not establish in-game readability.
No rendered benchmark or interactive playtest ran during planning.

## R4. Preserve collision and truthful hazard boundaries

**Decision:** Keep hazard owner nodes/IDs and all physical shapes intact. Add cosmetic
children driven from authoritative state. Exact envelopes and calls are in
[contracts/presentation.md](contracts/presentation.md).

- Spikes must be shallow/recessed: support top Y=0, lethal top Y=.17. Extract/adapt the
  separate spike mesh, fit tips initially at Y=.16, and distribute within the authored
  footprint. Never raise collision to fit the stock two-metre spikes.
- The saw rotates about local X in the YZ plane. Its existing lethal box is rectangular;
  a visible machinery danger track marks the full corridor while the wheel supplies the
  recognizable object. A stopped route remains unobstructed.
- The anvil has a bottom-centered pivot and a square warning outline matching its 2×2 m
  footprint. Drop/return visuals derive from the owner's cycle; no animation event kills
  the player or applies impulses to corpses.

**Rationale:** Current SpikeBed code assumes BoxMesh during resizing; imported visuals
must be decoupled from that path. Current saw orientation and circular anvil marker are
insufficient guides for the actual contact regions. Stable gameplay already has repeatable
solution evidence and must not be redesigned to accommodate a purchased/downloaded model.

**Alternatives considered:** Per-tooth/spike collision and physical falling anvils change
support/lethality and can break solutions. Independent animation timers can display stale
states after jam, pause or restart. Both are rejected.

## R5. Chamber architecture, palette and cutaways

**Decision:** Share one reusable cosmetic chamber layer, parameterized for existing
16×12 and 24×12 m rooms. Use slate stone, charcoal iron, pale bevel/wash accents, subdued
violet background and the established pink/green gameplay highlights. Retain readable
neutral floor value and yellow landing/warning cues. Use one shadowed directional key
and simple ambient/background treatment; no fog, bloom or new dynamic-light system is
required. Small material adjustments follow rendered review.

**Rationale:** Source preview supports chunky modular architecture; clutter, treasure,
weapons and furniture imply unwanted mechanics and obscure routes, so omit them. Existing
camera code hides only immediate MeshInstance3D children. Register cosmetic roots by
perimeter side and toggle their whole nested subtree from the same selected-view state;
keep physical walls active. Persistent low boundary trim must make hidden walls legible.

**Alternatives considered:** High opaque arches across routes, arbitrary prop scattering,
multiple visual styles and automatic camera zoom would compromise current camera/route
contracts. Compatibility renderer remains selected; avoid unsupported effects.
[Godot renderer overview](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).

## R6. Batching and performance targets

**Decision:** Retain current acceptance targets: 100,000 visible triangles, 450 draw calls
including shadows, one shadowed light, 24 cosmetic fragments; 60 FPS with p95 frame time
≤16.7 ms and p95 physics time ≤4 ms at 1920×1080 after 30 s warmup, over 120 s capture.
Use Windows Radeon 740M-class/16 GiB and macOS M1/8 GiB targets. The inspected Linux host
is Ryzen 5 220 with Radeon 740M and about 29 GiB available system RAM capacity; it is a
development reference, not native-platform evidence.

**Rationale:** Existing tuning and greybox evidence establish the baseline; six cow
visuals can consume up to 42,000 triangles under their existing per-character cap.
Allocate initially ≤45,000 triangles to new environment/hazard artwork, ≤12,000 of that
to spikes, and ≤60 added draw calls including shadows. These are conservative allocation
hypotheses informed by the inspected low-poly meshes, not measured rendered performance.
Reduce decorative density and batch repeated floors/spikes by mesh/material and cutaway
side before requesting budget changes. MultiMesh can reduce repeated-instance submission,
but visibility is per batch, so never combine opposing wall cutaway groups.
[Godot MultiMesh guidance](https://docs.godotengine.org/en/stable/tutorials/3d/using_multi_mesh_instance.html).

**Alternatives considered:** Increasing budgets without measurements, interpreting headless
FPS as render speed, or testing only stronger hardware provides no evidence for the target.
Implementation must profile an undecorated baseline and the same populated dressed scene
with identical capture conditions; any budget revision requires recorded evidence.

## R7. State, recovery and test strategy

**Decision:** Reuse RoomController, hazard owners and existing state/physics/recovery
runner. Add focused checks for imported visual isolation, envelopes, anvil phase alignment,
saw jam motion, nested cutaways, and material/resource presence. Existing authored solutions
run ten times each. Human checks cover the 72 view/window combinations, five-player
recognition/atmosphere evaluation, and four native platform/input combinations.

**Rationale:** Headless state checks catch visual-induced state regressions but cannot
prove recognizable hazards or atmosphere. Existing JUMP-01 evidence records release drift
≤.133334 m and maximum reach 3.000001 m; retain current movement/placement values rather
than retune for artwork. Save files need no new fields because presentation reconstructs
from authored content and current gameplay state.

**Alternatives considered:** Snapshot screenshots alone do not cover physics or recovery;
manual-only checks lose repeatability. Both kinds of evidence are required.

## Research resolution

All design questions have a selected approach and an acceptance experiment. Remaining
unknown outcomes—import cleanup, recognition, control feel and native performance—are
explicit implementation gates, not unresolved scope decisions. The real Git branch is
`main`; setup-plan's `BRANCH=002-improve-hazard-art` is its feature-directory fallback.
Before-research constitution review passed: the spec bounds the slice, preserves state,
requires four-view/input/recovery checks and gates rollout on representative proof.
