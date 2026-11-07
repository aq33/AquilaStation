import re, sys, numpy as np, soundfile as sf
from scipy.signal import stft

d, sr = sf.read('rec.wav')
d = d[:, :2]
log = open('dd.log', encoding='utf-8', errors='ignore').read()
ev = {m.group(2): int(m.group(1)) for m in re.finditer(r'^(\d+) (L\d latency|W\d [^\n]*|idle start|native start|web start|webrev start|webrev end|idle end|native end|web end)$', log, re.M)}

f, t, Z = stft(d.T, fs=sr, nperseg=1024, noverlap=768)
P = np.abs(Z) ** 2
def band(lo, hi): return P[:, (f >= lo) & (f < hi), :].sum(axis=1)
b2 = band(1950, 2050).sum(axis=0)
b9 = band(8950, 9050).sum(axis=0)
dt = t[1] - t[0]
def onset(b, t_from, t_to):
    m = (t >= t_from) & (t < t_to)
    seg = b[m]
    if not len(seg) or seg.max() <= 0: return None
    i = np.argmax(seg > seg.max() * 0.3)
    return t[m][i]

# Odniesienie czasu: pierwszy natywny ton 2 kHz (L1)
first = onset(b2, 0, len(d) / sr)
base = ev['L1 latency']
print('Opóźnienie Web Audio względem natywnego sound (ten sam tick serwera):')
for i in range(1, 6):
    s = first + (ev[f'L{i} latency'] - base) / 10
    n = onset(b2, s - 0.3, s + 1.0)
    w = onset(b9, s - 0.3, s + 1.5)
    print(f'  L{i}: natywny {n:.3f}s  web {w:.3f}s  różnica {1000 * (w - n):.0f} ms' if n and w else f'  L{i}: brak ({n}, {w})')

def seg(name, a=0.1, z=1.0):
    s = first + (ev[name] - base) / 10
    x = d[int((s + a) * sr):int((s + z) * sr)]
    return x, s
def db(x): return 10 * np.log10(x + 1e-20)
def bands(x):
    m = x.sum(axis=1); sp = np.abs(np.fft.rfft(m)) ** 2; ff = np.fft.rfftfreq(len(m), 1 / sr)
    return [sp[(ff >= a) & (ff < b)].sum() for a, b in [(50, 500), (500, 2000), (2000, 6000), (6000, 16000)]]

# W0 może być przesunięty o opóźnienie web: szukamy początku po onsetcie szumu w szerokim paśmie
ref = None
print('Widmo (pasma <0.5k, 0.5-2k, 2-6k, >6k kHz względem W0), L-P, ogon:')
for name in [k for k in ev if k.startswith('W')]:
    s = first + (ev[name] - base) / 10
    bb = P[:, (f > 6000) & (f < 16000), :].sum(axis=(0, 1)) + P[:, (f > 100) & (f < 1000), :].sum(axis=(0, 1))
    o = onset(bb, s - 0.2, s + 1.5) or s
    x = d[int((o + 0.05) * sr):int((o + 1.05) * sr)]
    tail = d[int((o + 1.3) * sr):int((o + 1.8) * sr)]
    bs = bands(x)
    if ref is None: ref = bs; ref_tot = (x ** 2).sum()
    L = (x[:, 0] ** 2).mean(); R = (x[:, 1] ** 2).mean()
    print(f'  {name:22s} start+{1000 * (o - s):4.0f}ms  pasma {[round(db(a / b), 1) for a, b in zip(bs, ref)]}  L-P {db(L / R):6.1f} dB  ogon {db((tail ** 2).sum() / ref_tot):6.1f} dB')

# HRTF przód/tył: różnica widma w pasmach 1/3 oktawy
def spec(name):
    s = first + (ev[name] - base) / 10
    bb = P[:, (f > 100) & (f < 16000), :].sum(axis=(0, 1))
    o = onset(bb, s - 0.2, s + 1.5) or s
    x = d[int((o + 0.05) * sr):int((o + 1.05) * sr)].sum(axis=1)
    sp = np.abs(np.fft.rfft(x)) ** 2; ff = np.fft.rfftfreq(len(x), 1 / sr)
    edges = [500, 1000, 2000, 3000, 4000, 6000, 8000, 10000, 12000, 16000]
    return [sp[(ff >= edges[i]) & (ff < edges[i + 1])].sum() for i in range(len(edges) - 1)]
fr, bk = spec('W5 hrtf front'), spec('W6 hrtf behind')
print('HRTF tył minus przód (dB) w pasmach 0.5-1,1-2,2-3,3-4,4-6,6-8,8-10,10-12,12-16 kHz:', [round(db(b / a), 1) for a, b in zip(fr, bk)])
