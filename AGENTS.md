# Project Guidance

Read [the constitution](.specify/memory/constitution.md) and [the PRD](PRD.md) before
specifying, planning, or implementing features. The constitution defines governing rules;
the PRD supplies detailed behavior and scope. Resolve conflicts explicitly and keep
dependent specifications, plans, tasks, and templates consistent.

This is a Godot 4.x / GDScript 3D puzzle-platformer targeting a six-room Windows and macOS
slice. Preserve the five-body creation-order limit, dependable corpse support and
placement, stationary camera readability, complete keyboard/controller flow, and room
recovery rules. Keep visual rigs independent of solid corpse collision behavior.

Use the Spec Kit artifacts under `specs/` for feature requirements, design decisions,
tasks, and validation evidence. Feature specs must explicitly request applicable
verification so task generation includes it. Prove the greybox interactions and one
reused character before producing the complete room sequence.

For affected state rules, run repeatable regression checks. Validate physics, readability,
and control feel in playable scenes. Record the setup, expected outcome, actual result,
and defects; report checks that could not be run as unverified. Select exact engine
versions, tuning, and measurement targets in feature plans using observed evidence.
