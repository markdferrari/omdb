# Original music and cartoon cues

All sources were generated in this repository on 2026-10-08 by
`scripts/checks/generate_audio.py`, using Python's standard library. They contain no
external recordings, samples, or quoted melodies. No third-party attribution is required;
keep the generator with the assets for provenance and reproducibility. Project distribution
may include these original assets. No external source licence is being claimed.

Run `python3 scripts/checks/generate_audio.py` to reproduce the selected sources.
Mono PCM16 at 22,050 Hz; each file is normalized to a peak amplitude of 0.75.

| Source | Content / event | Bus |
| --- | --- | --- |
| `music/cheerful_loop.wav` | Original 8-bar, 132 BPM swing tune with harmonic melody, offbeat chords, and alternating bass; 14.545 s loop | Music |
| `sfx/spike_hit.wav` | Descending spring tone on committed spike death; 0.38 s | SFX |
| `sfx/saw_hit.wav` | Cartoon rasp on committed saw death; 0.32 s | SFX |
| `sfx/saw_jam.wav` | Descending motor squeak when a saw first becomes jammed; 0.50 s | SFX |
| `sfx/anvil_warning.wav` | Two bright bell tones at the start of each warning cycle; 0.50 s | SFX |
| `sfx/anvil_drop.wav` | Short metallic clang once per impact, including a lethal impact; 0.65 s | SFX |
| `sfx/body_pop.wav` | Rising bubble pop on corpse eviction, also used by the settings preview; 0.22 s | SFX |

`resources/audio_cues.tres` selects the streams. Four SFX voices allow overlapping cues
without unbounded audio nodes; a fifth voice owns looping music. Independent bus volume
and mute settings apply to every voice. A retired room emits no new cues. Visual hazard
labels, motion, target markers, captions, and effect colors remain independent of sound.

WAV replaces the initially planned Ogg paths: Godot imports PCM directly, and no external
encoder is available or needed. The music source is approximately 0.64 MB and all six
short effects total approximately 0.11 MB before import/package compression. Speaker,
headphone, loop-seam, balance, and musical-style acceptance remain unverified under T091;
resource loading and event tests do not establish audibility or artistic acceptance.

The earlier `preview_music.wav` and `preview_sfx.wav` remain historical settings fixtures:
a two-second sine melody and 0.16-second descending tone. Runtime now uses the selected
streams above. They were also generated with the Python standard library without samples.
