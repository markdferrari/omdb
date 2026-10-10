# Implementation Plan: Recognizable Hazards and Gothic Atmosphere

**Branch:** `main` | **Feature:** `002-improve-hazard-art` | **Date:** 2026-10-09
**Spec:** [spec.md](spec.md)

**Input:** `specs/002-improve-hazard-art/spec.md`

**Status:** Phase 0 research, Phase 1 design and [task generation](tasks.md) complete.
Phases 1–3 implementation through T021 has passed automated checks; T022 human playable
acceptance remains unverified. Phases 4–6 have not run. Setup returned the feature identifier
as `BRANCH`; actual Git branch is `main`. No branch hook is configured.

## Summary

Trial a curated subset of KayKit Dungeon Free 1.1 for stone chambers and spikes, Lucian
Pavel's CC0 Iron Anvil, and Sam Jessup's CC0 Saw blade Version 1. Normalize these assets
into cosmetic scenes that consume existing hazard state. Fit artwork to established
collision and authored room footprints. Prove one chamber with the reused cow and five
corpses, then apply its accepted treatment to the six-room sequence.

The intended atmosphere is chunky gothic stone, dark iron machinery, ink-like surface
accents, subdued violet surroundings and selective experiment signage. Existing neon
feedback remains prominent. [Research](research.md) records free-pack comparisons, exact
archive identities, measured source geometry and alternatives.

## Technical Context

**Language/Version:** GDScript; Godot **4.7.2.stable.official.ed1daf0bf**, locally verified.
Retain Compatibility rendering and built-in Jolt at 60 physics ticks/s. Match export templates.

**Primary Dependencies:** Godot built-ins; current cow GLB; selected CC0 models. Blender
**5.2.2 LTS, d13f752e3b9c** is the inspected authoring/conversion tool, not a runtime or
routine import dependency. Python 3.12 supports existing development checks. No new plug-in.

**Storage:** Existing local current-room/settings documents; no save schema change or
saved artwork state. Provenance is a development manifest plus licences/source files.

**Testing:** Existing state/physics/recovery runner, targeted visual integration checks,
playable representative scene, 72 room/view/window reviews, five-player evaluation,
ten solutions per room and four native platform/input runs. See [quickstart.md](quickstart.md).

**Target Platform:** Windows x86_64 and macOS Universal 2; complete keyboard/controller flow.

**Project Type:** Single Godot 3D puzzle-platformer; one active room at a time.

**Performance Goals:** Retain 60 FPS, p95 frame ≤16.7 ms and p95 physics ≤4 ms at 1920×1080,
30 s warmup plus 120 s capture, one player/five corpses, all relevant traps and effects.
Target Windows Radeon 740M-class hardware/16 GiB and macOS M1/8 GiB. Inspected development
host is Linux Ryzen 5 220/Radeon 740M with about 29 GiB RAM capacity. Targets are not measured
achievements or advertised minimum requirements. Record exact OS/GPU/driver/build and
capture conditions; stronger hardware does not establish baseline acceptance.

**Tuning and Asset Budgets:** Preserve `resources/gameplay_tuning.tres` and the established
physical envelopes in [presentation contract](contracts/presentation.md). Key values:

| Area | Selected value | Evidence / acceptance |
| --- | --- | --- |
| Movement | Speed 4.5 m/s; ground acceleration 24; air acceleration 42; air braking 60 m/s²; jump 6 m/s; gravity 20 m/s² | Existing JUMP-01 measured release drift ≤.133334 m and reach 3.000001 m. Regressions retain these. |
| Forgiveness | Coyote .10 s; jump buffer .12 s; floor snap .18 m | Existing authored routes and jump checks. |
| Corpse | 1.8×.45×.9 m, 20 kg, locked rotation, friction 1, bounce 0, damping .5 | Stable support and ten-trial traversals. Visual normalization never changes this shape. |
| Placement | Pickup/release reach 2.2 m, preview 1.6 m, assist .6 m, clearance .02 m, support tolerance .04 m | Existing placement and invalid-release checks. |
| Camera | Small room (12,12,12), ortho size 21; wide room (16,16,16), size 28; authored pitch ≈35.3°; four 90° yaw steps | CAM-02; no art-driven zoom/tilt changes. |
| Trap timing | Anvil warning 1 s / cycle 3 s; respawn .6 s; saw 9 rad/s while active | Owner-driven visuals; contract specifies phase mapping. |
| Cow ceiling | 7,000 triangles, 32 surfaces, 10 materials, 8 bones, 512 KiB per runtime asset | Existing inspected cow budget; one player plus five corpses. |
| Whole room ceiling | 100,000 visible triangles, 450 draw calls including shadows, one shadowed key light, 24 effect fragments | Existing provisional budgets; verify with rendered capture. |
| New art allocation | ≤45,000 triangles total, including ≤12,000 spike triangles; ≤60 added draw calls including shadows | Initial allocations based on inspected models and six-cow allowance; optimize density/batching before revising. |
| Textures | One shared 1024² dungeon atlas; supplemental trap textures at most 512² each where retained | Avoid importing all recolours/unused maps; use shared metal materials where appropriate. |

Asset allocations are explicit starting hypotheses, not benchmark results. Measure baseline
and dressed versions with identical conditions. Budget revisions require recorded evidence
before the representative gate passes. Exact imported counts and visual transforms are
recorded in the asset manifest after normalization.

**Constraints:** Five bodies; independent corpse collision; unchanged hazard rules and
support; four diagonal orthographic views; fresh recovery; existing controls and audio.

**Scale/Scope:** Presentation polish for six existing rooms and three existing hazard
families. One reused character. No room redesign, new hazards, purchases or lighting system.

## Constitution Check

Design compliance was reviewed before research and after design. PASS here does not mean
playable acceptance. Outstanding historical human checks remain explicitly unverified.

| Principle | Required evidence | Before research | After design |
| --- | --- | --- | --- |
| I. Focused Six-Room Slice | Scope and intended solutions within five bodies | PASS: spec scope and US3 retain teaching sequence. | PASS: cosmetic integration, existing solutions, staged rollout and VR-006. |
| II. Reliable Corpse Physics and State | Single ownership, lifecycle and support | PASS: FR-006/011–013 and EC-01–04/07 preserve invariants. | PASS: visual subtree isolation and authoritative state/phase contract; no new persistence or physics. |
| III. Readability and Controls | Four views, landing/placement and state cues | PASS: FR-008–010 and VR-004/005 require direct review. | PASS: nested cutaway groups, exact danger boundaries, 72-case matrix and recognition criteria. |
| IV. Complete Flow and Recovery | Input, restart/save and platforms | PASS: US3 and VR-006 cover all affected flows. | PASS: reconstruction from gameplay state, existing input/save contract and native matrix. |
| V. Prove Before Expanding | Representative asset/interaction gate | PASS: FR-018 requires proof before rollout. | PASS: Stage B gates six-room art rollout; reference prior evidence without marking missing checks passed. |

The earlier user authorization to continue development beyond the original greybox
scheduling boundary remains recorded in feature 001. It is not retrospective test evidence.
This plan's representative art gate protects the new rollout and does not invalidate the
already authored rooms. No constitutional amendment or exception is required.

### Verification and Evidence

- **State regressions:** Existing death/carry/FIFO/contact/recovery suites plus art isolation,
  bounds, phase/state synchronization and nested-cutaway checks. Ten repetitions for affected
  state scenarios; no empty or diagnostic-contaminated success summaries.
- **Playable validation:** Rebuild representative bridges/stacks and placements ten times;
  inspect five bodies, all hazards, muted warnings and both input methods. Maintain valid and
  invalid placement categories and eviction in carried/support/plate/saw roles.
- **Asset check:** Current cow/source provenance remains in `assets/characters/cow/SOURCE.md`.
  Review live, jump, carry, hurt/death and collapsed poses against the new palette and support
  geometry. Existing missing dedicated jump/carry clips remain an assessment item. Reuse
  source assets under `art/characters/cow/`; do not select a new character.
- **Input/platform matrix:** Windows/keyboard, Windows/controller, macOS/keyboard,
  macOS/controller. Full flow, settings/mute, restart, resume, completion and replay.
- **Evidence:** This feature's `validation.md` during implementation, asset manifest and
  source records. Link existing `specs/001-six-room-slice/validation.md` and room solutions
  by scenario; never claim a historical run was performed against the new artwork.

## Project Structure

### Documentation (this feature)

```text
specs/002-improve-hazard-art/
├── spec.md
├── asset-candidates.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/presentation.md
├── quickstart.md
└── checklists/requirements.md
```

`tasks.md` contains 55 dependency-ordered actions. `validation.md` and asset acceptance records are
created during implementation. Their absence now does not imply completed checks.

### Source Code (repository root)

Existing paths are extended; paths marked new are planned, not delivered by this command.

```text
assets/art/                              # new curated runtime assets + provenance manifest
├── kaykit_dungeon/                      # glTF + buffers/atlas, licence and SOURCE.md
├── iron_anvil/                          # normalized GLB, SOURCE.md and licence evidence
└── sawblade/                            # normalized GLB, readme/licence and SOURCE.md
art/hazards/                            # new retained originals and adapted Blender sources
scenes/art/
├── room_dressing.tscn                   # shared cosmetic chamber assembly
├── hazards/{anvil,spikes,saw}_visual.tscn # new normalized visual wrappers
└── props/                              # new curated decorative wrappers
scripts/art/                            # new small visual controllers, tiling and cutaway groups
resources/materials/                    # shared stone, ink and metal treatment
scenes/hazards/                          # keep existing root IDs/owners/shapes
scripts/hazards/                        # consume visual wrappers from existing state
scripts/rooms/room_camera_views.gd       # nested cosmetic-root cutaway support
scenes/rooms/room_01.tscn ... room_06.tscn
scenes/puzzle/                          # cosmetic plate/exit skins
scenes/player/ and scenes/corpses/       # existing visual/physics separation
scripts/checks/                         # existing strict wrapper; add asset inspection checks
tests/physics/                          # extend/add focused visual-state/bounds/cutaway checks
tests/scenes/art_validation.tscn         # new representative playable launcher
```

**Structure Decision:** Source art stays beneath the existing `art/.gdignore`; runtime
models and their import options are versioned separately. Keep licences/credits with
adopted files. Do not install vendor game scripts, generated colliders, cameras or lights.
Use small typed visual controllers and shared scenes/materials, not a second gameplay
state machine or general asset-management framework. Data-model entities are logical
records realized through scenes, resources and a development manifest.

### Runtime design

**Staged adoption:** During Stages A/B, expose optional cosmetic scene assignments on
the existing hazard/puzzle owners and select them only in the art-validation fixture.
Keep the new chamber assembly in `scenes/art/gothic_chamber.tscn` until Stage B passes;
then adopt it through `scenes/art/room_dressing.tscn` and the six authored rooms. Default
assignments switch during Stage C. This prevents shared scene edits from silently applying
trial art throughout production before the representative gate. These assignments affect
presentation only and introduce no player setting, new save field or gameplay mode.
Candidate stone/ink materials use separate `art_stone.tres` / `art_ink.tres` resources so
trial palette changes do not affect existing production dressing before the gate.

Hazards remain direct room children with unchanged `hazard_id`, shapes and contact
ownership. `SpikeBed` configures its physical shapes from `bed_size` and separately asks
its visual wrapper to fit that footprint; remove the BoxMesh assumption from visual sizing.
`Buzzsaw` drives a local-X rotor and jam indication from actual contributor eligibility.
`FallingAnvil` supplies its authoritative phase to the visual wrapper every physics update.
Cosmetic animation cannot report death, modify registry state or apply physical impulses.

The chamber layer fits the actual 16×12 or 24×12 floor, with skins aligned to existing
walkable height and cutouts/contrasting boundaries at trap regions. Preserve current floor,
wall, gate, plate and door solids. Use closed grate artwork for the entrance hatch without
implying an unsupported hole. Preserve plate requirement text and door-open cues.

Perimeter visual groups are registered by side; hide the full nested cosmetic root for
camera-facing sides while retaining low boundary trim. Internal gates keep their state
cues and safe route visible. Connect once to `view_changed`, apply the current view on
initialization, and retire with the room. Batch repeated floor/spike instances by material;
keep opposing cutaway sides in separate batches. Nothing cosmetic writes save data.

## Delivery Stages

### Stage A — Curated import and hazard proof

Copy only selected files and dependencies, verify archive identities, retain licences and
sources, normalize pivots/materials and export trap GLBs. Add manifest/import checks.
Implement visual wrappers and exact-footprint markings from the contract. Extend focused
regressions for each owner-to-visual relationship, all spike sizes and collision isolation.

**Exit:** Strict clean import and automated checks pass; every adopted file has provenance.
Geometry/state correctness is established. Visual recognition is still pending Stage B.

### Stage B — One representative chamber

Build `art_validation.tscn` using actual production components, the reused cow, all three
hazards, plate/door, carry/placement and support routes. It is a test launcher, not room 7,
and uses isolated saves. Include the shared stone/iron treatment, nested cutaways, hatch,
exit and signs. Settle material values and spike density in all four views at all three
specified windows. Record baseline versus dressed performance.

**Exit:** VR-002 ten-trial interactions pass with keyboard and controller; affected outstanding
character/readability checks have evidence; five-reviewer recognition/atmosphere criteria
SC-001/002/004 pass; selected assets and budgets are accepted. Missing display/controller/
reviewers leave these outcomes unverified and block six-room art rollout, while independent
asset/regression work can continue. No additional permission ceremony is introduced.

### Stage C — Six-room rollout

Reuse accepted shared wrappers and skin each authored footprint without changing layout,
progression, camera or tuning. Apply plate/exit/hatch consistency. Run ten solutions per room
and focused state/recovery regressions; review all 72 room/view/window combinations in fresh
and representative populated states. Fix occlusion and misleading danger boundaries.

**Exit:** SC-003/005 pass, all hazard occurrences upgraded, no presentation-induced puzzle
failure, source and exported geometry agree. No missing acceptance check is marked passed.

### Stage D — Native and playtest acceptance

Export production packages using matching templates, verify included runtime assets and
credits, perform all four native input/platform flows and profile both target classes.
Record five-player findings and full-playthrough metrics against the existing duration
objective. Fix acceptance defects and recheck affected cases.

**Exit:** SC-006/007 and all remaining criteria pass. Publishing is outside this planning task.

### Requirement-to-design coverage

| Requirements | Design | Evidence |
| --- | --- | --- |
| FR-001–006 | Normalized trap wrappers, exact envelopes, authoritative phase/jam state | VR-002–005; SC-001/002/005 |
| FR-007–010 | Chamber treatment, nested cutaways, cue hierarchy | VR-002/004/005/007; SC-003/004 |
| FR-011–013 | Cosmetic isolation, existing room/state/input/save ownership | VR-003/006; SC-005/006 |
| FR-014–017 | Free-pack comparison, curated sources, provenance and gap decisions | VR-001/008; SC-007 |
| FR-018 | Representative scene and Stage B gate | VR-002/005/007/008; SC-001/002/004 |

## Complexity Tracking

No constitution conflict or exception. Integration risks have compliant resolutions:
shallow adapted spikes preserve support; explicit danger tracks describe rectangular saw
contacts; phase-driven anvils preserve timing; nested visual groups preserve cutaways.
No new physics framework, state persistence or renderer dependency is proposed.
