#!/usr/bin/env python3
"""Reproduce the slice's original sample-free PCM music and cartoon cues."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[2] / 'assets/audio'
RATE = 22050

def frequency(note):
    return 440 * 2 ** ((note - 69) / 12)

def tone(buffer, start, duration, note, gain, decay=5):
    hz = frequency(note)
    for index in range(int(duration * RATE)):
        target = int(start * RATE) + index
        if target >= len(buffer):
            break
        time = index / RATE
        envelope = min(1, time / .006) * math.exp(-decay * time) * min(1, (duration - time) / .03)
        value = math.sin(math.tau * hz * time) + .25 * math.sin(math.tau * hz * 2 * time) + .08 * math.sin(math.tau * hz * 3 * time)
        buffer[target] += gain * envelope * value

def write(relative, samples):
    path = ROOT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    peak = max(abs(value) for value in samples)
    scale = .75 / max(peak, .001)
    pcm = b''.join(struct.pack('<h', round(value * scale * 32767)) for value in samples)
    with wave.open(str(path), 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm)
    print(relative, len(samples) / RATE, 'seconds; normalized peak 0.75')

def music():
    beat = 60 / 132
    samples = [0.] * round(32 * beat * RATE)
    chords = [(48, 64, 67, 69), (45, 61, 64, 67), (50, 65, 69, 72), (43, 65, 69, 71), (41, 65, 69, 72), (41, 65, 68, 72), (48, 64, 67, 69), (43, 65, 69, 71)]
    melodies = [(76, 79, 81, 79, 76, 74, 72, 74), (73, 76, 79, 81, 79, 76, 73, 72), (74, 77, 81, 84, 81, 77, 76, 74), (71, 74, 77, 81, 79, 77, 74, 71), (72, 77, 79, 81, 84, 81, 79, 77), (72, 77, 80, 84, 83, 80, 77, 74), (76, 79, 84, 81, 79, 76, 74, 72), (71, 74, 77, 79, 81, 77, 74, 71)]
    for bar, chord in enumerate(chords):
        start = bar * 4 * beat
        for quarter in range(4):
            tone(samples, start + quarter * beat, beat * .9, chord[0] + (7 if quarter % 2 else 0), .25, 7)
            if quarter % 2:
                for note in chord[1:]:
                    tone(samples, start + quarter * beat, beat * .8, note, .12, 9)
        for eighth, note in enumerate(melodies[bar]):
            offset = (eighth // 2 + (2 / 3 if eighth % 2 else 0)) * beat
            tone(samples, start + offset, beat * .65, note, .17, 8)
    write('music/cheerful_loop.wav', samples)

def effects():
    durations = {'spike_hit': .38, 'saw_hit': .32, 'saw_jam': .5, 'anvil_warning': .5, 'anvil_drop': .65, 'body_pop': .22}
    for name, duration in durations.items():
        rng = random.Random(name)
        samples = []
        phase = 0.
        for index in range(round(duration * RATE)):
            time = index / RATE
            progress = time / duration
            envelope = min(1, time / .004) * (1 - progress) ** 2
            if name == 'spike_hit':
                hz = 650 * math.exp(-5 * progress) + 80
                wave_value = math.sin(phase + 2 * math.sin(math.tau * 28 * time))
            elif name == 'saw_hit':
                hz = 360 * (1 - progress) + 70
                wave_value = math.sin(phase) + .3 * math.sin(phase * 3) + .18 * rng.uniform(-1, 1)
            elif name == 'saw_jam':
                hz = 900 * (1 - progress) ** 3 + 120
                wave_value = math.sin(phase) + .2 * math.sin(phase * 2.3)
            elif name == 'anvil_warning':
                hz = 880 if time < .22 else 1174.66
                envelope *= abs(math.sin(math.pi * time / .25))
                wave_value = math.sin(phase) + .4 * math.sin(phase * 2.76)
            elif name == 'anvil_drop':
                hz = 130
                wave_value = math.sin(phase) + .6 * math.sin(phase * 3.42) + .3 * math.sin(phase * 7.13) + .5 * rng.uniform(-1, 1) * math.exp(-40 * time)
            else:
                hz = 90 + 700 * progress ** 2
                wave_value = math.sin(phase + math.sin(phase * .4))
            phase += math.tau * hz / RATE
            samples.append(wave_value * envelope)
        write('sfx/' + name + '.wav', samples)

if __name__ == '__main__':
    music()
    effects()
