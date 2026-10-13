# kaykit_spike_cluster

Creator: Kay Lousberg

Source: https://kaylousberg.itch.io/kaykit-dungeon-pack

Archive SHA-256: `6acb859d1aefae074f937d1e6f13656a7312b2bdb6d9f1232ebdade8d93d6a1c`

Edition: Free 1.1; zero-cost runtime source, CC0. No paid Blender source claimed.

Originals: `art/environment/kaykit_dungeon`. Normalized editable adaptation retained under `art/hazards/`.

Trial asset; playable recognition remains unverified. Runtime materials replace vendor texture references. See manifest for exact members, export hashes and metrics.

## Decoration trial — 2026-10-10

Original Free 1.1 glTF models: floor_tile_large, floor_tile_big_grate, wall, wall_arched, wall_cracked, wall_pillar, shelf_small_candles, bottle_A_labeled_brown, torch_mounted and banner_white. Exact original members, buffers/atlas hashes and measured Godot inventory are recorded per model in manifest.json. Sources remain under art/environment/kaykit_dungeon.

Wrappers fit existing support and room dimensions; stone/ink material overrides harmonize architecture. Shelves, candles, bottles, mounted torches and banners are non-interactive decoration in fixed wall clusters. No random gameplay spawn, vendor logic or additional lights. Custom low boundary trim fills the readability gap when foreground walls cut away; source modules do not supply persistent cutaway markers.

## Colourful dungeon trial — 2026-10-10

Additional original members: wall_doorway, wall_gated, torch_lit, candle_lit, rubble_half,
sword_shield and banner_patternA_red, with their .bin buffers and shared atlas. All are in
the supplied CC0 Free 1.1 archive; original files remain unchanged and retained under art/.
The chamber now uses original atlas materials. Lit meshes duplicate their materials for
restrained warm emission and add no Light3D nodes. Sparse rubble is cosmetic wall garnish.

The doorway wrapper removes the separate wooden-door mesh and compresses the broad
stone wings/tall header around the retained opening. The initial unadapted doorway screened
nearby traps in rendered review; compressed geometry corrects this reuse-fit defect.
The closed iron gate derives from wall_gated; it hides only when the owner opens the exit.
Custom plate cue strips and sign plaque fill the kit's missing weight-state outline and
engraved tutorial backing. Existing gameplay labels stay authoritative. No new mechanics.
