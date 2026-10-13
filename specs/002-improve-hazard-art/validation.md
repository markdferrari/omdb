# Hazard artwork implementation evidence

Date: 2026-10-09. Scope requested: Phases 1–3, T001–T022.
T001–T021 complete; T022 human playable acceptance remains UNVERIFIED.
Production hazard defaults and six-room dressing have not adopted candidate art.

## Setup and identity

Godot 4.7.2.stable.official.ed1daf0bf; Compatibility renderer; Jolt 60 Hz.
Blender 5.2.2 LTS d13f752e3b9c; Python 3.12. Sources, archive/export hashes,
normalization and runtime inventory: [manifest](../../assets/art/manifest.json).
Current source snapshot: [source-identity.json](evidence/source-identity.json).
Full-suite snapshot before the paused-label refinement:
[source-identity-full-suite.json](evidence/source-identity-full-suite.json).
Unrelated `.gitignore`, `.specify/feature.json` and supplied root ZIP changes preserved.
Godot runs use isolated `/tmp/omdb-art-*` save roots and temporary XDG directories.
Sandbox-only baseline import failed on local editor sockets; retry outside that
restriction passed. Strict import/error/summary rules were retained.

## Observed checks

| Check | Setup and expected outcome | Actual result | Status / evidence |
| --- | --- | --- | --- |
| T001 baseline | Strict import/load plus full state/physics/recovery suite against original owners | 14,356 pass; 0 fail (state 2,869; physics 9,609; recovery 1,878), wrapper exit 0 | PASS: [baseline](evidence/baseline.log) |
| T003 source acquisition | Compare exact selected archives to research hashes; retain sources and licence evidence | All three hashes matched. KayKit free member/CC0 file and saw readme retained; anvil creator-page CC0 rechecked and dated | PASS: manifest and per-pack SOURCE/LICENSE files |
| T008–T012 red contracts | Missing visual wrappers and pending inventory must fail before hookup | Three missing-wrapper failures and three incomplete-inventory failures; provenance/import isolation passed | Expected FAIL: [red](evidence/red.log) |
| T013–T015 conversion | Export normalized mesh-only GLBs and editable sources with autoexec disabled | All exports finalized. Runtime counts: spikes 108 triangles; anvil 258; saw 140; each 1 surface/material and 0 texture dependencies | PASS: [spikes](evidence/spikes-conversion.log), [anvil](evidence/anvil-conversion.log), [saw](evidence/saw-conversion.log), manifest |
| T016 resource closure | Compile/load every script/scene/resource and all curated GLBs, reject dependencies/errors | 144 resources checked, 0 failures; final strict import successful; source reload also passes after paused-label refinement | PASS: [load check](evidence/load-check.log), integrated log |
| T017–T020 focused contracts | Four spike sizes ×10 support/bounds trials; saw contributor/axis tests ×10; anvil phase/pause/retirement tests ×10; fixture baseline/mute/pause/name controls | 397 focused assertions pass on current source, including paused label hiding; earlier primitive-mesh inspection, approximate float comparisons and scene declaration ordering corrected | PASS: [focused checks](evidence/focused-final.log), integrated log |
| T021 integrated suite | Strict all-suite runner with candidate contract tests discovered, existing death/carry/FIFO/placement/support/recovery and ten-solution-per-room checks retained | 14,751 pass; 0 fail (state 2,869; physics 10,004; recovery 1,878); wrapper exit 0; no engine/script/import errors. Later label-only refinement verified with focused checks | PASS: [integrated](evidence/integrated.log) |
| Render smoke / partial T022 | Linux AMD 740M, OpenGL/Mesa 25.2.8, 1280×720, authored camera; synthetic five-body bridge/stack/plate/saw arrangement; capture four views | Four captures; body count 5 and jam true. Agent inspected geometry; saw teeth/hub, anvil horn/waist/foot and bounded shallow spikes visible. Metal contrast and fixture HUD overlap corrected | Partial only: [render](evidence/render.log), [SE](evidence/view-0.png), [SW](evidence/view-1.png), [NW](evidence/view-2.png), [NE](evidence/view-3.png) |
| T022 playable acceptance | Ten fresh applicable physical interactions, both keyboard/physical controller, all four views and muted warnings | No human keyboard/controller ten-trial session performed. Rendered arrangements were injected through test helper, not player-built solutions | UNVERIFIED; T022 remains unchecked |

## Corrected defects and retained attempts

- PrimitiveMesh has no ArrayMesh primitive-type API: inventory now uses the appropriate
  path; focused checks verify both repeated imported geometry and primitive markings.
- Exact floating-point test comparisons were overly strict: envelope/phase tests now use
  approximate comparisons without changing authored gameplay values.
- Saw scene declared an external resource after subresources: declaration order fixed;
  strict load now passes. Failed [scene attempt](evidence/scene-error.log) retained.
- A vector in a test ID contained spaces: assertions passed but strict summary rejected
  that run. IDs now use dimension strings without spaces; final wrapper exit 0.
  [Rejected summary](evidence/rejected-summary.log) retained. That run also emitted a
  Jolt job-capacity warning; the final passing run did not reproduce it.
- Dark metal and fixture controls overlapping the HUD: lighter non-emissive metal and
  controls below the camera readout; final four-view captures inspected.
- Blender preview-cache writes initially failed outside the workspace. Setting the pinned
  tool's `file_preview_type` to NONE fixed them; final conversions have no errors and
  unchanged GLB hashes. The legacy saw emits a UI migration warning; Blender emits a
  material API deprecation warning. Neither exists in the clean runtime imports.

Conversion exits only after synchronous save/export to avoid the observed legacy Blender
shutdown hang. Its retained implementation is `scripts/checks/normalize_hazard_art.py`.
Godot separately validates dependency closure, measured inventory, hashes and isolation.
Source and runtime models are retained; models stay trial_selected until Stage B proof.

## Repeatable evidence templates

- [Physical trials](evidence/representative-trials.csv): 20 cases ×2 input methods ×10 repeats.
- [Recognition](evidence/recognition.csv): 5 reviewers ×3 hazards ×4 views =60 observations.
- [Readability](evidence/room-readability.csv): 6 rooms ×4 views ×3 windows =72 combinations,
  each requiring fresh and populated/effect review.
- [Native flows](evidence/native-flow.csv): all four OS/input combinations.
- [Performance](evidence/performance.csv): matched baseline/candidate representative/densest
  captures, 1920×1080, 30 s warmup/120 s capture; targets frame p95≤16.7 ms,
  physics p95≤4 ms, whole-room≤100k triangles/450 draws, new art≤45k/60 added draws.

These rows are protocols, not passing observations. Stage B reviewer/performance evidence,
full rollout, native flows and full-slice playtests remain UNVERIFIED and outside this run.
The five-reviewer gate must pass before production adoption.

## Paused-label refinement — 2026-10-10

A subsequent fixture review found that hiding names while paused left the active saw name
visible until the next owner tick. [Regression reproduction](evidence/paused-names-red.log)
failed as expected. Saw/anvil visual name setters now refresh only the label from cached
owner-derived values; clocks, poses, contributor state and gameplay remain frozen.
The refined check explicitly establishes an anvil warning before pausing.
Both paused-label checks and all other focused contracts pass; resource reload remains
144/0. The full suite above preceded this label-only change; it was not unnecessarily
repeated. Current and full-suite source identities are recorded separately.
The [focused runner](evidence/focused-runner.txt) is retained for reproducing the targeted
run; copy it to an absolute `/tmp` `.gd` path and run Godot with `--fixed-fps 60`,
`--script` and an isolated `--save-root` as in quickstart. It returned exit 0.

## Remaining checks and defects

- T022: human interaction/control-feel review with physical controller and keyboard.
- Shallow 0.16m spikes meet support constraints but recognition at whole-room distance
  remains a trial outcome; refine density/materials if player review fails.
- No native Windows/macOS, player recognition/atmosphere, or timed performance acceptance.
- Earlier analysis U1 (native benchmark delivery) and I1 (cleanup/export order) concern later
  phases and remain unresolved; address before executing their affected tasks.

## Repeat final automated checks

```sh
python3 scripts/checks/run_checks.py --godot /usr/local/bin/godot --suite all --save-root /tmp/omdb-art-verified-20261009
```

Observed: strict wrapper exit 0 and the 14,751-case summary above. Post-execution hook
configuration is absent; no extension hook was dispatched. No commit or publication occurred.

## Decoration follow-up — 2026-10-10

User requested decorated walls/floors and additional objects around rooms. The candidate
fixture now includes a batched patterned stone floor, alternating masonry/arched/cracked/
pillar wall modules, a flush closed entrance grate, sparse fixed wall-mounted shelves with
candles, labelled bottles, banners and unlit torches, and a muted violet environment.
Low boundary trim remains visible when near-side walls and their prop clusters cut away.
This is non-adopting presentation work: production defaults and authored rooms remain on
the previous treatment until the representative acceptance gate passes.

Ten additional free-edition KayKit models are trial-selected with exact original members,
buffer/atlas hashes, retained sources, licence evidence and measured runtime inventory in
the manifest. The three hazard records remain intact. No paid content, collision,
interaction system, additional lights or randomized gameplay spawns were added.

| Check | Setup / expected | Actual | Status |
| --- | --- | --- | --- |
| Red decoration contracts | Missing chamber must fail | Two expected failures | [Expected FAIL](evidence/decoration-red.log) |
| Final chamber/cutaway contracts | Actual 16×12 fixture and 24×12 Room 4; flush bounded tiles excluding trap footprints; no decorative physics; props present; four nested cutaways, persistent trim and unchanged snapshots/solid walls | 172 passing assertions; 0 failures, no engine errors. Repeated after final prop-orientation adjustment | [PASS](evidence/decoration-contracts.log) |
| Strict all-suite integration | New environment dependency/hash/inventory checks plus existing state/physics/recovery suite, including room solutions | 15,016 pass; 0 fail (physics 10,269; state 2,869; recovery 1,878); wrapper exit 0 | [PASS](evidence/decoration-integrated.log) |
| Rendered preview | Linux 740M/Mesa 25.2.8, 1280×720; five synthetic bodies, jammed saw, all four authored views; inspect detail and occlusion | Four captures inspected; shelves oriented into room, props cut away with near walls, floor danger exclusions and boundary trim visible | Partial rendered review: [log](evidence/decoration-render.log) |
| Human/control/performance/rollout acceptance | Actual player-built arrangements, two input methods, three windows, reviewer and timed/native targets | Not performed; previous missing evidence remains missing | UNVERIFIED |

Preview captures: [SE](evidence/decoration-view-0.png),
[SW](evidence/decoration-view-1.png), [NW](evidence/decoration-view-2.png),
[NE](evidence/decoration-view-3.png). Current decoration-source identity:
[JSON](evidence/decoration-source-identity.json).

Godot imports documentation CSVs as translations by default. `specs/.gdignore` now keeps
specification/evidence content out of the engine import pipeline; only generated evidence
translation/import sidecars were removed. Evidence and original captures remain intact.
The old full-suite logs and snapshots remain historical records for the earlier increment.
T027 is complete; remaining Phase 4 tasks retain unchecked partial/pending outcomes.
Post-execution extension configuration is absent. No production rollout or release occurred.

## Colourful cursed dungeon — 2026-10-10

**Scope:** User selected the full dungeon premise and colourful dark comedy. Constitution
1.1.2, PRD, spec FR-019, plan, tasks and contract C8 now agree. Original KayKit atlas
materials replace the flat candidate architecture overrides. Red banners, warm lit meshes,
mounted shields, shelves/bottles and sparse wall-margin rubble establish the dungeon.
Optional stone plates and iron exit skins remain candidate-only; production 3D defaults
remain null. Visible prisoner/resurrection copy and 2D UI are updated globally without
changing technical subject IDs, save schemas, controls or room layouts.

### Repeatable automated checks

- **Setup:** Godot 4.7.2.stable.official.ed1daf0bf; real greybox owners, two plates/two exits,
  isolated temporary saves. Ten trials of stone support fit, independent plate cues,
  open/closed gate state, persistent arch in all views, retained solid sizes and retreat.
- **Expected:** Missing skins fail first; implemented skins are cosmetic, preserve original
  supporting top and labels, and follow owner state without shared state changes.
- **Actual:** [Red check](evidence/dungeon-red.log) failed the missing-skins case as expected;
  [initial skin checks](evidence/dungeon-skins-initial.log) passed 240 assertions. Rendered
  doorway adjustment adds ten-trial bounded-frame checks. Final [focused checks](evidence/dungeon-contracts-final.log)
  pass **613 assertions, zero failures**, including dungeon skins, chamber fit/cutaways,
  asset provenance/inventory and baseline/candidate mute/pause/reconstruction checks.
- **Full regression:** [Strict integrated run](evidence/dungeon-integrated.log) passed
  **15,339 assertions, zero failures**: physics 10,592, state 2,869, recovery 1,878; wrapper
  exit 0. This run preceded final cosmetic mesh batching; affected final code was rechecked
  in the 613-assertion focused run. No gameplay-state implementation changed in batching.
  The full run emitted the previously observed intermittent Jolt job-limit warning; no
  assertion or strict-wrapper failure occurred. Record this engine diagnostic rather than
  treating it as evidence of platform acceptance.

### Rendered review and defects

- **Setup:** Linux, AMD Radeon 740M, Mesa 25.2.8, Compatibility OpenGL. All four diagonal
  views at actual 1280×720, 1920×1200 and 1024×768 viewports, fresh and with five bodies.
  Five-body arrangements are injected, not player-built solutions. Player, plate labels,
  persistent gate frames, trap outlines, corpses and foreground cutaways were inspected.
- **Actual:** [Matrix log](evidence/dungeon-matrix.log) records all **24 captures**, fresh
  body count 0 and populated count 5, with jammed saw in populated states. Example:
  [1280×720 SE, five bodies](evidence/dungeon-1280x720-five-view-0.png). Agent visual
  inspection found no new wall/gate occlusion after the adjustment. This is a fixture
  smoke review, not five-reviewer recognition, physical input/control-feel acceptance or
  the production 72-case room review. Small-window text legibility still needs human review.
- **Corrected fit defect:** Uncompressed KayKit doorway wings/header screened adjacent
  traps. The wrapper removes the separate wooden door and compresses the broad stone
  wings/header around its retained, padded opening. Original passage/blocker/retreat
  geometry is unchanged. Bounded-frame assertions and all-view captures verify the fix.
- **Capture shutdown diagnostic:** Initial rendered harnesses quit while WAV playback was
  still being released; the [verbose probe](evidence/dungeon-audio-shutdown-probe.log)
  identified AudioStreamWAV/PlaybackWAV references. Temporary capture harnesses now retire
  the room, invoke existing audio shutdown and allow the audio thread to settle before
  freeing/quitting. Final matrix/inventory logs exit 0 without resource diagnostics.
  Runtime audio ownership/behaviour was not changed.

### Rendering inventory and remaining performance defect

- **Setup:** Matched baseline/candidate at actual 1920×1080, same live cow/five injected
  bodies and four camera views. [Inventory runner](evidence/dungeon-inventory-runner.txt)
  uses actual renderer counters. These are sampled counts, not a frame-time profile.
- **Before batching:** [Capture](evidence/dungeon-render-inventory-before-batching.log)
  reports baseline 441 draw calls; candidate peak 516, +75. The whole-room ceiling 450
  and added-art allowance 60 were exceeded.
- **Final:** Walls are grouped by model within each independent side; plate cue strips
  use MultiMesh. [Clean capture](evidence/dungeon-render-inventory.log) reports baseline
  441; candidate **498 peak draw calls (+57)** and **64,986 peak primitives**. Added-art
  draw allowance now passes, but **the whole-room 450-call ceiling remains exceeded by 48**.
  No target was raised. Chamber inventory is 35,968 triangles, 94 instanced surfaces,
  22 material identities, one shared atlas texture and no forbidden physics/light/camera nodes.
- **Timed profile:** The 30 s warmup/120 s baseline/candidate attempt ended before a
  completion result; [interrupted log](evidence/dungeon-profile-interrupted.log) is retained.
  Cause is not established. FPS/p95 frame/p95 physics acceptance remains **UNVERIFIED**.
  The Linux reference is not native Windows/macOS evidence. Further whole-room draw
  optimization and a completed timed capture remain required by T034–T037/T059.

### Current adoption status

Twenty source models have measured inventory, retained originals, dependency hashes and
CC0 records; they remain trial_selected. Custom gap rationales are in manifest.json and
SOURCE.md. [Final source identity](evidence/dungeon-source-identity.json) identifies current
code/resources; historical evidence remains dated. T030–T032 and T056–T058 are complete;
T059 remains partial due to incomplete timed performance and the draw ceiling defect.
T022 physical keyboard/controller trials and T033–T037 human/budget gates are unverified.
The six-room 3D rollout, five-reviewer proof and native build/input/performance checks have
not been claimed complete. No commit, export, publication or new game mechanic occurred.
