# Hazard artwork implementation evidence

Date: 2026-10-09. Scope requested: Phases 1–3, T001–T022.
T001–T021 complete; T022 human playable acceptance remains UNVERIFIED.
Production hazard defaults and six-room dressing have not adopted candidate art.

## Setup and identity

Godot 4.7.2.stable.official.ed1daf0bf; Compatibility renderer; Jolt 60 Hz.
Blender 5.2.2 LTS d13f752e3b9c; Python 3.12. Sources, archive/export hashes,
normalization and runtime inventory: [manifest](../../assets/art/manifest.json).
Checked source snapshot: [source-identity.json](evidence/source-identity.json).
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
| T016 resource closure | Compile/load every script/scene/resource and all curated GLBs, reject dependencies/errors | 144 resources checked, 0 failures; final strict import successful | PASS: [load check](evidence/load-check.log), integrated log |
| T017–T020 focused contracts | Four spike sizes ×10 support/bounds trials; saw contributor/axis tests ×10; anvil phase/pause/retirement tests ×10; fixture baseline/mute/pause/name controls | All focused assertions passed after correcting primitive-mesh inspection, approximate float comparisons and scene declaration ordering | PASS: [focused checks](evidence/focused-final.log), integrated log |
| T021 integrated suite | Strict all-suite runner with candidate contract tests discovered, existing death/carry/FIFO/placement/support/recovery and ten-solution-per-room checks retained | 14,751 pass; 0 fail (state 2,869; physics 10,004; recovery 1,878); wrapper exit 0; no engine/script/import errors | PASS: [integrated](evidence/integrated.log) |
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
