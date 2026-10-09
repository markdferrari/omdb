---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Verification**: Include tasks for every applicable Verification Requirement in spec.md.
The constitution requires repeatable state checks and playable validation for affected
gameplay. Use automated checks where practical; otherwise provide reproducible manual
steps. Additional automated suites are optional unless requested in the specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions
- Link validation tasks to spec requirement/scenario IDs and name the evidence file

## Path Conventions

- **Godot project**: `project.godot`, `scenes/`, `scripts/`, `assets/`, and `tests/`
- **Feature evidence**: `specs/[###-feature-name]/quickstart.md` and `validation.md`
- Paths below are illustrative; use the actual structure selected in plan.md

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /speckit-tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Interfaces/signals from contracts/ when present
  - Verification requirements from spec.md and constitution gates from plan.md

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create the planned scene/script directories and project.godot
- [ ] T002 Configure the selected Godot version and input actions in project.godot
- [ ] T003 [P] Document setup and validation commands in specs/[###-feature-name]/quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Configure shared physics layer names in project.godot
- [ ] T005 [P] Create the four diagonal isometric camera presets (90° yaw steps, fixed tilt/elevation/distance/zoom) and floor in scenes/rooms/greybox.tscn
- [ ] T006 [P] Inspect the candidate character and record asset/animation gaps in specs/[###-feature-name]/validation.md
- [ ] T007 Create the shared room state owner in scripts/room_state.gd
- [ ] T008 Define reproducible validation setups and expected results in specs/[###-feature-name]/quickstart.md
- [ ] T009 Bring the selected runtime character into assets/characters/ with retained Blender source location documented

Keep gameplay-specific work in its story. The greybox proof and in-scene asset validation
MUST complete before tasks producing the full room sequence; include those dependencies
where they actually fall in the plan, rather than assuming setup alone proves the mechanics.

**Checkpoint**: Foundation ready - start stories whose dependencies are satisfied

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Verification for User Story 1 (applicable spec requirements)

> Define expected outcomes first. For automated regression tests, confirm they fail before
> implementing the missing behavior. Run playable checks after the scene is implemented.

- [ ] T010 [P] [US1] Add repeatable [state invariant / edge case] checks in tests/test_[name].gd (spec: [VR/scenario IDs])
- [ ] T011 [P] [US1] Define playable [bridge/stack/input] trials and pass criteria in specs/[###-feature-name]/quickstart.md (spec: [VR/scenario IDs])

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create [gameplay entity] scene in scenes/[entity1]/[entity1].tscn
- [ ] T013 [P] [US1] Create [interacting entity] scene in scenes/[entity2]/[entity2].tscn
- [ ] T014 [US1] Implement [interaction/state transition] in scripts/[name].gd (depends on T012, T013)
- [ ] T015 [US1] Integrate the story into scenes/rooms/[room].tscn
- [ ] T016 [US1] Add [readable state / placement feedback] in scenes/ui/[name].tscn
- [ ] T017 [US1] Run state checks and playable trials, recording outcomes and defects in specs/[###-feature-name]/validation.md

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Verification for User Story 2 (applicable spec requirements)

- [ ] T018 [P] [US2] Add repeatable [state invariant / edge case] checks in tests/test_[name].gd (spec: [VR/scenario IDs])
- [ ] T019 [P] [US2] Define playable [placement/hazard/recovery] checks in specs/[###-feature-name]/quickstart.md (spec: [VR/scenario IDs])

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create [gameplay entity] scene in scenes/[entity]/[entity].tscn
- [ ] T021 [US2] Implement [interaction/state transition] in scripts/[name].gd
- [ ] T022 [US2] Integrate the story into scenes/rooms/[room].tscn with explicit earlier-story dependencies
- [ ] T023 [US2] Run the story checks and record keyboard/controller outcomes in specs/[###-feature-name]/validation.md

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Verification for User Story 3 (applicable spec requirements)

- [ ] T024 [P] [US3] Add repeatable [state invariant / edge case] checks in tests/test_[name].gd (spec: [VR/scenario IDs])
- [ ] T025 [P] [US3] Define playable [room/flow] checks in specs/[###-feature-name]/quickstart.md (spec: [VR/scenario IDs])

### Implementation for User Story 3

- [ ] T026 [P] [US3] Create [gameplay entity or UI] scene in scenes/[location]/[name].tscn
- [ ] T027 [US3] Implement [interaction/flow] in scripts/[name].gd
- [ ] T028 [US3] Integrate and validate the story, recording actual results in specs/[###-feature-name]/validation.md

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Review state ownership and remove obsolete logic in scripts/[affected-file].gd
- [ ] TXXX Measure player-plus-five-corpses performance against plan targets and record results in specs/[###-feature-name]/validation.md
- [ ] TXXX [P] Add additional automated checks requested by spec.md in tests/test_[name].gd
- [ ] TXXX Record each affected room's repeatable solution within the cap in specs/[###-feature-name]/validation.md
- [ ] TXXX Validate affected keyboard/controller flows and Windows/macOS exports in specs/[###-feature-name]/validation.md
- [ ] TXXX Run applicable restart and saved-room resume checks from specs/[###-feature-name]/quickstart.md
- [ ] TXXX Record playtest timing, help requests, rule confusion, jump judgment, and placement frustration in specs/[###-feature-name]/validation.md
- [ ] TXXX Address acceptance defects in [affected scene/script path] and record recheck results in specs/[###-feature-name]/validation.md

Include only applicable tasks for an incremental feature. For release, require full
six-room playthroughs on both target platforms and both input methods. Unperformed
checks remain unverified; do not mark them complete. Tasks sharing a validation file
must run sequentially unless the plan assigns separate evidence files.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can proceed in parallel only when their actual dependencies allow it
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: After Foundation and any explicitly required US1 interactions
- **User Story 3 (P3)**: After Foundation and any explicitly required US1/US2 interactions
- **Full room production**: After recorded greybox interaction and representative asset proof
- **Release validation**: After all six rooms, recovery, menus, settings, and completion flow exist

### Within Each User Story

- Automated regression tests, when included, MUST fail before missing behavior is implemented
- State rules and base scenes before dependent interactions
- Interactions before room and UI integration
- Core implementation before integration
- Playable verification and evidence after integration
- Applicable verification passes before marking the story complete

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- After Foundation, only stories with no unmet dependencies can start in parallel
- All tests for a user story marked [P] can run in parallel
- Independent scenes or scripts within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Define independent checks for User Story 1 together:
Task: "Add [state invariant] checks in tests/test_[name].gd"
Task: "Define playable trials in specs/[###-feature-name]/quickstart.md"

# Create independent scenes for User Story 1 together:
Task: "Create [Entity1] scene in scenes/[entity1]/[entity1].tscn"
Task: "Create [Entity2] scene in scenes/[entity2]/[entity2].tscn"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Demo the playable increment; advance only after its applicable proof gate passes

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Verify and record results → Demo the increment
3. Add User Story 2 → Verify it and affected regressions → Demo
4. Add User Story 3 → Verify it and affected regressions → Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundation and any story-specific dependencies are complete:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Define acceptance outcomes first; verify automated regression tests fail before implementing
- Run playable validation after integration and retain actual evidence
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
