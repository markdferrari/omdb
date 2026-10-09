# Contract: Player Controls and Feedback

**Version**: 1 | **Date**: 2026-10-08

## Input actions

Bindings below are the implementation baseline. Button labels use physical positions so
prompts can display the appropriate connected-controller glyph. No mouse is required.

| Action | Keyboard | Controller | Behavior |
| --- | --- | --- | --- |
| `move_left/right/up/down` | A/D/W/S and arrow keys | Left stick | Ground-plane motion relative to selected camera; normalize diagonals, preserve analog magnitude. |
| `jump` | Space | South face button | One buffered manual jump; no repeat from key echo. |
| `interact` | E | West face button | Empty hands: pick up nearest reachable body. Holding: attempt current preview placement. |
| `restart_room` | R | North face button | Immediately request a fresh active room, including during death feedback. Also available in pause menu. |
| `pause` | Escape | Start/Menu | Open/close pause menu; block gameplay actions while menus own input. |
| `camera_previous/next` | Q / C | Left / right shoulder (LB / RB) | Cycle diagonal isometric presets in 90° steps, preserving tilt, elevation, distance and zoom. |
| `camera_north/east/south/west` (legacy action IDs) | 1 / 2 / 3 / 4 | Use shoulder cycling | Select South-east/South-west/North-west/North-east directly; movement follows the selected view. |
| `ui_accept` | Enter or Space | South face button | Activate the focused menu control. |
| `ui_cancel` | Escape | East face button | Return from submenu, preserving focus; resume from pause. |
| `ui_left/right/up/down` | Arrow keys | D-pad or left stick | Move focus or adjust the focused slider; no simultaneous gameplay movement. |

Use `Input.get_vector` and the camera's projected right/forward ground axes, then normalize
the projected basis. Unit tests cover all four screen directions and diagonal speed.
The placement direction is the last nonzero movement direction, retained when standing.
The controller deadzone begins at 0.2 and is tuned through the required device trials.
There is no aimed throwing, dragging, free camera orbit, or body-generation action.

## Flow and focus

| Screen/state | Available operations | Initial / restored focus |
| --- | --- | --- |
| Title | Start/Continue current saved room, Settings, Quit | Start/Continue |
| Gameplay | Movement, jump, interact, restart, pause | Gameplay owns input |
| Pause | Resume, Restart Room, Settings, Quit to Title | Resume; preserve last control when returning from Settings |
| Settings | Music slider, SFX slider, Back | Music slider; expose value and mute state |
| Completion | Replay, Settings, Quit to Title | Replay |

Start/Continue opens the saved room fresh. Reopening after completion offers the saved
room 6; Replay explicitly starts and saves room 1. Quit to Title preserves the current
room and settings, and reentering starts that room fresh. Pausing freezes room simulation
and feedback countdowns but keeps UI responsive. Window-focus loss or controller
disconnection while that controller is active opens pause; reconnection restores usable
menu focus. Opening a menu consumes its input event so it cannot also activate a control.

Keyboard/controller focus must remain visible, and no pointer hover is required. Display
prompts for the last actively used input method; incidental stick noise below the deadzone
does not switch prompts. Controller names/glyphs must have a readable generic fallback.

## Readability and feedback

- HUD shows `Bodies: n/5` and highlights the actual oldest body; zero bodies means no
  oldest marker. A held oldest body must still be identifiable through the carry visual/HUD.
- The placement ghost uses a distinct outline/icon as well as colour for valid versus
  invalid state. An invalid action leaves the body held and briefly explains the reason.
- Plate displays show current/required weight and active state. Saw motion and a jam
  indicator distinguish states; anvil warning marks its future impact area before a drop.
- A ground shadow marks the live player's floor position during jumps. Camera and UI
  framing retain the entire puzzle and cues at 16:9, 16:10, and 4:3; letterbox when needed.
- First relevant interactions trigger brief contextual prompts, while retaining movement
  control. Death captions and neon effects cannot cover a required decision or delay respawn
  beyond the two-second active-play target.
- Music and SFX volumes range from 0 to 1, independently mute at zero, update audibly while
  changed, and persist when the user leaves settings. Defaults: music 0.7, SFX 0.9.
- A save failure is communicated briefly while allowing play to continue. It must not
  claim progress was saved. Critical hazard information remains visual even with both
  audio categories muted.

## Acceptance mapping

US1/AS1 and FR-002–FR-003 cover direction, framing and landings. US2 and FR-007–FR-011
cover interact/preview behavior. FR-014 and FR-022 cover body/hazard feedback. US4–US6
cover all menu, recovery, progress and settings operations; US7 covers presentation.
VR-006 exercises each platform/input combination, and VR-007/SC-008 establish whether
first-time players understand the cues. Passing headless input tests is not sufficient
for controller comfort or visual readability acceptance.
