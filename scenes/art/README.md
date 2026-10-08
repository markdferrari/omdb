# Reusable miniature room frame

`room_dressing.tscn` is original code-native decoration for a 16 × 12 m footprint:
a layered stone/ink plinth and four low gothic finials outside the playable area.
Engine inventory reports 248 triangles in 18 mesh instances. It uses shared matte
stone and ink materials, no lights, no
shadow-casting dressing, and no collision or gameplay nodes. It does not provide
physical walls, floors, landing surfaces, or support. Pair it with the room's
validated collision geometry; move/scale the frame for other authored footprints.

The dark plinth and post borders supply structural contrast while reserving the
neon palette for gameplay states/effects. It is prepared for T090 integration,
not applied to the validated greybox or unfinished six-room sequence. Check the
fixed camera at 16:9, 16:10 and 4:3 before acceptance: low foreground posts must not
cover an exit, landing, shadow, body, placement ghost, plate label, saw or anvil
warning. Adjust/remove any obstructing decorative instance. No rendered
readability or measured frame/draw-call acceptance is claimed.

Generated from Godot primitive meshes; no external imagery, samples or licences.
