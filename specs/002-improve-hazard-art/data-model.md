# Data Model: Artwork and Presentation

**Date:** 2026-10-09 | **Plan:** [plan.md](plan.md)

These are logical records, not a new database. Gameplay identities, registry, room state
and saves retain the [existing model](../001-six-room-slice/data-model.md).

## AssetRecord

One adopted source asset or documented custom adaptation in a development-only manifest.

| Field | Meaning / validation |
| --- | --- |
| asset_id | Stable unique project identifier, e.g. kaykit_spike_cluster. |
| family | environment, spikes, anvil, saw, signage or interface_skin. |
| creator, source_url | Actual creator and original publisher page; required for external assets. |
| pack_version, archive_sha256, source_members | Exact inspected archive and files; free-edition membership explicit. |
| acquired_on, acquisition_note | Known download date or explicitly unknown supplied-file provenance. |
| licence_id, licence_evidence, required_credits | Supplied terms or dated creator-page evidence; no guessed permissions. |
| source_paths, runtime_paths | Retained originals/adaptations and exported runtime dependency closure. |
| modifications | Pivot/scale/material/geometry changes and authoring tool version. |
| triangles, surfaces, materials, textures, bounds | Measured normalized runtime inventory, not only publisher claims. |
| decision, evidence_refs | Candidate, trial_selected, accepted or rejected; concrete reasoning/evidence. |
| custom_gap | Required only for custom work; links comparison/trial failure justifying it. |

Transitions: candidate → trial_selected after content/licence/fit inspection; trial_selected
→ accepted only after clean import and playable proof; rejected records retain reasons.
An accepted asset changed in a way that affects silhouette/bounds/materials returns to trial
status for affected verification. Catalogue acceptance does not waive each room's review.

## HazardVisualDefinition

Authored visual scene/resource associated with one existing hazard family.

- `family`, `asset_ids`, `visual_scene`: known source linkage and cosmetic wrapper.
- `local_bounds`, `pivot`, `axis`, `normalization_transform`: match the contract envelopes.
- `material_refs`, `state_cue_nodes`: shared base treatment and independently controlled cues.
- `footprint_policy`: fixed saw/anvil dimensions or bed-size-driven spike coverage.
- `shadow_policy`: explicit participation in the one-light budget.

A definition has no body identity, collision, input handling, lethal callback or save fields.
Shared resources must not be mutated for one instance's active/jammed state; use per-instance
parameters or duplicated state-specific materials where needed.

## HazardPresentationState

Transient inputs supplied by the existing owner, not authoritative state of their own.

| Family | Inputs | Derived presentation |
| --- | --- | --- |
| Saw | jammed, eligible_contributor_count, active delta | Rotor motion if active; stopped teeth plus persistent jam symbol/text otherwise. |
| Anvil | phase_seconds, warning_seconds, cycle_seconds, room active/retired | Warning, descent, impact pose, return and suspended pose from one clock. |
| Spikes | authored bed_size | Static bounded pattern and danger-bed outline. |
| Plate/exit | existing weight/required/open observations | Material/cue state; original labels and physical behavior retained. |

All instances initialize from current owner state before their first visible frame.
Pause freezes gameplay-derived animation. Retirement frees the room-owned visuals and
prevents old updates. Restart/new-room/resume creates fresh definitions and state, with
no serialization or recovery migration.

## ChamberArtDefinition

A shared scene with authored configuration per room:

- footprint (16×12 or 24×12), floor/wall skin references and palette;
- entrance and exit decorative anchors matching existing geometry;
- repeated module transforms and batches, excluding routes/trap markings;
- north/south/east/west cosmetic roots and persistent low boundary trim;
- internal gate decoration with state cues retained;
- lighting/background settings and source asset references.

Visual groups own only cosmetic descendants. Cutaway membership is explicit; a group
cannot contain a collider, player, corpse, hazard owner or critical HUD. Dimensions are
read from actual authored room properties; they are not a replacement room-layout source.

## ValidationCase and Observation

A case identifies requirement IDs, asset/build identity, room/fixture, view, window size,
input/device/platform, body arrangement, starting state, actions, expected outcome and
repeat count. An observation adds actual outcome, metrics/capture, PASS/FAIL/UNVERIFIED,
defects and retest reference. No observation defaults to PASS.

Recognition rows identify anonymized reviewer, hazard and view; atmosphere rows record
five-minute session description/rating. Native rows identify all four platform/input
combinations. Performance rows record hardware/OS/driver, release build, warmup/capture,
resolution and populated scene. These records implement VR-008, not a runtime telemetry
or account system.
