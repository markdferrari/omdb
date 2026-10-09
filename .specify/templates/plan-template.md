# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: GDScript / Godot 4.x [record exact engine version]

**Primary Dependencies**: [Godot built-ins, selected runtime assets, any justified add-ons]

**Storage**: Local current-room progress and player settings; no saved corpse arrangement

**Testing**: [Repeatable state regression checks and playable scene checks; commands and evidence paths]

**Target Platform**: Windows and macOS; complete keyboard and controller support

**Project Type**: Godot 3D puzzle-platformer

**Performance Goals**: [Measured targets, reference hardware, resolution, and player-plus-five-corpses scenario]

**Tuning and Asset Budgets**: [Relevant movement, placement, physics, and asset limits;
greybox evidence or a planned experiment to establish them, with results recorded before completion]

**Constraints**: Four diagonal isometric orthographic views, 90° yaw steps with fixed tilt/elevation/distance/zoom; five-body cap; stable solid corpses; local recovery

**Scale/Scope**: [Feature's part of the six-room slice and current milestone; excluded work]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Read `.specify/memory/constitution.md` and `PRD.md`. Record a result and supporting design
reference for each gate before research and after design; use N/A only with a reason.

| Principle | Required evidence | Before research | After design |
|-----------|-------------------|-----------------|--------------|
| I. Focused Six-Room Slice | PRD scope mapping, teaching order, and intended solutions within the cap where rooms change | [Result/reference] | [Result/reference] |
| II. Reliable Corpse Physics and State | State ownership and transitions for death, carrying, FIFO replacement, hazard updates, and stable support | [Result/reference] | [Result/reference] |
| III. Readable Puzzles and Dependable Controls | Camera framing, screen-relative input, landing cues, placement validity, and readable puzzle feedback | [Result/reference] | [Result/reference] |
| IV. Complete Play Flow and Recovery | Keyboard/controller coverage, restart and save boundaries, and platform verification | [Result/reference] | [Result/reference] |
| V. Prove Interactions Before Expanding | Greybox/asset proof dependencies, repeatable checks, and recorded playtest or scene validation | [Result/reference] | [Result/reference] |

Resolve conflicts before implementation. Complexity Tracking records issues and their
resolution; it does not authorise a constitution exception.

### Verification and Evidence

- **State regression checks**: [Applicable spec scenarios, automated checks where practical,
  reproducible manual alternatives, and expected outcomes]
- **Playable validation**: [Bridge/stack trials, camera and placement readability, control
  feel, setup and repetition counts; record actual results during implementation]
- **Asset check**: [Selected character, source/export paths, actual-camera inspection,
  animation gaps, and player-plus-five-corpses performance; or N/A with reason]
- **Input and platform matrix**: [Affected flows on keyboard/controller and Windows/macOS;
  distinguish completed checks from planned or unavailable checks]
- **Evidence location**: [Feature quickstart and validation record paths; room solution
  steps and playtest findings where applicable]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output when applicable (/speckit-plan command)
├── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
└── validation.md        # Actual check results recorded during implementation and playtesting
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace this illustrative Godot layout with the feature's
  actual paths. Include only directories needed for its scope. Keep visual
  assets separate from gameplay scripts and corpse collision behavior.
-->

```text
project.godot
scenes/
├── player/
├── corpses/
├── hazards/
├── rooms/
└── ui/
scripts/
assets/
├── characters/
└── audio/
tests/                  # Regression scripts and/or reproducible validation scenes
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check identifies a conflict. Record its resolution or
> the required amendment; justification alone does not pass the gate.**

| Conflict | Why Proposed | Compliant Alternative or Amendment Required | Resolution |
|----------|--------------|--------------------------------------------|------------|
| [Principle and proposed deviation] | [Concrete need] | [Alternative or amendment] | [Status/reference] |
