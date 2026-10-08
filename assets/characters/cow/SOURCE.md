# Cow provenance

Copied on 2026-10-08; original source project is unchanged. Editable Blender sources
are excluded from runtime imports using `art/.gdignore`.

| Copy | Source | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `assets/characters/cow/cow.glb` | `/home/mark/projects/streets-of-rock/assets/characters/cow-crow/runtime/cow.glb` | 351196 | `9b8227157dc6439efebccf6867ddd1faef873af46f918685cf495af3509b8909` |
| `art/characters/cow/cow.blend` | `/home/mark/projects/streets-of-rock/assets/characters/cow-crow/cow.blend` | 130989 | `c1ab6e38f6e48fc38433f64b3f7d59d034a5cc0df4458d5720bb3ec931f1a3e3` |
| `art/characters/cow/cow-rigged.blend` | `/home/mark/projects/streets-of-rock/assets/characters/cow-crow/runtime/cow-rigged.blend` | 166007 | `93af979abb5163663a2a16899b58822f9da67546648d912f6d98820482abc968` |

Selected for the greybox provisionally. Named Idle, Move, Hurt, and KnockedOut clips
exist in the source metadata. Jump and carry have no dedicated named clip; adaptation
and actual-camera visual validation remain unverified. Source licensing is inherited
from the existing project; no new third-party asset was downloaded.

## Initial runtime presentation (T020)

The GLB is reused by the player and corpses. `character_visual.gd` resolves imported
clip names at runtime. Idle/Move/Hurt are mapped for the live player; airborne motion
provisionally stretches only its visual while using Idle. The corpse visual samples
KnockedOut and pauses, with an independent flat visual transform. Collision is one
rotation-locked 1.8 × 0.45 × 0.9 m box and never follows rig bones.

Dedicated jump/carry animation and the actual-camera corpse silhouette fit remain
UNVERIFIED. T031 now adds a provisional cosmetic carrying lean and a duplicate of the
collapsed cow visual under the directional CarryAnchor. The held world prop is hidden,
frozen, and noncolliding; its registry identity is unchanged. The actual-camera review
must assess this adapted pose and ghost/support silhouette before character acceptance. No visual acceptance is inferred
from successful import or clip names. Presentation metadata: `presentation.tres`.
