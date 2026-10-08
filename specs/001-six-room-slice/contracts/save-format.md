# Contract: Local Progress and Settings

**Version**: 1 | **Date**: 2026-10-08

Use separate ConfigFile documents under the game's `user://` directory. SaveStore receives
its storage root at construction; validation can substitute a temporary absolute path
before any file access. Production never uses test data by default.

## Progress document: `progress.cfg`

```ini
[meta]
schema_version=1

[progress]
current_room="room_01"
```

`current_room` must be one of `room_01`, `room_02`, `room_03`, `room_04`, `room_05`,
`room_06`. These IDs resolve through the authored catalogue, not arbitrary file paths.
There are no body transforms, creation indices, contact sets, subject states, hazard
phases, or completion flag in the document.

## Settings document: `settings.cfg`

```ini
[meta]
schema_version=1

[audio]
music_volume=0.7
sfx_volume=0.9
```

Values are finite numbers clamped into 0–1; reject booleans, strings, NaN and infinity.
Missing or invalid fields take their individual default. Zero means mute for that bus;
the other category is unaffected. No account, cloud identifier, or controller pairing
is stored.

## Reads and writes

| Event | Required behavior |
| --- | --- |
| First launch / missing progress | Use room 1; load any independently valid settings. |
| Unreadable progress, unknown schema, invalid room | Use room 1; do not attempt to load an arbitrary scene or discard independently valid settings. |
| Unreadable/unsupported settings document | Use default audio settings; valid progress remains usable. |
| Missing/invalid one audio field | Default only that field; use the other valid field. |
| Successful room activation | Save the newly active room after initialization succeeds, before resuming normal play. |
| Ordinary death or room restart | Preserve current room ID and settings; never save the body arrangement. |
| Completion | Keep room 6 current. |
| Replay | Start room 1 fresh and save room 1 after activation; preserve audio settings. |
| Leaving settings / quitting | Persist changed audio values; flush any pending valid progress change. |

For each document, save to a sibling temporary file, check the result, and perform a
checked rename to replace the destination. Do not delete the existing valid destination
first. On write/rename failure, retain it and report failure to the caller; cleanup may
remove only the temporary file owned by that operation. This is not a guarantee against
all power-loss or filesystem failures. Reads do not overwrite malformed files merely
because loading failed; a later valid user-driven progress/settings update can replace
them through the normal write path.

Progress and settings are independent commits; failure of one must not falsely report
the other as failed or destroy its previous value. Unknown extra fields in schema 1 are
ignored; unknown schema versions use the documented fallback rather than an invented
migration. Bump this contract's schema when interpretation changes incompatibly.

## Verification

Recovery tests create isolated roots for missing, malformed, unsupported-version,
out-of-range-room, partial-settings, and write-failure cases. Reopening every valid room
must produce its original scene with one live player, no corpses, no carry state, and
initial machinery. A failed save must leave the previous valid file loadable. Tests must
also prove that no access falls back to the production root after a test root was supplied.
These checks implement FR-026–FR-030, FR-033, EC-09–EC-13, VR-005, and SC-010.
