"""Stłumione kopie dźwięków do wygłuszania przez ściany (aquila/code/game/sound_occlusion.dm).

BYOND 516 (FMOD Ex) nie filtruje dźwięku po stronie klienta, więc za ścianą gra gotowa kopia po filtrze
dolnoprzepustowym. Skrypt wybiera dźwięki najczęściej używane w kodzie (playsound z plikiem i zmienne typu
fire_sound/hitsound), wszystkie kroki z footsteps.dm i grupy z get_sfx(), filtruje je i zapisuje listę DM.

Użycie (z katalogu repo): python aquila/tools/muffle_sounds.py
Wymaga: numpy, scipy, soundfile.
"""
import collections
import glob
import os
import re
import sys

import numpy as np
import soundfile as sf
from scipy.signal import butter, resample_poly, sosfiltfilt

CUTOFF_HZ = 900          # jak przez ścianę: zostaje dół i środek, znika syk i klik
OUT_RATE = 22050         # po filtrze 900 Hz wyższa częstotliwość niczego nie wnosi
MIN_USES = 5             # dźwięk z co najmniej tylu miejsc w kodzie
MAX_SECONDS = 20         # dłuższe (muzyka, pętle) zostają bez kopii
OUT_DIR = 'aquila/sound/muffled'
DM_OUT = 'aquila/code/game/muffled_sounds.dm'
EXTRA_GLOBS = ['sound/machines/airlock*.ogg', 'sound/machines/door*.ogg', 'sound/machines/blastdoor.ogg',
               'sound/effects/explosion*.ogg', 'sound/effects/bang.ogg', 'sound/effects/clang.ogg']

USE_PATTERNS = [
    re.compile(r"playsound\(\s*[^,]+,\s*'([^']+\.ogg)'"),
    re.compile(r"(?:fire_sound|hitsound|open_sound|close_sound|usesound|drop_sound|pickup_sound|mob_throw_hit_sound"
               r"|attack_sound|deathsound|death_sound|equip_sound|doorOpen|doorClose|boltUp|boltDown|doorDeni)"
               r"\s*=\s*'([^']+\.ogg)'"),
]


def pick_sounds():
    uses = collections.Counter()
    for path in glob.glob('code/**/*.dm', recursive=True) + glob.glob('nsv13/**/*.dm', recursive=True) \
            + glob.glob('aquila/code/**/*.dm', recursive=True):
        text = open(path, encoding='utf-8', errors='ignore').read()
        for pattern in USE_PATTERNS:
            for match in pattern.finditer(text):
                uses[match.group(1)] += 1
    picked = {f for f, n in uses.items() if n >= MIN_USES}
    picked |= set(re.findall(r"'([^']+\.ogg)'", open('code/__DEFINES/footsteps.dm', encoding='utf-8').read()))
    sfx = open('code/game/sound.dm', encoding='utf-8').read().split('proc/get_sfx')[1].split('AQ EDIT START')[0]
    picked |= set(re.findall(r"'([^']+\.ogg)'", sfx))
    for pattern in EXTRA_GLOBS:
        picked |= {p.replace('\\', '/') for p in glob.glob(pattern)}
    # Głosy mają własne kopie (voice_muffled_sounds.dm), stłumione kopie nie potrzebują kopii
    return sorted(f for f in picked if os.path.isfile(f) and '/speech' not in f and not f.startswith(OUT_DIR))


def muffle(src, dst):
    data, rate = sf.read(src, always_2d=True)
    if len(data) > MAX_SECONDS * rate:
        return False
    mono = data.mean(axis=1)
    sos = butter(4, CUTOFF_HZ, 'lowpass', fs=rate, output='sos')
    out = sosfiltfilt(sos, mono)
    if rate != OUT_RATE:
        g = np.gcd(rate, OUT_RATE)
        out = resample_poly(out, OUT_RATE // g, rate // g)
    peak = np.abs(out).max()
    if peak > 0.99:
        out *= 0.99 / peak
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    sf.write(dst, out.astype('float32'), OUT_RATE, format='OGG', subtype='VORBIS')
    return True


def main():
    sounds = pick_sounds()
    done = []
    taken = set()
    for src in sounds:
        dst = f'{OUT_DIR}/{src}'
        # Fireball.ogg i fireball.ogg to dwa pliki, ale na Windowsie kopie nadpisałyby się nawzajem
        if dst.lower() in taken:
            print(f'pominięty {src}: kopia o tej nazwie już jest (wielkość liter)', file=sys.stderr)
            continue
        taken.add(dst.lower())
        try:
            if muffle(src, dst):
                done.append((src, dst))
        except Exception as error:  # uszkodzony albo nietypowy plik: zostaje bez kopii
            print(f'pominięty {src}: {error}', file=sys.stderr)
    lines = ['// Wygenerowane przez aquila/tools/muffle_sounds.py, nie edytuj ręcznie.',
             f'/// Stłumione kopie dźwięków (filtr dolnoprzepustowy {CUTOFF_HZ} Hz) do wygłuszania przez ściany, klucz to ścieżka oryginału jako tekst',
             'GLOBAL_LIST_INIT(muffled_sounds, list(']
    lines += [f"\t\"{src}\" = '{dst}'," for src, dst in done]
    lines[-1] = lines[-1].rstrip(',')
    lines.append('))')
    with open(DM_OUT, 'w', encoding='utf-8', newline='\n') as out:
        out.write('\n'.join(lines) + '\n')
    size = sum(os.path.getsize(dst) for _, dst in done)
    print(f'{len(done)} kopii, {size / 1e6:.1f} MB -> {DM_OUT}')


if __name__ == '__main__':
    main()
