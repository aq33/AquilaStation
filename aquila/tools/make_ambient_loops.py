"""Pętle szumu maszyn do dźwięków otoczenia (aquila/code/controllers/subsystem/ambient_emitters.dm).

Klient gra je z repeat = 1, więc koniec pliku musi przejść w początek bez trzasku: ostatnie
CROSSFADE sekund przenika się z początkiem (równa moc). Źródła to istniejące pętle maszyn z aquila/sound.

Użycie (z katalogu repo): python aquila/tools/make_ambient_loops.py
Wymaga: numpy, scipy, soundfile.
"""
import os

import numpy as np
import soundfile as sf
from scipy.signal import resample_poly

CROSSFADE = 0.3
OUT_DIR = 'aquila/sound/ambience/emitters'
# nazwa wyjściowa: (źródło, zmiana prędkości odtwarzania)
LOOPS = {
    'vent': ('aquila/sound/machines/thermal/vent_mid.ogg', 1.0),
    'scrubber': ('aquila/sound/machines/thermal/vent_mid.ogg', 0.85),
    'apc': ('aquila/sound/machines/electronics/transformator_mid.ogg', 1.0),
    'vending': ('aquila/sound/machines/electronics/computer_mid1.ogg', 1.0),
}


def make_loop(src, speed):
    data, rate = sf.read(src, always_2d=True)
    x = data.mean(axis=1)
    if speed != 1.0:
        # wolniej = niżej: więcej próbek przy tej samej częstotliwości
        up, down = int(round(100 / speed)), 100
        x = resample_poly(x, up, down)
    fade = int(CROSSFADE * rate)
    t = np.linspace(0, np.pi / 2, fade)
    body = x[:len(x) - fade].copy()
    body[:fade] = x[:fade] * np.sin(t) + x[len(x) - fade:] * np.cos(t)
    peak = np.abs(body).max()
    if peak > 0.99:
        body *= 0.99 / peak
    return body.astype('float32'), rate


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, (src, speed) in LOOPS.items():
        loop, rate = make_loop(src, speed)
        dst = f'{OUT_DIR}/{name}.ogg'
        sf.write(dst, loop, rate, format='OGG', subtype='VORBIS')
        print(f'{dst}: {len(loop) / rate:.2f} s, skok na styku {abs(loop[0] - loop[-1]):.4f}')


if __name__ == '__main__':
    main()
