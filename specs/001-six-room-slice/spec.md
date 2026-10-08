# Feature Specification: Six-Room Puzzle Slice

**Feature Branch**: `main` (existing branch; no branch-creation hook configured)

**Feature Directory**: `specs/001-six-room-slice`

**Created**: 2026-10-07

**Status**: Draft — quality validated; ready for planning

**Input**: User description: "from PRD.md"

**Governing documents**: [PRD](../../PRD.md) and
[constitution v1.0.0](../../.specify/memory/constitution.md)

## Scope and Principle Alignment *(mandatory)*

**Slice contribution:** Deliver the complete PRD vertical slice: six authored rooms in
which a player intentionally dies, returns as a clone, and uses persistent corpses to
solve spatial puzzles. The audience is players who enjoy puzzle-platformers and dark
slapstick. The release is free on Itch.io for Windows and macOS, with a first-playthrough
target of 20–30 minutes. Death enables progress and unlimited retries.

**Included:** Screen-relative movement and jumping in full 3D; a stationary isometric,
orthographic view; solid supporting corpses; carrying and assisted placement; a visible
five-body limit; spikes, buzzsaws, falling anvils, weighted plates, and linked exits;
room restart; local room progress and settings; complete keyboard/controller play;
menus, onboarding, completion, replay, character reuse, visual feedback, and audio.

**Excluded:** Jointed physical ragdolls, aimed throwing, simulated dragging, hanging
ropes, crates, projectile shielding, turrets, additional hazard types, camera rotation,
multi-character swapping, inventory systems, complex enemy AI, branching stories,
elaborate lighting systems, and a separate body-generation button.

**Applicable principles:** All five apply to the full slice.

| Principle | Application |
| --- | --- |
| I. Focused Six-Room Slice | Fixed teaching sequence, intended solutions within five bodies, explicit exclusions, and measured pacing. |
| II. Reliable Corpse Physics and State | One body per death, creation-order replacement, stable support, and consistent carrying/hazard transitions. |
| III. Readable Puzzles and Dependable Controls | Whole-room framing, screen-relative movement, landing cues, placement previews, and visible puzzle states. |
| IV. Complete Play Flow and Recovery | Full keyboard/controller flow on both platforms, room restart, saved-room resume, settings, completion, and replay. |
| V. Prove Interactions Before Expanding | First prove one greybox room and one reused character, then finish systems, author the six rooms, and playtest. |

**Puzzle progression:** Each room must have a recorded, repeatable intended solution
within the cap. Exact arrangements and route geometry are established through the first
playable proof and room design. Reliable alternative solutions are allowed, but simply
walking around a blocking hazard must not bypass the intended puzzle.

| Room | Teaching goal | Required solution evidence |
| --- | --- | --- |
| 1. Sacrifice and traversal | Death, replacement clones, and bodies supporting traversal across spikes. | A route across spikes using hazard-created bodies. |
| 2. Carry and weigh | Pickup, valid placement, and plate weight. | Deliberate body placement that satisfies a plate and permits reaching the exit. |
| 3. Jam the machinery | Persistent saw jams and the consequences of retrieving the jamming body. | A route through a jammed saw and a demonstration of its reactivation on retrieval. |
| 4. Combine and replace | Telegraphing of falling anvils and oldest-body replacement. | Anvil interaction and a demonstrated sixth-body replacement with visible consequences. |
| 5. Plan the route | Combining taught hazards and weight requirements. | Deliberate allocation of bodies across established interactions. |
| 6. Final experiment | A final combination of previously taught rules. | A complete solution using taught mechanics, followed by completion and replay. |

## User Scenarios & Testing *(mandatory)*

Story priorities determine the order of playable increments; every story is required
for release. Later stories may use earlier interactions. Each independent test below
can be performed in a prepared room or flow without completing all six authored rooms.
Acceptance scenarios are referenced as US1/AS1, US1/AS2, and so on.

### User Story 1 - Turn Death into a Traversable Route (Priority: P1)

As a player, I want to explore a readable room, sacrifice a clone, and use the body left
behind so that dying advances my understanding and helps me reach the exit.

**Why this priority**: This proves the central promise that death is a useful puzzle action.

**Independent Test**: In one room with a safe entrance and a spike crossing, move and jump,
die enough times to make the intended body route, and traverse it after respawning.

**Acceptance Scenarios**:

1. **Given** a fresh room, **When** I move in each screen direction and jump, **Then**
   movement follows that direction, my shadow shows my ground position, and the stationary
   camera keeps the player and the complete puzzle visible.
2. **Given** an exposed lethal hazard, **When** my clone touches it, **Then** exactly one
   body remains at the death location and one controllable replacement appears at the safe
   entrance after brief feedback; other bodies and puzzle state remain.
3. **Given** enough bodies arranged for the intended spike crossing, **When** I walk or
   jump across them, **Then** they support me and each other without unintended collapse
   or a required lucky bounce; exposed spikes remain lethal.
4. **Given** any number of prior deaths, **When** I die again, **Then** I receive another
   attempt without a game-over screen or a retry limit.

---

### User Story 2 - Carry and Place Bodies Deliberately (Priority: P1)

As a player, I want to carry one nearby body and preview where it will rest so that I can
build a bridge, stack bodies, or supply plate weight through deliberate placement.

**Why this priority**: Reliable placement makes the puzzles repeatable instead of dependent
on accidental body positions. This story uses US1's death and support rules.

**Independent Test**: With bodies available in a room containing spikes and a plate, pick
up and place bodies on each supported surface, reject invalid placements, and build a
traversable arrangement and a plate-controlled exit route.

**Acceptance Scenarios**:

1. **Given** a nearby released body, **When** I pick it up, **Then** I hold only that body;
   it remains counted in creation order but ceases to support me, weigh on plates, or jam
   a saw. A second pickup cannot add another held body.
2. **Given** a held body and a nearby valid floor, spike-bed, or body surface, **When** I
   preview and release it, **Then** the preview indicates validity and the body settles
   in the shown stable pose, without requiring a placement grid.
3. **Given** a preview overlapping my clone, a wall, or another body's occupied space,
   or extending beyond reach, **When** I attempt placement, **Then** the preview indicates
   invalidity and the body remains held without changing the count or creation order.
4. **Given** a plate requiring one body, **When** I place a body on it and leave the plate
   myself, **Then** the plate remains active and its linked door stays open; picking up
   that body removes its weight and updates the door.
5. **Given** a held body, **When** I die, **Then** it is released, a new death body is
   created, and my replacement holds nothing; the five-body replacement rule still applies.

---

### User Story 3 - Allocate Five Bodies Across Hazards (Priority: P1)

As a player, I want visible body order and consistent machinery reactions so that I can
predict the consequences of moving or replacing bodies while solving a room.

**Why this priority**: Body allocation is the main puzzle constraint. This story combines
US1 and US2 with the remaining hazard interactions.

**Independent Test**: In one prepared room, jam a saw, satisfy a multi-unit plate, experience
an anvil drop, and create a sixth body while the oldest serves each possible puzzle role.

**Acceptance Scenarios**:

1. **Given** five bodies, **When** another death creates a body, **Then** the previously
   identified oldest disappears in a non-solid burst, the new body becomes newest, the
   count remains five, and the next-oldest marker updates correctly.
2. **Given** bodies of different ages, **When** I pick up and release an older one,
   **Then** it retains its place in creation order and the next removal remains predictable.
3. **Given** an active saw, **When** a released body contacts its jam point, **Then** the
   saw visibly stops and its designated route is safe; it stays jammed without a timer
   until no released body remains at the jam point, then visibly reactivates.
4. **Given** a plate requiring multiple units, **When** the live player and released
   bodies bring its weight to that requirement, **Then** it activates and opens the linked
   door; falling below the requirement closes the door and updates its visible state.
5. **Given** an anvil's marked drop area, **When** a drop occurs, **Then** a visible warning
   precedes it, a clone caught beneath dies once, existing bodies survive, and another
   warned drop can occur later.
6. **Given** the oldest body is held, supporting a stack, pressing a plate, or jamming a
   saw, **When** it is replaced, **Then** its role ends immediately: carrying clears,
   unsupported bodies settle, or the affected plate/door/saw updates according to remaining
   bodies. No invisible support, weight, or jam remains.

---

### User Story 4 - Recover and Resume a Puzzle (Priority: P2)

As a player, I want to restart a failed arrangement and return to my current room in a
later session so that experimentation cannot permanently block progress.

**Why this priority**: Recovery makes the physical puzzles safe to experiment with. It can
be assessed in one room using the interactions from US1–US3.

**Independent Test**: Change the room state, hold a body, adjust sound settings, restart,
then reopen the game and verify room and settings behavior.

**Acceptance Scenarios**:

1. **Given** any failed arrangement, held body, or changed hazard state, **When** I restart,
   **Then** the player returns to the initial entrance, all bodies and creation order clear,
   carrying clears, and hazards, switches, and doors match a fresh room.
2. **Given** a saved current room and volume settings, **When** I close and reopen the
   game, **Then** I resume that room at its entrance in the original puzzle state, with
   no bodies or held item, and the same volume settings.
3. **Given** I have entered the next room, **When** I reopen, **Then** that next room is
   the saved current room and starts fresh rather than restoring the preceding puzzle.
4. **Given** no usable saved progress, **When** I start, **Then** I can play from room 1
   with default settings without being blocked by a missing or unreadable save.
5. **Given** a death or room transition is already underway, **When** I request restart,
   **Then** the resulting active room has exactly one live player and a consistent fresh
   state, without late-arriving bodies or duplicated transitions.

---

### User Story 5 - Learn and Complete Six Experiments (Priority: P2)

As a player, I want a short sequence that teaches each interaction before combining it
so that I can solve a final puzzle and replay the experience.

**Why this priority**: Authored progression turns the proven interactions into a finished
slice. Full room production follows the greybox and character proof.

**Independent Test**: Play each room from a fresh state using its recorded solution, then
play the sequence end to end and replay from the completion screen.

**Acceptance Scenarios**:

1. **Given** a first visit to the sequence, **When** I play rooms 1–4, **Then** the rooms
   introduce the rules in the progression table, with contextual guidance available when
   the relevant action or hazard first appears.
2. **Given** the taught interactions, **When** I play rooms 5 and 6, **Then** each combines
   established rules, has an intended solution within five bodies, and does not require
   precision jumping, timed jump sequences, or walking around the blocking hazard.
3. **Given** an open exit in rooms 1–5, **When** the live player enters, **Then** the next
   room begins once with no carried body or old bodies; a corpse entering alone does not
   advance the room, and a closed exit cannot be used.
4. **Given** the open final exit, **When** the live player enters, **Then** a completion
   screen appears with a usable replay option.
5. **Given** the completion screen, **When** I choose replay, **Then** room 1 starts fresh
   and becomes the saved current room, while my chosen settings remain.

---

### User Story 6 - Play the Entire Slice with Either Input Method (Priority: P2)

As a player on either supported desktop platform, I want to use my keyboard or controller
for gameplay and menus so that no part of the experience requires switching input methods.

**Why this priority**: Both input methods and both platforms are release requirements.
Controls are exercised from the first playable increment through final release validation.

**Independent Test**: On Windows and macOS, use each input method separately to start,
play, restart, adjust settings, finish, and replay.

**Acceptance Scenarios**:

1. **Given** only a keyboard or only a controller, **When** I follow the complete game
   flow, **Then** movement, jumping, pickup, placement, menus, restart, completion, replay,
   and exit are all usable without a mouse or the other input method.
2. **Given** the current input method, **When** a control is introduced or a menu is opened,
   **Then** the available actions and selected menu item are visibly identifiable.
3. **Given** the audio settings, **When** I change music or sound-effect volume, **Then**
   only the chosen category changes; each can be muted independently and is retained
   after reopening.

---

### User Story 7 - Read the Puzzle Through Dark Slapstick (Priority: P3)

As a player, I want exaggerated deaths and a macabre testing-facility atmosphere while
still being able to recognise safe routes, body placements, and machinery states.

**Why this priority**: Presentation gives the slice its identity, while readability must
already hold during the greybox and character assessment.

**Independent Test**: Observe and play a representative room at the actual camera distance
with one live clone, five bodies, active and inactive machinery, captions, and audio.

**Acceptance Scenarios**:

1. **Given** the representative room, **When** I view it from the normal camera, **Then**
   the gothic miniature chambers, high-contrast silhouettes, ink-and-wash-inspired surfaces,
   and neon gore are visible without hiding the player, important bodies, hazards, or exit.
2. **Given** movement, jumping, carrying, or death, **When** the reused character animates,
   **Then** its appearance remains readable with five bodies present and visual deformation
   does not change where a body provides support.
3. **Given** repeated deaths and oldest-body removals, **When** effects and subject captions
   play, **Then** they communicate the event without obscuring the next decision or extending
   the respawn delay; counts and subject numbers do not create a failure condition.
4. **Given** a playable room with audio enabled, **When** hazards and deaths occur,
   **Then** cheerful elevator jazz or period-style muzak contrasts with cartoon trap sounds,
   while warning and state information remains visible even when audio is muted.

### Edge Cases

| ID | Situation | Required outcome |
| --- | --- | --- |
| EC-01 | Multiple lethal contacts during one death or its feedback. | One death body and one replacement player; no duplicate count or subject increment. |
| EC-02 | Rapid repeated deaths up to and beyond the cap. | Each completed death adds one newest body, removes only the oldest when required, and leaves one live replacement. |
| EC-03 | Sixth body while the oldest is held. | Old held body disappears and carrying clears; no reference to a missing body remains in the player's actions. |
| EC-04 | Death while carrying at the five-body cap. | Held body releases, one new body is created, and the oldest is removed; the formerly held body survives only if it was not oldest. |
| EC-05 | Invalid placement into the clone, wall, body, or beyond reach; pickup with no available body. | Invalid placement keeps the held body; unsuccessful pickup leaves state unchanged. No extra body is created. |
| EC-06 | Pickup/removal of support, plate weight, or a saw-jamming body. | Remaining bodies settle; plate/door/saw state reflects remaining eligible contacts immediately, without phantom effects. |
| EC-07 | Several bodies at a jam point or more plate weight than required. | Removing one does not clear a jam or close a door while sufficient eligible contact/weight remains. |
| EC-08 | Anvil hits bodies, or a saw/spike contacts an existing body. | Bodies survive; only live-player contact can cause a new death body. |
| EC-09 | Restart during death feedback, a held-body action, or an exit transition. | The active room resets consistently, leaving one live player and zero bodies; if the next room has already become active, restart applies there. |
| EC-10 | A corpse reaches an exit, or the live player remains at an exit boundary. | Corpses never complete rooms; one live-player entry produces at most one room transition. |
| EC-11 | Closing while a body is held or a puzzle is partly solved. | Reopening restores the saved current room's original state and settings, without held or arranged bodies. |
| EC-12 | Missing/unreadable saved progress or a saved room outside the six-room sequence. | Start room 1 with usable defaults; preserve valid settings when they can be recovered independently. |
| EC-13 | Reopening after completion without choosing replay. | Resume room 6 in its original state; choosing replay instead resets saved progress to room 1. |
| EC-14 | Player enters spikes while already on a body bridge, or a jam ends during crossing. | Exposed lethal contact remains lethal; a valid supported route or still-jammed route remains traversable. |
| EC-15 | A linked door closes while the live player occupies its passage. | The door blocks traversal when weight falls below its requirement, without killing or trapping the player; any necessary displacement returns the player to a safe position on the entry side. |

## Requirements *(mandatory)*

### Functional Requirements

The acceptance references below identify the primary evidence for each requirement.
Verification requirements and measurable outcomes apply across these references.

**Movement and death**

- **FR-001**: The game MUST provide a linear sequence of exactly six authored rooms with
  the teaching goals in the progression table. Acceptance: US5/AS1–AS2.
- **FR-002**: Each room MUST show its entire playable puzzle through a stationary
  orthographic camera at an isometric angle; foreground geometry MUST NOT hide the live
  player, hazards, or bodies needed for the puzzle. Acceptance: US1/AS1; US7/AS1.
- **FR-003**: Players MUST move across the floor in any direction relative to the screen
  and jump manually, with a ground shadow showing landing position. Intended routes MUST
  provide broad landing surfaces and avoid precision or timed jump sequences.
  Acceptance: US1/AS1, AS3; US5/AS2.
- **FR-004**: Each hazard death MUST leave exactly one body at the death location and
  produce exactly one replacement player at a safe entrance within two seconds of lethal
  contact, including when hazards overlap. Acceptance: US1/AS2; EC-01; SC-005.
- **FR-005**: Death MUST preserve existing bodies and puzzle state except for the new body
  and any consequences of its creation or cap replacement, and MUST allow unlimited
  retries without game over. Acceptance: US1/AS2, AS4; EC-02.
- **FR-006**: Bodies MUST behave as solid props capable of supporting the player and other
  bodies on floors and spike beds, regardless of visual squashing or flopping. Existing
  bodies MUST survive hazards and persist until cap replacement, restart, or departure.
  Acceptance: US1/AS3; US7/AS2; EC-08.

**Carrying and placement**

- **FR-007**: Players MUST be able to pick up one nearby released body and carry at most
  one at a time; an unsuccessful pickup MUST leave state unchanged. Acceptance: US2/AS1; EC-05.
- **FR-008**: A held body MUST count toward the cap and retain its age, while contributing
  no support, plate weight, or saw jam. Acceptance: US2/AS1; US3/AS2.
- **FR-009**: Carrying MUST show a nearby preview with distinguishable valid and invalid
  states, and allow stable placement on floors, other bodies, and spike beds without a
  grid. Table/plate approaches MUST permit a bounded nearby adjustment to a fully
  supported pose when the nominal aim straddles an edge, preserving facing and all
  reach/overlap/reservation rules; a valid nominal aim MUST stay unchanged.
  Acceptance: US2/AS2–AS3; DEV-004.
- **FR-010**: Release at a valid preview MUST place the body in the indicated stable pose
  and restore its support, weight, and eligible hazard interactions. Acceptance: US2/AS2, AS4.
- **FR-011**: Placement intersecting the player, walls, or occupied body space, or beyond
  nearby reach, MUST be rejected while keeping the body held. Acceptance: US2/AS3; EC-05.
- **FR-012**: Death while carrying MUST release the existing body, create one new death
  body, apply the cap, and clear carrying before control returns. Acceptance: US2/AS5; EC-04.

**Body allocation and machinery**

- **FR-013**: At most five bodies, including a held body, MUST remain in a room. A sixth
  creation MUST remove the oldest by creation order, independent of pickup or placement.
  Acceptance: US3/AS1–AS2; EC-02–EC-04.
- **FR-014**: The displayed body count and next-to-disappear marker MUST match the actual
  count and oldest body after every creation, pickup, release, removal, or reset; an empty
  room MUST show zero with no oldest marker. Acceptance: US3/AS1–AS2; US4/AS1.
- **FR-015**: Cap removal MUST produce a visible confetti or neon-gore burst that cannot
  collide with or support anything. Acceptance: US3/AS1; US7/AS3.
- **FR-016**: Pickup or removal MUST immediately end that body's support, weight, and jam
  effects; stacks MUST settle after support removal and carrying MUST clear if its body is
  removed. Remaining eligible bodies MUST continue to contribute. Acceptance: US3/AS6; EC-06–EC-07.
- **FR-017**: Exposed spike contact MUST kill the live player, while sufficient body
  bridges or stacks MUST permit supported traversal. Acceptance: US1/AS2–AS3; EC-14.
- **FR-018**: Active saw contact MUST kill the live player. A released body at the jam
  point MUST stop the saw indefinitely and permit traversal through its designated route.
  The saw MUST reactivate when no eligible jamming body remains. Acceptance: US3/AS3; EC-07, EC-14.
- **FR-019**: Falling anvils MUST visibly warn before repeatable drops, kill a live player
  caught beneath, and leave existing bodies intact. Acceptance: US3/AS5; EC-08.
- **FR-020**: Plates MUST visibly show their one-unit or multi-unit requirement and active
  state. The live player on a plate and each released body resting directly on it MUST
  contribute one unit; a held body MUST contribute none. Acceptance: US2/AS4; US3/AS4.
- **FR-021**: Linked doors MUST open when plate weight meets the requirement and close when
  it falls below. Closing MUST NOT kill or trap a player in the passage; any necessary
  displacement MUST return the player to a safe position on the entry side.
  Acceptance: US3/AS4; EC-07, EC-15.
- **FR-022**: Active and jammed saws, anvil warnings, plate activation, exits, body count,
  and oldest-body identity MUST be distinguishable from the normal room camera, including
  while audio is muted. Acceptance: US3/AS1, AS3–AS5; US7/AS4; SC-008.

**Progression and recovery**

- **FR-023**: Only a live player entering an open exit MUST advance or complete a room;
  each entry MUST produce at most one transition. Acceptance: US5/AS3–AS4; EC-10.
- **FR-024**: Every room MUST have a repeatable intended solution within five bodies;
  layouts MUST block simple walk-around bypasses while allowing reliable alternative
  solutions using established rules. Acceptance: US5/AS2; SC-001.
- **FR-025**: The game MUST introduce interactions through contextual guidance and the
  stated room progression before requiring them in combined puzzles. Acceptance: US5/AS1–AS2.
- **FR-026**: Room restart MUST be reachable with keyboard and controller and restore
  the initial player position, hazards, switches, and doors, clearing all bodies, creation
  order, and carrying state, including during interrupted actions. Acceptance: US4/AS1, AS5.
- **FR-027**: Entering another room MUST start its original puzzle with no carried or
  surviving bodies from the previous room and save it as the current room.
  Acceptance: US4/AS3; US5/AS3.
- **FR-028**: Local progress MUST preserve the current room and player settings; reopening
  MUST resume that room fresh, with no saved corpse arrangement. Acceptance: US4/AS2–AS3; EC-11.
- **FR-029**: Missing, unreadable, or out-of-range progress MUST fall back to room 1 without
  blocking play; usable settings MUST be retained when independently recoverable.
  Acceptance: US4/AS4; EC-12.
- **FR-030**: The final exit MUST lead to a completion screen with replay. Replay MUST
  start room 1 fresh, update saved progress, and retain settings. Reopening a completed
  run before replay MUST resume room 6 fresh. Acceptance: US5/AS4–AS5; EC-13.

**Complete flow and presentation**

- **FR-031**: Windows and macOS releases MUST each support starting, all gameplay actions,
  menus, restart, settings, completion, replay, and exit with keyboard alone or controller
  alone. Acceptance: US6/AS1.
- **FR-032**: Onboarding and menus MUST identify available controls for the input method
  being used and make the selected menu action visible. Acceptance: US6/AS2.
- **FR-033**: Music and sound effects MUST have separate volume controls, each including
  mute, and these choices MUST survive restart, replay, and reopening. Acceptance: US6/AS3;
  US4/AS2; US5/AS5.
- **FR-034**: Rooms MUST follow the PRD's gothic miniature, high-contrast, ink-and-wash and
  neon-gore direction with lighting that keeps depth and landing cues visible.
  Acceptance: US7/AS1; SC-008.
- **FR-035**: The slice MUST use one selected character for all clones and prioritise the
  existing character candidates from the PRD. Movement, jump, carry, and death presentation
  MUST be assessed in play with one live clone and five bodies. Acceptance: US7/AS2; VR-004.
- **FR-036**: Death and replacement feedback MUST use exaggerated animation, effects, and
  humorous subject/death captions without changing physical support, obscuring required
  puzzle information, or treating death count as failure. Acceptance: US7/AS2–AS3; US1/AS4.
- **FR-037**: The audio presentation MUST contrast cheerful elevator jazz or period-style
  muzak with cartoon hazard/death sounds; critical state and warning information MUST
  remain visible without audio. Acceptance: US7/AS4; SC-008.
- **FR-038**: The validated slice MUST be prepared for a free Windows and macOS release on
  Itch.io as a feedback and portfolio build. Acceptance: release validation in VR-006 and
  SC-002 establishes both playable builds; the release listing identifies both platforms
  and has no required purchase price.

### Verification Requirements *(mandatory)*

These requirements explicitly request verification tasks in the implementation task list.
All evidence must distinguish completed checks from checks not yet performed. Numeric
trial counts and the respawn threshold below are initial acceptance assumptions, not
results already measured.

- **VR-001**: Define and run repeatable checks for FR-004–FR-021 and EC-01–EC-08, EC-14,
  and EC-15. Include simultaneous lethal contacts, rapid deaths, all invalid-placement
  categories, each oldest-body role, surplus plate weight, and multiple jamming bodies.
  Repeat each applicable scenario at least ten times from a documented starting state.
  Use automated checks for isolated state rules where practical; otherwise record exact
  manual actions and results.
- **VR-002**: Define and run playable trials of every intended bridge/stack and room
  solution. Rebuild each arrangement from a fresh room and traverse it ten consecutive
  times, with no unintended support failure, hidden bypass, or dependence on lucky bounces.
  Record the maximum simultaneous body count and the actions in each solution.
- **VR-003**: Before full room production, demonstrate the movement, jumping, death,
  respawn, carrying, preview, stack, plate, saw-jam, and cap behaviors together in one
  greybox room. Record expected and actual outcomes, including manual camera and control
  checks; this proof does not require all six finished rooms. For DEV-004, run ten
  rebuilt table-edge, diagonal, raised-table, two-body, obstacle, undersized-surface,
  and stale-preview trials; verify bounded adjustment, unchanged valid aim, stable
  settling, two direct plate units, and retained holding on invalid release. Retest
  placement feel/readability with keyboard and physical controller in the greybox.
- **VR-004**: Before full room production, assess one reused character at the actual
  camera angle and distance with five bodies present. Record visual fit, material/scale
  suitability, animation coverage and gaps, and performance observations. Resource or
  animation names alone do not establish that the character works in play. Automated
  presentation checks MUST verify animation/effect collision isolation, bounded cosmetic
  feedback, unchanged respawn deadlines under overlapping contacts, correct hazard types
  for custom IDs, and cue deduplication/retirement with independent audio routing. These
  checks supplement the required rendered and listening reviews.
- **VR-005**: Run EC-09–EC-13 and all US4 recovery scenarios at least ten times each,
  including restarting with a held oldest body and reopening a partly solved room.
  Record the resulting room, live-player count, body count, carrying state, puzzle state,
  and settings. A fresh-state outcome must match a fresh entry into the active room.
- **VR-006**: Before release, complete a fresh six-room run, settings changes, restart,
  reopen, completion, and replay in each of four combinations: Windows/keyboard,
  Windows/controller, macOS/keyboard, and macOS/controller. Record the build, operating
  system, input device, and outcome for each. Untested combinations remain unverified.
- **VR-007**: Conduct at least five first-time playtests with people who have not seen
  the solutions. Record active completion time, help requests, misunderstood rules,
  difficulty judging jumps, placement frustration, and whether the player correctly
  identifies the cues in SC-008. Use the findings to revise puzzles and pacing and record
  follow-up results for changed areas.
- **VR-008**: Record setup, expected outcome, actual result, and outstanding defects in
  this feature's `validation.md`, with reproducible steps in `quickstart.md` where useful.
  Planning must define any further tuning and performance measurements. Release requires
  passing applicable acceptance checks; unperformed checks and acceptance defects must
  remain visible until resolved.

### Key Entities *(include if feature involves data)*

- **Live subject**: The single controllable clone, its position, living/dead status, current
  room, optional held body, and displayed subject/death information.
- **Corpse**: One hazard-created body with creation age, position, held/released status,
  and current support, plate, or saw relationships; it may be removed only by the defined
  lifecycle rules.
- **Body order**: The room's creation-ordered set of up to five bodies, including any held
  body, determining the count and next removal.
- **Room**: An authored puzzle with an entrance, fixed view, original arrangement, hazards,
  plates, linked exit, teaching objective, and repeatable intended solution.
- **Hazard**: A spike bed, buzzsaw, or falling anvil, with its visible lethal/warning/jammed
  state and its different effects on live subjects and corpses.
- **Pressure plate and exit**: A required weight, contributing occupants, activation state,
  and linked passage; only the live subject can complete the room through an open exit.
- **Saved progress and settings**: The current room and chosen music/sound-effect volumes;
  corpse arrangements, held bodies, and transient machinery states are not retained.
- **Validation record**: The checked build and conditions, scenario, expected and actual
  outcome, room solution steps, playtest findings, and unresolved defects.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Each of the six rooms is completed from its original state ten consecutive
  times using its recorded intended solution, never retaining more than five bodies and
  requiring no precision jumping, timed jump sequence, or lucky bounce.
- **SC-002**: All four platform/input combinations in VR-006 pass the entire game flow,
  including menus, settings, restart, reopen, completion, and replay without switching
  input methods or encountering a progression blocker.
- **SC-003**: Every intended body bridge and stack supports ten consecutive independently
  rebuilt traversals without unintended collapse or a mismatch between visible bodies
  and usable support.
- **SC-004**: All state and recovery scenarios in VR-001 and VR-005 pass their ten repetitions
  with zero duplicate death bodies, duplicate replacement players, bodies beyond the cap,
  incorrect oldest-body removals, or stale carrying/plate/door/saw effects.
- **SC-005**: Across twenty measured hazard deaths, including overlapping contacts and
  death while carrying, control returns to one live clone at the safe entrance within
  two seconds in every trial.
- **SC-006**: In ten valid placement attempts per allowed supporting surface and ten
  invalid attempts per rejection category from US2, every preview matches the observed
  outcome; invalid attempts leave the body held and valid attempts produce stable support
  or the intended puzzle contact.
- **SC-007**: At least five first-time playtests produce recorded completion times and
  usability observations. A median active completion time of 20–30 minutes is the pacing
  target; a result outside it requires a documented pacing review and follow-up playtest,
  rather than being presented as an achieved duration.
- **SC-008**: At least 80% of first-time testers (at least four in the initial group of
  five) correctly identify the exit, landing position, valid versus invalid placement,
  oldest body, plate requirement and
  activation, active versus jammed saw, and anvil warning when each is introduced, using
  the normal camera and available in-game guidance without facilitator explanation.
- **SC-009**: The representative character passes the US7 presentation review for all four
  actions (movement, jumping, carrying, death) with five corpses visible, without missing
  visuals, obscured required cues, or animation changing the usable body support.
- **SC-010**: Both volume categories can be independently adjusted and muted in every
  platform/input combination, and selected values survive restart, replay, and reopening
  in all recorded settings checks.

## Assumptions

- This invocation specifies the complete PRD slice as one feature. The greybox is its
  first delivery milestone, not a separate feature or a reduction in release scope.
- The trial counts, five-person initial playtest group, four-of-five readability target,
  and two-second respawn limit are explicit initial acceptance defaults added to make the
  PRD's reliability and responsiveness goals measurable. They can be refined through an
  explicit spec amendment informed by the greybox and playtest evidence.
- For pacing, active completion time runs from first gaining control in room 1 to the
  completion screen, includes deaths and restarts, and excludes breaks outside play.
  Non-completion and facilitator help are recorded alongside timings, not discarded.
- Each plate counts the live player and each released body directly resting on it as one
  unit. A released body stably resting on a contributing corpse adds one more unit when
  its support chain reaches the plate; bodies resting beside the plate or on held/
  ineligible bodies do not. Multi-unit plate layouts must offer space for their required
  contributors.
- If several released bodies occupy a saw jam point, the saw stays jammed while at least
  one remains. This makes removal obey the same remaining-contributor rule as plates.
- Restart applies to the currently active room. A transition already completed makes the
  next room current; otherwise the original room restarts. No interrupted action may
  repopulate a restarted room with old bodies.
- A closing plate-linked door is not an additional lethal hazard. If a player occupies
  its passage, closure safely returns them to the side they entered from instead of
  allowing continued passage without the required weight or trapping them in the doorway.
- No saved progress starts room 1. Invalid progress falls back safely; completing the
  game retains room 6 as current until replay resets it to room 1. There is one local
  progression record; multiple profiles and cloud synchronisation are outside this slice.
- Character selection depends on inspecting the existing cow, crow, lion, and plates
  candidates identified in the PRD. Existing animation metadata is preliminary evidence;
  jump/carry suitability and missing work must be established in the first playable proof.
- Exact control bindings, movement values, placement reach, anvil timing, performance
  targets, asset budgets, and room geometry are planning/tuning decisions. The PRD and
  constitution retain their technical constraints; this specification defines observable
  player outcomes.
- Release validation depends on access to Windows and macOS and a working keyboard and
  controller for each. Checks on unavailable hardware remain unverified until performed.
