# Connected six-room playtest candidate — 2026-10-09

This candidate launches `res://scenes/main.tscn` with the exact six authored definitions.
It is ready for continued playable review; native platform, physical-controller, rendered,
first-time playtest and performance acceptance remain **UNVERIFIED**. No release or
publication has been performed.

Engine: **4.7.2.stable.official.ed1daf0bf**. Standard official export templates: **4.7.2.stable**, retained
outside the repository at `/tmp/omdb-export-templates/4.7.2.stable`. Compatibility renderer,
built-in Jolt, Windows x86_64 PE and macOS Universal 2 (x86_64 + arm64). macOS is unsigned
and unnotarized. Changes remain in the working tree; this is not a committed build tag.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| builds/windows/over-my-dead-body.exe | 109,127,680 | `4a9eaded8955ef789ab02651ed9d2dde80328fbb342bd2a6db4db33e86305668` |
| builds/macos/over-my-dead-body.zip | 60,053,556 | `8a0ad6818337ab64fafe2d10bd5d3df7166c6ba2e78533ae35e0c87a4f489312` |
| builds/windows/over-my-dead-body.zip | 38,419,380 | `60da6ae92c87264d71d9ac7932983dae07fc0a7d29be4ec282f3610a07eda52c` |
| builds/windows/over-my-dead-body.pck | 530,108 | `68d4a8502e8cee297ed17840a6bac6641595bcf625cf4b946aa6d4bdce9f5ca9` |

The Windows distribution ZIP includes both the EXE and required PCK. Keep those together.
The macOS ZIP includes the app bundle. Builds are ignored local outputs; exact generated
identities are also in `builds/game-manifest.json`. The EXE is the matching stock engine;
the separate PCK identifies the authored content.

Included: the production room catalogue/definitions, six room scenes/shared chamber and
partition geometry, player/corpse collision and reused cow runtime asset, HUD/onboarding,
four diagonal isometric views with preserved tilt and zoom, puzzle components, menus,
saving/settings, original audio and cosmetic
feedback. Excluded: all `tests/*`, `scripts/checks/*` and retained `art/*` sources.
Root floor/spike/passage authoring properties avoid the observed compiled-export loss of
nested shape overrides; packaged metadata checks confirm actual floor/spike dimensions.
The refreshed camera correction is recorded in CAM-02 in `validation.md`; export and
Linux PCK smoke logs are `/tmp/omdb-isometric-export.log` and
`/tmp/omdb-isometric-package.log`. Native acceptance remains unverified.

Reproduce from the project root:

```sh
python3 scripts/checks/export_fixture.py --production --template-dir /tmp/omdb-export-templates/4.7.2.stable
python3 scripts/checks/check_package.py
```

The Linux PCK smoke runs use empty source directories and temporary saves, checking Title,
settings/mute persistence, fresh Continue, all six actual definitions/geometries, Completion
and saved fresh Replay. Both packages pass in `/tmp/omdb-connected-candidate-package.log`;
this exercises the packaged resources with Linux Godot and does not run the native binaries.
State/physics/recovery and solution evidence are in [validation.md](validation.md) and
[room-solutions.md](room-solutions.md).

| Native acceptance | Result |
| --- | --- |
| Windows keyboard full sequence and recovery | UNVERIFIED |
| Windows physical controller full sequence and recovery | UNVERIFIED |
| macOS keyboard full sequence and recovery | UNVERIFIED |
| macOS physical controller full sequence and recovery | UNVERIFIED |
| macOS actual downloaded launch/signing behavior | UNVERIFIED |
| Selected Windows/macOS performance targets | UNVERIFIED |

Normal launches use local player saves. For isolated checks, pass an absolute child of the
OS temporary directory with `--save-root`; preserve that directory to check fresh resume.
T082/T083/T091/T095/T098–T105/T113 and remaining human gates stay open. Native checks must
identify these hashes; any subsequent content change requires refreshed affected evidence.
