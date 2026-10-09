# Over My Dead Body — Product Requirements Document

## 1. Product Overview

**Elevator pitch:** A macabre, dark-comedy 3D puzzle-platformer where death is the primary puzzle-solving mechanic. Players control a relentlessly unlucky test subject navigating a sadistic facility, intentionally sacrificing themselves to create bodies they can carry, stack over spike pits, use to jam buzzsaws, and place on pressure plates.

**Objective:** Deliver a tightly scoped, six-room vertical slice that proves reliable corpse placement and stacking, readable puzzles, and dark slapstick humor. Target 20–30 minutes for a first playthrough, validated through playtesting.

**Engine:** Godot 4.x using GDScript.

**Presentation:** Full 3D rooms viewed through an orthographic camera with four selectable diagonal isometric views. Rotation changes yaw in 90° steps while preserving the authored elevation, distance, tilt and zoom. The player moves across the floor in any direction and can jump vertically. Each room is framed to show the entire puzzle.

## 2. Target Audience & Platform

- **Audience:** Fans of dark slapstick, puzzle-platformers, and morbid comedy, including players drawn to Portal, Super Meat Boy, The Binding of Isaac, and Happy Tree Friends.
- **Platforms:** Windows and macOS, with keyboard and controller support for the complete game flow.
- **Distribution:** Free release on Itch.io for feedback and a portfolio showcase.
- **Session structure:** A linear sequence of six authored rooms, ending with a completion screen and an option to replay.

## 3. Core Gameplay Loop

1. **Assess the room:** Identify the exit, hazards, pressure plates, and potential uses for bodies from the selected camera view.
2. **Sacrifice for science:** Intentionally enter a lethal hazard to leave a persistent corpse at the death location.
3. **Return as a fresh clone:** Respawn at the room's entrance hatch while existing corpses and puzzle state persist.
4. **Arrange the remains:** Carry and place bodies to create a traversable surface, provide weight, or stop a buzzsaw.
5. **Manage the five-body limit:** Plan around the oldest corpse disappearing when another body is created.
6. **Reach the exit:** Traverse the resulting route and enter the open exit door to advance.

Deaths allow unlimited retries. Death counts and subject numbers provide humor rather than a failure condition. Corpses are created through hazard deaths; a separate body-generation button is outside the slice.

## 4. Movement, Camera & Corpse Rules

### Movement and camera

- Controls are dependable and responsive. Exaggerated animation, death effects, and sound provide the physical comedy.
- Keyboard and controller movement follow screen directions under the selected camera angle.
- Include a forgiving manual jump, broad landing surfaces, and a clear ground shadow to communicate height and landing position.
- Avoid precision jumping and timed jump sequences in the slice.
- The camera remains stationary between four selectable South-east/South-west/North-west/North-east isometric views. Start at the authored South-east view; cycling rotates immediately to an adjacent corner. Frame the entire playable puzzle and use open or cutaway foreground walls so geometry does not hide the player, hazards, or important bodies.

### Death and corpse persistence

- Each death creates exactly one corpse and one replacement player, including when multiple hazards contact the player at once.
- Respawn follows brief death feedback and restores control promptly at a safe entrance hatch, without a game-over screen.
- Each corpse is a single solid physical prop with a stable collision shape. Visual animation may squash, stretch, or flop independently of that shape.
- Corpses interact with the floor, other corpses, the player, pressure plates, and designated hazard contacts. They can support the player and each other.
- Hazards do not destroy existing corpses. Bodies persist until replaced by the body limit or cleared when restarting or leaving the room.

### Carrying and assisted placement

- The player can pick up a nearby corpse and carry one body at a time.
- A carried body still counts toward the five-body limit, but does not support the player, press plates, or jam hazards while held.
- Picking up a corpse does not change its position in the creation queue.
- Show a nearby placement preview that clearly distinguishes valid and invalid positions.
- On release, align the body into a stable pose at the preview position, then resume its physical interaction with the room.
- Allow placement on valid surfaces, including other corpses and spike beds, without a grid. Bodies must be able to form bridges or stacks over spike pits.
- Reject placement inside the player, walls, other bodies, or beyond the player's nearby reach. An invalid placement attempt leaves the body held.
- Dying while carrying releases the existing body and creates the new corpse; both remain subject to the body limit.
- Carrying supports controlled placement. Aimed throwing and simulated dragging are outside the slice.

### Five-body limit

- At most five corpses may exist in a room, including a carried body.
- Creating a sixth removes the oldest corpse in creation order, with a non-colliding burst of confetti or neon gore.
- Show the current body count and clearly identify the corpse that will disappear next.
- Removing or picking up a body immediately updates any plate or buzzsaw it affects. Removing a supporting body allows the remaining stack to settle physically.
- If the oldest corpse is being carried when it is removed, clear the carrying state as part of its removal.
- Treat the limit as a visible puzzle rule. Every room's intended solution must work within it.

## 5. Hazards & Puzzle Interactions

| Element | Player interaction | Corpse interaction |
| --- | --- | --- |
| Spike pit | Exposed contact is lethal; the player can cross on a sufficient body bridge or stack. | Bodies remain intact and provide physical support. |
| Buzzsaw | Contact is lethal while active; a jammed saw permits traversal through its designated route. | A released corpse contacting the jam point stops the saw until that body is picked up or removed. |
| Falling anvil | A clearly telegraphed, repeatable drop kills a player caught beneath it. | Existing bodies remain intact after impact. |
| Pressure plate | The live player contributes one unit of weight while standing on it. | Each released corpse resting on the plate contributes one unit of weight. |
| Exit door | The player can pass through while its linked plate requirement is satisfied. | Bodies can hold the linked plate open; they do not complete the room themselves. |

- Support plates requiring either one unit or multiple units of weight, with their requirement and activation state clearly visible.
- A plate-controlled door opens while its weight requirement is satisfied and closes when it is no longer satisfied.
- Saw jams persist without a timer. Make active and jammed states visibly distinct, including when the oldest body's removal reactivates a saw.
- Introduce each hazard and body interaction before combining them into a harder puzzle.

## 6. Room Progression, Recovery & Saving

### Six-room sequence

1. **Sacrifice and traversal:** Teach dying, respawning, and using corpses to cross spikes.
2. **Carry and weigh:** Teach picking up bodies, assisted placement, and pressure plates.
3. **Jam the machinery:** Teach persistent buzzsaw jams and the consequences of retrieving a jammed body.
4. **Combine and replace:** Introduce falling anvils and demonstrate how creating another corpse removes the oldest when the cap is reached.
5. **Plan the route:** Combine established hazards and weight requirements with deliberate body allocation.
6. **Final experiment:** Combine previously taught mechanics into a final puzzle, followed by the completion screen.

Each room must have a repeatable intended solution within the five-body limit. Room layouts should make hazards block meaningful routes across the 3D floor and prevent simply walking around the intended obstacle. Reliable alternative solutions are welcome.

### Recovery and saved progress

- Provide a clearly accessible room restart on keyboard and controller.
- Restart restores the initial player position, hazards, switches, and doors, and clears all corpses, carrying state, and the creation queue.
- Restart is available for recovering from failed arrangements or blocked routes.
- Save the current room and player settings locally. Reopening the game resumes that room in its original state, with no saved corpse arrangement.
- Advancing to the next room begins a fresh puzzle with an empty body queue.

## 7. Visual, Animation & Audio Direction

**Art direction:** Stylised gothic miniature testing chambers with high-contrast silhouettes, ink-and-wash-inspired surfaces, and cartoonish neon blood splatters in hot pink or glowing green. Prioritise readable geometry and hazard states from the selected camera distance.

**Lighting:** Simple lighting and clear ground shadows that support depth perception and landing judgment. Avoid elaborate lighting systems in the slice.

**Character assets:** Prioritise reuse of the existing Blender characters from `/home/mark/projects/streets-of-rock/assets/characters`. Available candidates are cow, crow, lion, and plates, with Blender sources, rigged Blender files, and runtime GLB exports in their subdirectories. Select one character for the slice after checking its visual fit and readability at the intended camera distance; clones reuse that character.

**Confirmed asset metadata:** All four existing GLB exports contain a skin and animation clips named `Idle`, `Move`, `Hurt`, and `KnockedOut`. Metadata inspection confirms these resources exist, but visual quality, animation suitability, materials, scale, and in-game performance still require validation. Jump and carry animations need to be assessed or added.

**Asset workflow:** Retain Blender source models and use exported glTF/GLB assets in Godot. Bring the selected runtime assets into this project. Validate one representative character in the first greybox room. Reuse its mesh in a collapsed pose for corpse visuals where practical, with a separate simple physics shape. Identify any missing movement, jump, carry, and death animation work during the asset check.

**Animation and effects:** Exaggerated stretching, spinning, squashing, neon splatters, and pop-in death captions such as "Subject #402: Flattened". These effects must preserve the readability of the puzzle and the underlying solid corpse behavior.

**Audio:** Incongruously cheerful elevator jazz or 1950s-style muzak, contrasted with cartoonish trap sounds, slide whistles, squelchy thuds, wet splats, and occasional canned applause. Include settings for music and sound-effect volume.

## 8. Technical Scope & Milestones

### Implementation direction

- Use `CharacterBody3D` for the live player and `RigidBody3D` for each solid corpse prop.
- Use conservative collision shapes and assisted placement to support predictable stacks.
- Keep visual character rigs separate from corpse collision behavior; jointed physical ragdolls are outside the slice.
- Choose exact movement values, physics tuning, asset budgets, and level geometry during feature specification and technical planning, guided by the greybox proof.

### Milestones

1. **Prove the 3D interactions:** Build one greybox room with a corpse bridge, pressure plate, and jammable saw. Validate screen-relative movement, jumping, death and respawn, carrying, placement previews, stack stability, and oldest-body removal. Assess one existing Blender character at the actual camera angle and distance.
2. **Complete the puzzle systems:** Add falling anvils, readable hazard feedback, complete room restart, saved room progression, settings, and keyboard/controller coverage.
3. **Build the six-room sequence:** Implement the teaching progression and establish a repeatable intended solution for each room within the cap.
4. **Polish and playtest:** Add final presentation, contextual onboarding, death captions, audio, menus, and completion flow. Validate Windows and macOS builds and use playtest findings to refine puzzles and pacing.

### Outside the slice

Jointed ragdolls, aimed throwing, simulated dragging, hanging ropes, crates, projectile shielding, turrets, additional hazard types, free camera orbit, multi-character swapping, inventory systems, complex enemy AI, branching storylines, and elaborate lighting systems.

## 9. Acceptance & Playtest Criteria

The slice is ready for release when:

- All six rooms can be completed from a fresh start using either keyboard or controller, including menus, restart, and completion flow.
- Intended body bridges and stacks can be repeatedly built and traversed without unintended collapse or dependence on lucky physics bounces.
- Players can judge landing positions, valid body placements, and hazard states from the selected camera.
- Every death creates only one corpse and replacement player, and the room never retains more than five corpses.
- The displayed oldest body matches the body removed next, including when it is supporting a stack, pressing a plate, jamming a saw, or being carried.
- Invalid placement, death while carrying, overlapping hazard contacts, and rapid repeated deaths preserve correct carrying and queue state.
- Picking up or removing a body updates the affected plate, door, or saw consistently.
- Restart fully restores a room, and reopening the game resumes the saved room with its original layout and no corpses.
- Reused character assets render and animate correctly in the game and remain readable with the player and five corpses present.
- Windows and macOS builds complete the full game flow successfully.

Treat 20–30 minutes as a first-time completion target to validate through playtesting. Record completion time, requests for help, misunderstood rules, difficulty judging jumps, and frustration with body placement. Use these findings to revise the slice before release.
