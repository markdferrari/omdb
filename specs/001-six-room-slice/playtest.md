# First-time slice playtest protocol — T094

Status: prepared; no participant sessions conducted. This protocol applies to the authored
six-room slice after its greybox/character and solution gates pass. Representative fixtures
cannot establish SC-007 pacing or SC-008 first-time cue recognition. Do not count the
existing developer/user debugging sessions as first-time participants.

Recruit at least five people who have not seen the solutions. Record participant codes
rather than names, platform/hardware, input device, build/source/package hashes, date,
prior puzzle-platformer familiarity, and facilitator. Each participant starts with a new
isolated save root, original room state, and default volumes. Test one input method alone;
note any accessibility adjustments. Record the room camera's resolution/aspect ratio.

Use the same introduction: “Reach the exit in each room. You can move, jump, interact,
restart, pause, and adjust audio using the controls shown in the game. Think aloud if you
are comfortable. Tell me when something is unclear.” Do not describe corpse solutions,
plate allocations, FIFO behavior, or bypasses. Let in-game onboarding introduce those rules.

## Timing and intervention

Start the active timer when room 1 first grants control. Stop when the final completion
screen appears. Include all active gameplay, deaths, replacement feedback, failed attempts,
and room restarts. Exclude menus/settings, participant breaks, hardware interruptions,
and facilitator questions by recording pause/resume timestamps and reasons. Record wall
time separately so exclusions remain auditable. Do not remove stuck time from active time.

Record every help request before responding, with time/room, verbatim confusion, current
body order/held identity, and relevant puzzle state. Start with “What could the on-screen
cues tell you?” If further help is required, record the exact hint, timing, and whether
it reveals a rule or solution. Preserve assisted outcomes rather than treating them as
unassisted success. Record any facilitator intervention not requested by the participant.

Allow up to 45 minutes of active play unless the participant stops earlier. Mark a timeout,
withdrawal, crash, or inaccessible control as non-completion, with last room, active time,
and reason. A non-completer has no fabricated completion time. Report completion count,
all completed-session times, and median of completed sessions alongside assistance and
non-completion rates; five completed first-time sessions are required to establish the
intended duration rather than relying on a selective median.

## Observation and cue recognition

Record room-entry/exit times, first successful sacrifice, pickup/place attempts and rejection
messages, jump misjudgments, restarts, creation-order misunderstandings, frustration,
repeated failed approaches, and unexpected alternative solutions. For every defect record
setup, expected behavior, actual outcome, severity, reproducibility, build, and evidence.
Do not ask leading questions during a failure; observe the participant's interpretation.

At the first natural introduction of each cue, pause active timing and ask the corresponding
neutral question below using the normal camera. Do not explain the answer beforehand.
Record the first response verbatim and a correct/incorrect/unobserved result. A prompted
second answer does not replace the first. Keep audio muted for one hazard-cue recheck,
recording the recheck separately from first recognition.

| Cue | Question | Scoring criterion |
| --- | --- | --- |
| Exit | Where are you trying to go in this room? | Correct exit indicated |
| Landing | Where will you land if you jump from here? | Correct broad landing position/depth indicated |
| Placement | What does the current body preview tell you? | Correct valid/blocked state and interaction outcome |
| Oldest body | Which body will disappear if another one is created, and why? | Actual oldest identity and creation-order rule |
| Plate requirement | What do these numbers mean, and what would change them? | Current/required direct units; player/released body contributions |
| Plate activation | What will happen to the linked door in this state? | Correct open/closed threshold prediction |
| Saw | Is this route safe now, and what would change that? | Correct active/jammed state and persistence until contributor removal |
| Anvil | What is about to happen, and where? | Warning, future impact area, and safe avoidance recognized |

A participant meets SC-008 only when all applicable first responses are correct. Require
at least four of the initial five participants to meet that criterion (80%). Also report
each cue's recognition rate to locate defects. An unobserved cue is missing evidence,
not a correct answer; repeat with a fresh participant if session coverage is insufficient.

## Session and defect records

| Session | Input/platform/build | Completion / active time | Help / restarts | All eight cues correct? | Notes/evidence |
| --- | --- | --- | --- | --- | --- |
| P01 | UNRUN | UNRUN | UNRUN | UNRUN | |
| P02 | UNRUN | UNRUN | UNRUN | UNRUN | |
| P03 | UNRUN | UNRUN | UNRUN | UNRUN | |
| P04 | UNRUN | UNRUN | UNRUN | UNRUN | |
| P05 | UNRUN | UNRUN | UNRUN | UNRUN | |

For each session append timestamped observations, timing exclusions, cue responses,
help text, peak body counts, room timings, and a defect list. Link actual recordings/logs
where available, with the participant's permission. Summarize findings in `validation.md`.

After five sessions, report actual completion count, median active completion time,
assistance, non-completions, and recognition results. If the median is outside 20–30 minutes,
record the pacing review and concrete room/onboarding changes. Resolve findings under T096,
rerun affected physics/state/solution checks, then conduct new first-time follow-ups on the
corrected build. Record new hashes and separate the original and follow-up cohorts. Do not
claim targets achieved until actual observations support them.
