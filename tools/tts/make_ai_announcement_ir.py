"""Odpowiedź impulsowa filtra ogłoszeń SI, dopasowana do sound/ai/default (ksenomorfy, meteory, burza jonowa, epidemia).
Łańcuch: górnoprzepustowy 300 Hz (Butterworth 4. rzędu) -> podbicie +7 dB przy 1500 Hz (Q 0,6) -> sygnał + 0,5 x pogłos
(szum z zanikiem RT60 0,5 s, opóźnienie wstępne 12 ms, energia 1). Całość liniowa, więc jedna IR wystarcza do afir.

Użycie: python tools/tts/make_ai_announcement_ir.py aquila/sound/ai/ai_tts_ir.wav [próbki ElevenLabs .mp3 ...]
Próbki służą tylko do dobrania wzmocnienia (szczyt po filtrze jak przed nim). Obecny plik: wzmocnienie 0,804
z czterech zdań głosem r43lnMEVUzxMWMYz9JXK (teksty ogłoszeń aliens, meteors, ionstorm, outbreak5).
Gra używa pliku przez ffmpeg (aq_tts_announcement_filter w aquila/code/modules/mob/living/silicon/ai/ai_tts.dm).
"""
import sys
import numpy as np
import soundfile as sf
from scipy.signal import butter, sosfilt, fftconvolve

SR = 44100
HP_HZ, HP_ORDER = 300, 4
PEQ_HZ, PEQ_DB, PEQ_Q = 1500, 7, 0.6
RT60, PREDELAY, WET = 0.5, 0.012, 0.5
LENGTH = 1.0


def peq_sos(f0, gain_db, q):
    a_gain = 10 ** (gain_db / 40)
    w = 2 * np.pi * f0 / SR
    alpha = np.sin(w) / (2 * q)
    b = [1 + alpha * a_gain, -2 * np.cos(w), 1 - alpha * a_gain]
    a = [1 + alpha / a_gain, -2 * np.cos(w), 1 - alpha / a_gain]
    return np.array([[b[0] / a[0], b[1] / a[0], b[2] / a[0], 1, a[1] / a[0], a[2] / a[0]]])


def build_ir():
    n = int(SR * LENGTH)
    rng = np.random.default_rng(3)
    t = np.arange(int(SR * RT60 * 2)) / SR
    reverb = rng.standard_normal(len(t)) * np.exp(-t * 6.9 / RT60)
    reverb = np.concatenate([np.zeros(int(PREDELAY * SR)), reverb])
    reverb /= np.sqrt((reverb ** 2).sum())
    room = np.zeros(n)
    room[0] = 1
    room[:len(reverb)] += WET * reverb[:n]
    eq = sosfilt(butter(HP_ORDER, HP_HZ, 'high', fs=SR, output='sos'), np.eye(1, n, 0).ravel())
    eq = sosfilt(peq_sos(PEQ_HZ, PEQ_DB, PEQ_Q), eq)
    ir = fftconvolve(eq, room)[:n]
    # zanik do zera na ostatnich 50 ms, bez trzasku na końcu
    fade = int(0.05 * SR)
    ir[-fade:] *= np.linspace(1, 0, fade)
    return ir


if __name__ == '__main__':
    ir = build_ir()
    # wzmocnienie: typowa wypowiedź ElevenLabs po filtrze ma szczyt ok. 0,9 (resztę łapie alimiter)
    peaks = []
    for path in sys.argv[2:]:
        x, sr = sf.read(path)
        peaks.append(np.abs(fftconvolve(x, ir)).max() / max(np.abs(x).max(), 1e-9))
    gain = 1 / np.median(peaks) if peaks else 1
    ir *= gain
    sf.write(sys.argv[1], ir.astype(np.float32), SR, subtype='FLOAT')
    print('gain', round(gain, 3), 'ir peak', round(float(np.abs(ir).max()), 3), 'len', len(ir))
