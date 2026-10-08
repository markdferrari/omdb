<!--
Sync Impact Report
Version change: unversioned template → 1.0.0 (initial adoption)
Modified principles: all five placeholder slots replaced with:
  1. I. Focused Six-Room Slice
  2. II. Reliable Corpse Physics and State
  3. III. Readable Puzzles and Dependable Controls
  4. IV. Complete Play Flow and Recovery
  5. V. Prove Interactions Before Expanding
Added sections: Technical and Scope Constraints; Development Workflow and Quality Gates;
  concrete Governance rules.
Removed sections: none; instructional placeholder comments removed.
Templates and guidance:
  ✅ updated: .specify/templates/plan-template.md
  ✅ updated: .specify/templates/spec-template.md
  ✅ updated: .specify/templates/tasks-template.md
  ✅ updated: AGENTS.md
  ✅ reviewed, unchanged: .specify/templates/constitution-template.md (generic seed)
  ✅ reviewed, unchanged: .specify/templates/checklist-template.md
  ✅ reviewed, unchanged: PRD.md (source of product requirements)
  ✅ reviewed: installed Spec Kit skill references to the constitution;
    speckit-plan and speckit-tasks remain compatible. Required verification is made
    explicit in feature specifications, satisfying the task skill's test opt-in rule.
  Command templates: .specify/templates/commands/ is absent in this skills installation.
Deferred items: none. Initial ratification and amendment date: 2026-10-07.
-->

# Over My Dead Body Constitution

## Core Principles

### I. Focused Six-Room Slice

The product MUST remain a linear, six-room 3D puzzle-platformer in which hazard deaths
create bodies used to solve puzzles. Each room MUST have a repeatable intended solution
within the five-body limit, and the sequence MUST teach interactions before combining
them. Reliable alternative solutions are welcome. Feature work MUST trace to the slice
defined in `PRD.md`; excluded mechanics MUST remain outside it unless the scope is
explicitly amended. The 20–30 minute first-playthrough duration MUST be treated as a
playtest target, not an assumed result. This boundary keeps the slice small enough to
prove its central mechanic and finish the complete experience.

### II. Reliable Corpse Physics and State

Every death MUST create exactly one corpse and one replacement player, including under
overlapping hazard contacts. A room MUST retain at most five corpses, counting a held
body; a sixth MUST replace the oldest by creation order. Pickup MUST NOT reorder that
queue. Existing corpses MUST survive hazards and persist until limit replacement, room
restart, or departure. Each corpse MUST be one solid physical prop whose stable collision
shape is independent of visual animation. Intended bridges and stacks MUST support
repeatable traversal without reliance on lucky physics bounces.

A held body MUST NOT support the player, press a plate, or jam a saw. Pickup and removal
MUST immediately update affected plates, doors, and saws; removing support MUST allow the
remaining bodies to settle. Removing a held body MUST clear the carrying state. Death
while carrying MUST release the held body and create the new corpse under the same limit.
State changes MUST preserve these rules together so that puzzle outcomes remain explainable.

### III. Readable Puzzles and Dependable Controls

Each room MUST use a stationary orthographic camera at an isometric angle that shows the
entire puzzle. Geometry, lighting, animation, and effects MUST preserve visibility of the
player, important bodies, and hazard states. Movement MUST follow screen directions;
manual jumping MUST use forgiving landings and a clear ground shadow. Intended solutions
MUST NOT require precision jumping or timed jump sequences.

Carrying MUST provide a nearby placement preview with distinct valid and invalid states.
Valid placement MUST align the body into a stable pose before restoring physical
interaction, including on other bodies and spike beds, without a grid. Overlapping or
out-of-reach placement MUST be rejected while keeping the body held. The body count,
oldest body, plate weight requirements, and active or jammed hazards MUST be legible from
the room camera. Dark slapstick MUST reinforce these rules without obscuring them.

### IV. Complete Play Flow and Recovery

Windows and macOS builds MUST support the full game flow with either keyboard or
controller, including menus, movement, jumping, carrying, placement, restart, settings,
completion, and replay. Death MUST allow unlimited retries and return control at a safe
entrance after brief feedback, without a game-over screen.

Room restart MUST restore the initial player position, hazards, switches, and doors and
clear corpses, carrying state, and creation order. Advancing MUST begin a fresh room with
an empty body queue. Local saves MUST preserve the current room and player settings;
reopening MUST load that room in its original state without a corpse arrangement. Music
and sound-effect volume MUST be separately adjustable. Recovery and input coverage are
part of a finished puzzle, not optional polish.

### V. Prove Interactions Before Expanding

Development MUST first validate one greybox room containing a corpse bridge, pressure
plate, and jammable saw. That proof MUST cover movement, jumping, death and respawn,
carrying, placement, stack stability, and oldest-body removal before production of the
full room sequence. One existing Blender character MUST be assessed at the actual camera
angle and distance, including its animations, materials, scale, and performance with the
player and five corpses present. Metadata alone MUST NOT count as visual validation.

Feature specifications MUST explicitly require verification for the rules they affect.
State transitions MUST have repeatable regression checks; use automated checks for
isolated logic where practical and document reproducible manual checks otherwise. Physics,
camera readability, and control feel MUST also be checked in playable scenes. Validation
records MUST state setup, expected outcome, actual result, and outstanding defects. Before
release, playtests MUST record completion time, help requests, misunderstood rules,
difficulty judging jumps, and placement frustration, with findings used to revise the slice.

## Technical and Scope Constraints

- The implementation MUST use Godot 4.x and GDScript, with `CharacterBody3D` for the live
  player and `RigidBody3D` for solid corpse props. Visual rigs MUST remain separate from
  corpse collision behavior; use conservative collision shapes and assisted placement.
- The slice MUST use the PRD's spikes, jammable buzzsaws, falling anvils, weighted plates,
  and linked exit doors. Plates MUST count one unit per live player or released corpse
  resting on them; linked doors MUST track whether the required weight is met. Saw jams
  MUST persist until the jamming body is picked up or removed, without a timer. Falling
  anvils MUST have a clear warning and repeatable drop.
- Asset work MUST prioritise reuse from
  `/home/mark/projects/streets-of-rock/assets/characters`. Retain Blender sources and bring
  the selected GLB/glTF runtime assets into this repository. Record missing jump, carry,
  movement, or death animation work after inspecting the selected character. Clones MUST
  reuse that character; corpse visuals may reuse its mesh in a collapsed pose.
- Presentation MUST follow the PRD's stylised gothic chambers, clear silhouettes, neon
  gore, simple lighting, and cheerful music contrasted with cartoon trap sounds. Effects
  for oldest-body removal MUST be non-colliding.
- Jointed ragdolls, aimed throwing, simulated dragging, hanging ropes, crates, projectile
  shielding, turrets, extra hazard types, camera rotation, multi-character swapping,
  inventory systems, complex enemy AI, branching stories, elaborate lighting systems,
  and a separate body-generation button MUST remain outside this slice.
- Feature plans MUST select and record the exact Godot version, movement and physics
  tuning, asset budgets, and performance targets when relevant, using greybox evidence.
  Targets MUST specify measurement conditions; this constitution does not invent them.
- The release target is a free Windows and macOS build on Itch.io for feedback and a
  portfolio showcase. Platform validation MUST precede release.

## Development Workflow and Quality Gates

1. **Specify:** Use `PRD.md` and this constitution to define scoped player stories,
   observable acceptance scenarios, applicable state edge cases, and explicit verification
   requirements. Mark unrelated rules as not applicable with a reason.
2. **Plan:** Complete the Constitution Check before research and again after design.
   Account for all five principles, the chosen scene/script structure, relevant state
   ownership, asset validation, and the verification approach. Resolve conflicts before
   implementation; recording complexity alone does not waive a principle.
3. **Implement in stages:** Prove the greybox interactions and representative asset, finish
   puzzle systems and recovery, build the six-room teaching sequence, then polish and
   playtest. Tasks MUST include the applicable validation work and dependencies. Incremental
   features need only deliver their stated scope, while the release must satisfy all gates.
4. **Review changes:** Reviews MUST check the affected principles and acceptance scenarios.
   Changes to death, carrying, body removal, hazards, or progression MUST cover relevant
   regressions: simultaneous contacts, rapid deaths, invalid placement, death while
   carrying, oldest-body replacement in each affected role, restart, and saved-room resume.
5. **Release:** All six rooms MUST have recorded repeatable solutions within the cap and
   complete playthrough evidence on Windows and macOS with keyboard and controller.
   Required checks that were not run MUST remain reported as unverified. Release MUST
   wait for these checks and correction of defects that violate acceptance criteria.

## Governance

This constitution governs project specifications, plans, tasks, implementation, and
reviews. `PRD.md` supplies the detailed product requirements; `AGENTS.md` supplies runtime
development guidance. These documents MUST remain consistent. A conflict MUST be resolved
by aligning the affected artifact or explicitly amending this constitution, not by silently
ignoring a rule.

Every amendment MUST document its reason, affected principles, version change, and any
migration work for existing features. The same change MUST update dependent templates and
guidance and prepend a Sync Impact Report listing reviewed files and deferred work. Review
of an amendment MUST check its consistency with the PRD and existing feature artifacts.

Versions MUST follow semantic versioning: MAJOR for incompatible principle or governance
removal or redefinition; MINOR for added principles, sections, or materially expanded
guidance; PATCH for clarifications without changed obligations. Preserve the original
ratification date and set the last-amended date to the amendment date in ISO format.
Compliance MUST be checked during specification, planning, change review, and release.

**Version**: 1.0.0 | **Ratified**: 2026-10-07 | **Last Amended**: 2026-10-07
