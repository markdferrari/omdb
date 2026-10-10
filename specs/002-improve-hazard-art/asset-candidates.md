# Initial Free Asset Candidates

Planning follow-up: [research.md](research.md) records the completed comparison, additional
free anvil/saw sources and selections for the representative trial. It supersedes unresolved
sourcing questions below; playable acceptance remains pending.

Checked 2026-10-09 from publisher pages and the Godot Asset Library. This is a planning
shortlist, not asset selection or playable acceptance. Two free KayKit archives appeared
in the workspace during specification and were inspected in place; no pack was downloaded
by this specification, extracted into the project, or integrated with the game.

| Candidate | Confirmed public information | Possible use and unresolved checks |
| --- | --- | --- |
| [KayKit Dungeon Pack](https://kaylousberg.itch.io/kaykit-dungeon-pack) / [Godot Asset Library package](https://godotengine.org/asset-library/asset/2126) | Publisher advertises a CC0 free edition and FBX/glTF/OBJ. The supplied Free 1.1 archive contains 211 glTF files, including `floor_tile_big_spikes.gltf`, and CC0 licence text. Godot library entry is older Dungeon Remastered 1.0 for Godot 4.1. | First environment/spike candidate. Anvil/toothed-saw coverage is unconfirmed. Test the spike silhouette, adaptation to authored beds, cutaways, cow palette and current camera. Do not assume the older Godot package contains newer assets. |
| [Kenney Modular Dungeon Kit](https://kenney.nl/assets/modular-dungeon-kit) | Publisher lists a free CC0 3D modular kit, 40 files, with a 2.1 update. | Alternative chamber kit. Inspect archive formats, gothic silhouettes, materials, cutaway suitability and actual hazard coverage. |
| [Kenney Graveyard Kit](https://kenney.nl/assets/graveyard-kit) | Publisher lists 90 files, 3D assets and CC0. | Supplemental gothic dressing; inventory pieces before deciding fit. A graveyard theme alone establishes neither testing-facility suitability nor hazard coverage. |
| [Quaternius Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html) | Publisher lists CC0, glTF/FBX/OBJ and a free tier containing part of the full collection. Godot scenes, editable Blender sources and additional features are advertised for Source. | Supplemental metal/workshop props. Verify whether a usable anvil is in the free download; coverage is unconfirmed. Evaluate runtime files separately from paid source/engine packages. |

[KayKit Platformer Pack](https://kaylousberg.itch.io/kaykit-platformer) places spike traps
and sawblades in the paid EXTRA tier. These do not qualify as confirmed free coverage.
Free platform/background pieces may still be compared if their fit warrants it; avoid
making paid traps a dependency.

## Local archive inspection

- `KayKit_Dungeon_Pack_1.1_FREE.zip`, SHA-256
  `6acb859d1aefae074f937d1e6f13656a7312b2bdb6d9f1232ebdade8d93d6a1c`:
  211 glTF files; spike asset has separate `spikes` and `floor_tile_big_spikes` nodes/meshes,
  with references to `floor_tile_big_spikes.bin` and `dungeon_texture.png`. Floor/wall/door
  files are present. Filename searches found no named anvil or saw asset.
- `KayKit_Platformer_Pack_1.0_FREE.zip`, SHA-256
  `7e140ee01abf99a5896cf93a02ff3dc6a23a7222109fd04854821f44a3a3adeb`:
  370 glTF files; filename searches found no named spike, saw, anvil or trap asset.
- Both archives contain `License.txt` naming Kay Lousberg and CC0, allowing personal,
  educational and commercial projects and describing credit as optional. Retain the actual
  licence alongside any adopted files. Download origin/date were not observed; record them
  when available rather than inferring provenance solely from filenames.
- These are archive/metadata observations only. They establish available candidate files,
  not successful import, silhouette quality, performance or compatibility with gameplay.

Follow FR-014–FR-018 and VR-001 in [the spec](spec.md): compare at least three plausible
packs, inspect needed free files, test representative assets in the playable chamber,
then document selection/rejection. Record author, URL, download date, archive/version
identity, file identity, supplied licence, credits and modifications for each selected
piece. Preserve available editable sources; record when only runtime models are free.
