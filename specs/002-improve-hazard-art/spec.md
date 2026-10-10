# Feature Specification: Recognizable Hazards and Gothic Atmosphere

**Feature Branch**: `main` (existing branch; no branch-creation hook configured)

**Feature Directory**: `specs/002-improve-hazard-art`

**Created**: 2026-10-09

**Status**: Draft — quality validated; implementation plan and tasks complete

**Input**: User description: "I want to improve the artwork - I want real anvils, spikes, bladed wheels, and a proper atmosphere. Help me spec this out." Follow-up: "if a suitable free asset pack already exists for the godot enginer I think we should consider it, there's no point reinventing the wheel"

**Governing documents**: [PRD](../../PRD.md) and
[constitution v1.1.1](../../.specify/memory/constitution.md).
Existing gameplay requirements remain defined by [the six-room feature](../001-six-room-slice/spec.md).

## Scope and Principle Alignment *(mandatory)*

**Slice contribution:** Deliver the PRD's presentation polish: replace unfinished hazard
forms and sparse chamber dressing with recognizable traps inside stylised gothic miniature
testing chambers. Players should understand danger through the objects themselves and feel
that all six rooms belong to the same macabre, comic facility.

**Included:** Recognizable 3D anvils, pointed spike beds and toothed bladed wheels; warning,
impact, active and jammed presentation; a shared stone-and-iron chamber style; floor/wall
treatment, cutaway architecture, selective testing-facility props, restrained backgrounds,
simple lighting and readable shadows; consistent visual treatment of existing plates, doors
and entrance hatches. Evaluate suitable free packs before custom work, adapt reusable assets,
prove one representative chamber, then apply the accepted treatment across the six rooms.

**Excluded:** New hazards, changed puzzle rules, room redesign, new character selection,
new biomes, cinematic cameras, free orbit, realistic gore, jointed ragdolls, elaborate
lighting, a new soundtrack, or broad menu redesign. Existing cheerful music, cartoon trap
sounds, neon effects and the reused character remain part of the visual-fit review. Buying
assets is not part of this feature's default scope.

**Applicable principles:**

| Principle | Application |
| --- | --- |
| I. Focused Six-Room Slice | Polish existing rooms and teaching order; retain intended solutions within five bodies. |
| II. Reliable Corpse Physics and State | Artwork, animated traps and dressing preserve support, placement, hazard contacts and creation-order removal. |
| III. Readable Puzzles and Dependable Controls | Review player, bodies, hazards and cues in all four diagonal isometric views; retain landing and placement aids. |
| IV. Complete Play Flow and Recovery | Preserve keyboard/controller interaction, restart, saved-room resume and fresh transitions with the new presentation. |
| V. Prove Interactions Before Expanding | Reuse recorded greybox evidence, close applicable outstanding playable/character checks, and prove one art treatment before six-room rollout. |

**Puzzle progression:** No new mechanic is taught. Room 1 still teaches corpse traversal,
Room 2 carrying/weight, Room 3 persistent saw jams, Room 4 anvils/oldest-body replacement,
and Rooms 5–6 established combinations. Existing [room solutions](../001-six-room-slice/room-solutions.md)
must remain repeatable within the cap. Cosmetic architecture must not introduce shortcuts,
apparent landing surfaces without support, or obstacles to those solutions.

**Interpretation and consistency:** "Real" means recognizable, convincingly shaped objects
within the PRD's stylised direction. "Bladed wheels" means the existing jammable buzzsaws.
"Atmosphere" means a cohesive visual environment supported by the existing sound direction.
These interpretations require no amendment to the PRD or constitution. This feature adds
presentation acceptance criteria; it does not supersede gameplay contracts or claim that
outstanding human or native-platform checks have passed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recognize Traps and Their States (Priority: P1)

As a player, I want anvils, spikes and saws to look like dangerous physical objects so I
can identify each trap, understand where it threatens me, and see when it becomes safe.

**Why this priority**: These objects are the main artwork gap, and their appearance directly
affects the player's ability to read and solve puzzles.

**Independent Test**: In a playable chamber with all three hazards, inspect each from all
four views, trigger an anvil, cross a body-supported spike route, and jam/release a saw.
This can be evaluated before all room dressing is complete.

**Acceptance Scenarios**:

1. **Given** the normal whole-room camera, **When** I inspect traps without their name
   labels, **Then** the anvil has a broad striking face, projecting horn, narrowed waist
   and flared foot; spikes have clearly pointed tips rising from a bed; and the saw has
   a visibly toothed rim and central hub. Materials distinguish metal from surrounding stone.
2. **Given** an exposed spike bed, **When** I approach its boundary or place a body over it,
   **Then** the dangerous region is identifiable, decorative gaps do not imply safe walking
   lanes, and a supported corpse route remains visible and traversable.
3. **Given** an active saw, **When** a released body jams it and is later picked up or removed,
   **Then** blade motion stops and resumes with the actual state; the jam cue is distinguishable
   without sound or colour alone, and the stopped route permits traversal.
4. **Given** an anvil preparing to drop, **When** I watch a cycle with sound muted,
   **Then** a visible warning identifies its dangerous footprint before impact, the anvil
   reaches that footprint when the strike occurs, and its return clearly precedes the next
   drop. Warning duration and repeat timing retain established gameplay values.

---

### User Story 2 - Explore a Cohesive Gothic Testing Chamber (Priority: P2)

As a player, I want rooms to feel like a deliberately built, darkly comic testing facility
so that the traps, character and puzzle objects share a believable setting.

**Why this priority**: Recognizable props need a consistent surrounding direction to deliver
the requested atmosphere rather than a collection of unrelated assets.

**Independent Test**: Play one dressed chamber using the reused character and up to five
corpses. Review architecture, surfaces, lighting and prop hierarchy without completing the sequence.

**Acceptance Scenarios**:

1. **Given** a fresh dressed chamber, **When** I survey it, **Then** stone floor divisions,
   ink-like edge/wash treatment, iron machinery and gothic arch or buttress motifs establish
   a consistent miniature chamber. An identifiable entrance hatch, framed exit and testing
   signage connect the architecture to the experiment premise.
2. **Given** props and a restrained background, **When** I assess a route, **Then** walkable
   floors and landing surfaces are distinguishable from background dressing, neon accents
   emphasize gameplay/effects, and background detail remains subordinate to the player,
   corpses, plates and hazards.
3. **Given** the player is jumping, carrying or arranging five bodies, **When** I cycle
   through all four views, **Then** the ground shadow, airborne surface ring, placement
   preview, oldest-body marker, plate requirement and exit state remain visible; foreground
   dressing cuts away as needed without altering physical boundaries.
4. **Given** the same character alive and collapsed as a corpse, **When** I view it against
   the new stone/metal palette, **Then** its silhouette and pose remain distinguishable at
   normal camera distance and visual effects leave the usable support surface understandable.

---

### User Story 3 - Solve the Polished Six-Room Sequence (Priority: P3)

As a player, I want improved artwork throughout the slice while retaining dependable
movement, placement and recovery so that presentation strengthens the experience.

**Why this priority**: Reuse of the proven treatment completes the upgrade while protecting
the puzzles that already work.

**Independent Test**: Start each room fresh, perform its recorded solution, restart a partly
solved arrangement, and resume saved progress using either input method.

**Acceptance Scenarios**:

1. **Given** any of the six rooms, **When** I inspect and solve it, **Then** every requested
   trap uses the accepted recognizable artwork and the room uses the shared chamber treatment;
   its existing solution works within five simultaneous bodies.
2. **Given** bodies supporting a route, weighing a plate, jamming a saw or being carried,
   **When** a sixth corpse removes the oldest, **Then** markers and trap/door states reflect
   the resulting gameplay state immediately; removal effects add no physical obstacle.
3. **Given** a partly solved room or running warning/effect, **When** I restart, advance or
   reopen saved progress, **Then** the expected fresh puzzle and presentation return without
   stale blades, warnings, corpses or effects from the earlier room state.
4. **Given** keyboard or controller input, **When** I move, jump, place bodies, select views,
   use settings and recover a room, **Then** existing interactions remain available without
   extra actions introduced by the artwork.

### Edge Cases

- **EC-01 — Visible versus actual danger:** Spaced spikes, blade teeth and anvil overhang
  must not suggest safe routes inside lethal regions or lethal regions on intended safe
  routes. Use legible boundary treatment where a simplified interaction area differs from
  the detailed silhouette.
- **EC-02 — Jam and reactivation:** A stopped saw retains its jam cue indefinitely while
  an eligible body remains. Removing the final contributor resumes motion and danger;
  removing one of several does not. Held bodies never jam a saw.
- **EC-03 — Oldest-body roles:** Removal while held clears carrying visuals; removal under
  a stack permits settling; removal from a plate updates plate/door; removal from a saw
  updates its state. The marker identifies the same creation-order body in every view.
- **EC-04 — Death and placement:** Simultaneous contacts and rapid deaths still create
  exactly one corpse/replacement per death. Carrying death releases the existing body and
  creates the new one under the cap. Invalid overlap/out-of-reach placement keeps the body
  held and the invalid cue visible despite new decoration.
- **EC-05 — Presentation density:** Review an anvil warning, active/jammed saw, neon effects,
  live character and five corpses together. Effects, shadows and splatters must not cover
  landing/placement cues or imply that an existing body was destroyed by a trap.
- **EC-06 — Views and windows:** Arches, posts, machinery housings and exit trim remain
  readable after view selection or supported aspect-ratio changes; cutaways must not remove
  collision or hide the open exit frame.
- **EC-07 — Lifecycle:** Restart during warning, drop, jam or death feedback; leave during
  effects; reopen saved progress. Fresh puzzle state produces matching fresh visuals,
  and earlier presentation must not reappear.
- **EC-08 — Imported packs:** Reject missing materials, scale/orientation errors,
  unsupported visual dependencies, conflicting styles, misleading props, and needed assets
  available only in a paid edition. Record failed candidates and evaluate alternatives or
  limited custom work; placeholder traps do not qualify as the final result.
- New mechanics, save-format changes and soundtrack composition are not applicable because
  this feature changes presentation. Existing save/settings and input flows still need
  integration verification.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each anvil MUST have the recognizable face, horn, waist and foot in US1/AS1,
  visible at normal camera distance rather than only in close-ups.
- **FR-002**: Each spike bed MUST display pointed 3D spikes throughout its dangerous region
  and a clear bed boundary, including different authored bed dimensions (US1/AS2).
- **FR-003**: Each buzzsaw MUST display a toothed wheel and central hub, readable rotation
  while active, and a visibly stopped blade while jammed (US1/AS1, AS3).
- **FR-004**: Saw states MUST use a persistent non-colour cue alongside any palette change;
  visuals MUST follow eligibility and contributor changes without a timeout (EC-02).
- **FR-005**: Anvil warning, strike and return MUST agree visibly with the dangerous footprint,
  impact moment and established repeat cycle, including with sound muted (US1/AS4).
- **FR-006**: Hazard artwork MUST communicate exposed danger and body-protected routes
  without changing established contact, timing, support or jam rules (EC-01–EC-02).
- **FR-007**: Chambers MUST share stone/ink surfaces, iron machinery, gothic architectural
  motifs, identifiable entrance/exit and selective experiment signage (US2/AS1).
- **FR-008**: Lighting and backgrounds MUST retain readable silhouettes, clear ground
  shadows and visible floor height/edges; neon accents MUST prioritize existing effects
  and gameplay states over decoration (US2/AS2–AS4).
- **FR-009**: Artwork MUST preserve whole-puzzle visibility in South-east, South-west,
  North-west and North-east diagonal isometric views, separated by 90° yaw with authored
  elevation, tilt, distance and zoom preserved. Foreground dressing MUST accommodate
  the selected view and leave the exit frame visible (US2/AS3; EC-06).
- **FR-010**: Player, released/held corpses, placement validity, ground shadow, airborne
  surface ring, body count, oldest marker, plate requirement/activation and door state
  MUST remain distinguishable under the new treatment (US2/AS3–AS4).
- **FR-011**: Dressing and cosmetic animation/effects MUST NOT add physical obstacles,
  support or hazard contacts. Corpse support MUST remain independent of its visual rig,
  and traps MUST NOT destroy or displace existing bodies (US3/AS1–AS2).
- **FR-012**: All six rooms MUST receive the accepted hazard/environment treatment,
  preserving teaching order, recorded solutions and the five-body creation-order limit.
- **FR-013**: Keyboard/controller interactions, restart, progression, saved-room resume,
  settings, completion and replay MUST preserve existing behavior, with presentation
  reflecting fresh or updated state correctly (US3/AS3–AS4).
- **FR-014**: Suitable free 3D packs MUST be evaluated before making equivalent custom
  artwork. Prefer reuse that meets style, silhouettes, readability and distribution needs;
  a Godot-ready package is a convenience, not grounds to reject suitable standard 3D assets.
  Record a decision for each hazard and environment family.
- **FR-015**: Every selected external asset MUST have recorded creator, source URL, exact
  pack/version or archive identity, free-edition membership, supplied licence/credit
  obligations and modifications. Verify that supplied terms permit adaptation and game
  redistribution; keep accompanying licences and required credits.
- **FR-016**: Selection MUST check actual free contents and playable suitability; storefront
  screenshots or compatibility claims alone MUST NOT count as acceptance. Use one dominant
  environment style and harmonize supplemental traps with the reused character.
- **FR-017**: Custom artwork MUST be limited to documented coverage/suitability gaps after
  free-pack evaluation. Retain available editable sources and adaptation records; distinguish
  freely supplied runtime assets from source files sold separately.
- **FR-018**: One representative playable chamber with all three trap types and the reused
  character MUST prove the proposed treatment before six-room art rollout. Reuse existing
  greybox evidence and close outstanding affected visual/interaction checks explicitly;
  asset metadata alone is insufficient.

### Verification Requirements *(mandatory)*

- **VR-001 — Sourcing:** During planning, compare at least three plausible free packs,
  including the initial [candidate notes](asset-candidates.md). Record coverage, free versus
  paid contents, supplied licence evidence, visual fit, usability, adaptation effort and
  accept/reject reasoning. Inspect actual files before adoption; document custom gaps.
  No candidate is selected by this specification.
- **VR-002 — Representative proof:** In a playable chamber, validate the character alive
  plus five corpses, all three traps, plate/door cues, rebuilt bridge/stack, pickup/placement
  and oldest-body consequences. Review materials, poses, scale and visual agreement with
  support. Perform each physical interaction ten consecutive times from a defined fresh
  setup with zero failures before full-room art rollout.
- **VR-003 — State regressions:** Run repeatable checks for EC-01–EC-04 and EC-07:
  rapid/simultaneous deaths, carrying death, invalid placement, eviction in each role,
  multi-body jams, plate/door updates, restart, transitions and saved-room resume. Run
  applicable existing checks and add checks for changed presentation/state relationships;
  use automated isolated checks where practical and reproducible manual steps otherwise.
- **VR-004 — Readability:** Inspect six dressed rooms in four diagonal views at 1280×720,
  1920×1200 and 1024×768 (72 room/view/window combinations). Check fresh and representative
  five-body arrangements, warning/active/jammed states and applicable effects. Required cues
  remain identifiable, safe routes correctly represented and the whole puzzle visible.
  Include evidence from normal camera distance, not only asset renders.
- **VR-005 — Player review:** Use five players unfamiliar with the new artwork. At
  1280×720 without trap-name labels, show three hazards from each of four views, giving
  60 recognition observations. Separately test warning footprints and active/jammed judgments
  with ordinary cues and sound muted. Record recognition, misread routes, jump judgment,
  placement frustration, help requests and atmosphere ratings (SC-001–SC-004).
- **VR-006 — Solutions, input and platforms:** Repeat each intended room solution ten
  times under regression conditions with the new art; play the connected sequence and
  recovery flows with keyboard and controller on Windows and macOS. Cover mute/settings,
  completion and replay. Record all four native platform/input combinations; export
  inspection or synthetic controller input does not replace these checks.
- **VR-007 — Performance:** Establish exact engine, asset budgets, target devices, rendering
  conditions and acceptance targets in the plan using observed evidence and the existing
  plan's provisional goals. Measure the representative chamber and densest dressed room
  with one player, five corpses and effects active. Report actual measurements; headless
  results do not establish rendered performance.
- **VR-008 — Evidence:** During implementation, record setup, expected outcome, actual
  result, repeats and defects in this feature's `validation.md`, with sourcing decisions
  and references to existing evidence. Report unrun checks as UNVERIFIED. Resolve acceptance
  defects before marking the artwork complete. Full-slice playtests also record completion
  time against the existing 20–30 minute target, help requests, misunderstood rules,
  jump judgment and placement frustration.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 54 of 60 label-free observations identify the correct hazard,
  with at least 18 of 20 correct observations for each type (VR-005).
- **SC-002**: In each view, all five reviewers correctly distinguish active from jammed
  saws and identify the anvil danger footprint before impact with sound muted. No reviewed
  intended safe route is mistaken for exposed danger or the reverse.
- **SC-003**: All 72 room/view/window combinations retain the complete puzzle and required
  player/body/placement/landing/weight/door cues without decoration/effect obstruction;
  all requested hazard instances use accepted recognizable forms (VR-004).
- **SC-004**: At least four of five reviewers describe the representative chamber as a
  gothic or macabre testing setting and rate its visual coherence at least 4 out of 5
  after a five-minute playable session; record descriptions and remaining presentation gaps.
- **SC-005**: Representative interaction trials and ten fresh solutions per room finish
  with zero artwork-induced support, placement, hazard-state, timing or recovery failures
  and never retain more than five bodies (VR-002–VR-003, VR-006).
- **SC-006**: All rooms and connected completion/replay/recovery flows pass Windows-keyboard,
  Windows-controller, macOS-keyboard and macOS-controller review with zero unresolved
  acceptance defects; performance meets measured plan targets.
- **SC-007**: Every adopted external asset has complete provenance/free-edition/licence
  evidence, and every custom hazard/environment piece has a recorded reuse-gap justification.

## Assumptions

- Recognizable stylised objects, gothic stone-and-iron miniature rooms and neon slapstick
  effects satisfy the request within the PRD. Photorealism is outside this interpretation;
  candidate review should establish visual examples.
- The selected reused cow character and existing sound direction remain. Assess available
  sources and missing animations under the existing character requirements; an environment
  pack does not replace that obligation.
- Six authored rooms and scripted solution evidence already exist. Human visual, controller
  and native-platform gates remain partly unverified in the existing validation record.
  Reuse evidence accurately; art production does not retrospectively close those gates.
- Free means the needed files are downloadable at zero purchase cost and supplied terms
  support game distribution. Prefer CC0 candidates where suitable; required credit is
  acceptable. Paid bonus/source editions are not assumed available.
- One pack may not cover atmosphere and all hazards. A primary environment kit plus
  compatible supplemental free props and limited custom gaps is acceptable after comparison
  and playable review.
- Exact asset choices, engine version, budgets, visual tuning and performance measurements
  belong to planning. Recognition thresholds here are acceptance targets, not claims about
  current artwork or player behavior.
