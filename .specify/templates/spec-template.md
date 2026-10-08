# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`

**Created**: [DATE]

**Status**: Draft

**Input**: User description: "$ARGUMENTS"

**Governing documents**: `PRD.md` and `.specify/memory/constitution.md`

## Scope and Principle Alignment *(mandatory)*

- **Slice contribution**: [PRD requirement and milestone this feature delivers]
- **Included / excluded**: [Feature boundary within the six-room slice]
- **Applicable principles**: [I–V with affected rules; explain any N/A]
- **Puzzle progression**: [Mechanics taught or combined and intended solution within five
  bodies for affected rooms; or N/A with reason]

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

For affected gameplay, specify observable outcomes for simultaneous hazard contacts,
rapid deaths, invalid placement, death while carrying, and oldest-body removal while
carried, supporting a stack, pressing a plate, or jamming a saw. Cover restart, room
transition, and reopening saved progress where relevant. Mark unrelated cases N/A with
a reason; do not omit applicable state rules.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: Game MUST [observable capability for this feature]
- **FR-002**: Game MUST [relevant corpse, placement, or hazard rule]
- **FR-003**: Players MUST be able to [affected interaction using keyboard and controller]
- **FR-004**: Game MUST [applicable restart, progression, or settings behavior]
- **FR-005**: Game MUST [feedback needed to understand the puzzle from the fixed camera]

*Example of marking unclear requirements:*

- **FR-006**: Game MUST [NEEDS CLARIFICATION: observable interaction not defined by the PRD]

### Verification Requirements *(mandatory)*

This section explicitly requests the applicable verification tasks required by the
constitution. Define acceptance evidence, not implementation details or a test framework.

- **VR-001**: Verify [affected state invariants and edge cases] through repeatable
  regression checks with defined starting state, actions, and expected result.
- **VR-002**: Validate [affected physics, camera readability, placement, and control feel]
  in playable scenes, with repeat counts and pass criteria defined for the feature.
- **VR-003**: Exercise [affected flows] with keyboard and controller; specify Windows and
  macOS checks required for this feature and for release.
- **VR-004**: Record setup, expected outcomes, actual results, and outstanding defects in
  [feature validation record]. Include greybox/asset evidence, room solution steps, or
  playtest observations when applicable; explain N/A cases.

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Player outcome, e.g., intended route completed within the five-body limit]
- **SC-002**: [Reliability measure with trial count, setup, and allowed failure count]
- **SC-003**: [Readability or usability outcome assessed from the stationary camera]
- **SC-004**: [Completion of affected input, recovery, and platform checks]

For full-slice playtests, record completion time against the 20–30 minute first-playthrough
target, help requests, misunderstood rules, jump judgment, and placement frustration.

## Assumptions

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right assumptions based on reasonable defaults
  chosen when the feature description did not specify certain details.
-->

- [Feature-specific assumption about player knowledge or teaching order]
- [Dependency on the greybox proof or an existing gameplay interaction]
- [Asset assumption requiring visual validation; metadata alone is not proof]
- [Unresolved tuning or measurement decision assigned to feature planning]
