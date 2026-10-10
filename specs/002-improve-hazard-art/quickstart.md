# Quickstart and Validation: Artwork Upgrade

**Date:** 2026-10-09 | **Plan:** [plan.md](plan.md)

This is the implementation validation guide. The Phase 3 hazard wrappers and art-validation scene are implemented.
T022 human keyboard/controller acceptance remains unverified. Existing baseline commands work now; commands
marked post-implementation require the named scene/checks to have been delivered.

## 1. Prerequisites and source preparation

Use Godot `4.7.2.stable.official.ed1daf0bf`, matching export templates, Python 3.12 and,
for source conversion only, Blender 5.2.2 LTS. Interactive review needs a display and a
physical controller; native Windows/macOS checks need those platforms.

Obtain the exact free sources/identities in [research.md](research.md). Preserve supplied
licences and originals, disable automatic execution when opening third-party authoring
files, and export only the curated runtime subset. The dependency/provenance conditions
are [C6](contracts/presentation.md#c6-asset-adoption-and-delivery). Do not depend on research
files remaining in `/tmp`; record adopted assets in the project manifest during implementation.

Run from the repository root:

```sh
cd /home/mark/projects/over-my-dead-body
/usr/local/bin/godot --version
OMDB_ART_CHECK_ROOT="$(mktemp -d /tmp/omdb-art-checks.XXXXXX)"
python3 scripts/checks/run_checks.py --godot /usr/local/bin/godot --suite all --save-root "$OMDB_ART_CHECK_ROOT"
```

The existing wrapper imports and validates resources, then runs state/physics/recovery
suites. Expected: nonempty passing summaries, zero failed checks and no engine/script/import
errors. Exit zero alone is insufficient. Record actual results under this feature rather
than copying the old feature's totals. For targeted work use `--suite physics`, `state` or
`recovery`; run all suites once integrated. New visual checks must be registered in the
existing runner/import checks during implementation. Missing checks are UNVERIFIED.

## 2. Representative playable artwork (post-implementation)

```sh
OMDB_ART_PLAY_ROOT="$(mktemp -d /tmp/omdb-art-play.XXXXXX)"
/usr/local/bin/godot --path . --resolution 1280x720 --scene res://tests/scenes/art_validation.tscn -- --save-root "$OMDB_ART_PLAY_ROOT"
```

Expected: a test chamber using actual production hazard/room/cow components, all three
hazards, a plate/exit, safe spawn and routes for body support/carrying. It is not a seventh
progression room. Isolated saves prevent disturbing normal play progress. Until this fixture
exists, the current baseline is `res://tests/scenes/greybox_validation.tscn`; baseline results
do not validate the future artwork.

Fixture tools: B switches baseline/candidate and restarts fresh; N hides trap names;
M mutes/unmutes audio; P pauses/resumes gameplay. Buttons provide the same controls.
These tools exist only in the development fixture.

Keyboard: WASD/arrows, Space jump, E pickup/place, R restart, Escape pause, Q/C cycle views,
1–4 select South-east/South-west/North-west/North-east. Controller: stick movement, South
jump, West pickup/place, North restart, Menu pause, LB/RB views.

Perform ten fresh repetitions of each applicable physical case with keyboard and controller:

1. Die on exposed spikes, build/traverse the intended support route and inspect exposed
   versus body-covered danger. Rebuild a stack, remove support and observe settling.
2. Pick up/place on floor, corpse and spike bed; reject overlap, blocked and out-of-reach
   placements while holding the body. Verify preview/support agreement under new materials.
3. Jam the wheel, traverse its route, retrieve the body and observe reactivation. Repeat
   with two contributors and removing only one. Check active/jammed states with sound muted.
4. Watch warning/drop/return, stand outside and inside the anvil footprint, and verify
   impact pose/death timing. Existing bodies remain intact; pause/restart in each phase.
5. Create a sixth body with oldest held, supporting a stack, pressing a plate and jamming
   a saw. Verify marker, removal, count and immediate dependent state. Include carrying
   death, rapid deaths and overlapping hazard contacts.
6. With one player and five corpses, inspect cow movement/jump/carry/death/collapsed poses,
   shadows, yellow airborne surface ring, valid/invalid preview, plate text and exit state.
   Turn through all four views during each representative arrangement.

Pass criteria are [spec VR-002/003](spec.md), [presentation contract](contracts/presentation.md)
and zero unexplained physical/state failures. Record remaining character animation gaps.

## 3. Recognition and atmosphere gate

Recruit five reviewers unfamiliar with this artwork. At 1280×720, hide trap-name labels
for recognition only, show each of three traps from each of four views, and record all
60 observations. At least 54 must be correct, including at least 18/20 per trap.

Restore ordinary gameplay cues. With sound muted, each reviewer must distinguish active
and jammed saws and identify anvil danger before impact in every view. Record safe-route
misinterpretations; none may remain for acceptance. After a five-minute playable session,
at least four reviewers must describe a gothic/macabre testing setting and rate visual
coherence at least 4/5. Record descriptions, help requests, jump judgment and placement
frustration rather than only a pass mark.

Stage B requires these outcomes plus representative physical/character checks and measured
asset budgets before applying the treatment to all six rooms. Unavailable reviewers or
input hardware leave that gate unverified, not automatically passed.

## 4. Six-room and recovery review (after rollout)

```sh
OMDB_ART_ROOMS_ROOT="$(mktemp -d /tmp/omdb-art-rooms.XXXXXX)"
/usr/local/bin/godot --path . --resolution 1280x720 --scene res://tests/scenes/authored_room_validation.tscn -- --save-root "$OMDB_ART_ROOMS_ROOT"
```

Follow existing [room solutions](../001-six-room-slice/room-solutions.md), preserving
creation order and no more than five simultaneous bodies. Ten fresh solutions per room
must pass regression checks with the art present. Repeat rendered inspection at 1920×1200
and 1024×768 by changing `--resolution`; inspect each of four views in each of six rooms
at all three windows (72 combinations), in fresh and representative five-body states.

Required outcome: whole puzzle visible, no decoration/effect obstruction, exact danger
interpretation, nested cutaways correct, open exit visible and floor/support truthful.
Record viewport/window/stretch settings so a letterboxed picture is not confused with a
full-window rendering measurement.

For full menu/completion/replay/recovery flow:

```sh
/usr/local/bin/godot --path . -- --save-root "$OMDB_ART_ROOMS_ROOT"
```

Restart during jam/warning/drop/death/holding; advance during effects; quit and reopen the
same root. Expected: original room layout and fresh puzzle, no bodies/held state/stale
presentation, saved room and volumes retained. Complete room 6 and replay to room 1.
Check all menus and music/SFX mute independently with each input method.

## 5. Performance and native packages

Capture release builds at 1920×1080 on the plan's target hardware. Warm up 30 s, then
capture 120 s with one player/five corpses and hazards/effects active, in the representative
and densest dressed rooms. Run the same scenario before/after dressing. Record CPU/GPU/RAM,
OS/driver, renderer, build identity, window/viewport, pacing/VSync configuration, p95 frame
and physics time, visible triangles, draw calls and lights. Expected: plan budgets and
60 FPS / 16.7 ms frame p95 / 4 ms physics p95. Headless runs do not establish these results.

Use the existing production export path after integration:

```sh
python3 scripts/checks/download_export_templates.py --output /tmp/omdb-export-templates/4.7.2.stable
python3 scripts/checks/export_fixture.py --godot /usr/local/bin/godot --template-dir /tmp/omdb-export-templates/4.7.2.stable --production
python3 scripts/checks/check_package.py
```

Expected: six-room production packages, matching runtime assets/textures/licences/credits,
no source art or test scenes. Inspect both compiled packages, then perform full native
Windows-keyboard, Windows-controller, macOS-keyboard and macOS-controller runs with fresh
OS-temporary save roots. Package smoke checks on Linux do not pass the native matrix.
Full-slice playtests also record duration against 20–30 minutes and the existing help/
misunderstanding/jump/placement measures. Publishing is outside this guide.

## 6. Evidence record

Create this feature's `validation.md` during implementation. Each row includes requirement
and contract IDs, build/asset identity, setup, actions, expected result, actual result,
repeats, device/view/window/platform, status, capture/log and outstanding defects.
Use the [ValidationCase model](data-model.md#validationcase-and-observation). Preserve failed
results and link their fixes/retests. Unrun checks are UNVERIFIED. Planning inspected source
files and one temporary resource load only; none of the new playable/native checks is passed.
