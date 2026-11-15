"""Generuje nagrania ogłoszeń eventów głosem announcera (ElevenLabs + filtr jak w ai_tts.dm).

Użycie:
    python tools/tts/make_event_announcements.py --key-file ŚCIEŻKA [--only id1,id2] [--force]

Teksty: tools/tts/event_announcements.tsv (kolumny plik, tekst).
Wynik: aquila/sound/ai/events/<plik>.ogg. Istniejące pliki są pomijane bez --force.
Wymaga ffmpeg w PATH albo w --ffmpeg. Klucz ElevenLabs czytany z pierwszej linii pliku,
nigdy nie trafia do repo.
"""
import argparse
import csv
import json
import os
import subprocess
import sys
import tempfile
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TSV = os.path.join(ROOT, "tools", "tts", "event_announcements.tsv")
OUT_DIR = os.path.join(ROOT, "aquila", "sound", "ai", "events")
IR = os.path.join(ROOT, "aquila", "sound", "ai", "ai_tts_ir.wav")
# Ten sam głos co polski dubbing sound/ai/default (AI_TTS_VOICE w config/squad_tts.txt).
VOICE = "r43lnMEVUzxMWMYz9JXK"
MODEL = "eleven_multilingual_v2"
# Filtr z aquila/code/modules/mob/living/silicon/ai/ai_tts.dm, plus wyrównanie głośności do nagrań sound/ai/default.
FILTER = "[0:a]apad=pad_dur=0.6[s];[s][1:a]afir=irnorm=-1,loudnorm=I=-25:TP=-3:LRA=11,alimiter=limit=0.9:level=disabled"


def tts(key, text, dest):
    payload = json.dumps({
        "text": text,
        "model_id": MODEL,
        "language_code": "pl",
        "voice_settings": {"stability": 0.6, "similarity_boost": 0.8},
    }).encode("utf-8")
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}?output_format=mp3_44100_128",
        data=payload,
        headers={"xi-api-key": key, "Content-Type": "application/json", "Accept": "audio/mpeg"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp, open(dest, "wb") as f:
        f.write(resp.read())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--key-file", required=True)
    ap.add_argument("--ffmpeg", default="ffmpeg")
    ap.add_argument("--only", default="")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    with open(args.key_file, encoding="utf-8") as f:
        key = f.readline().strip()
    only = set(filter(None, args.only.split(",")))
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(TSV, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f, delimiter="\t"))
    done = 0
    with tempfile.TemporaryDirectory() as tmp:
        for row in rows:
            name, text = row["plik"], row["tekst"]
            if only and name not in only:
                continue
            out = os.path.join(OUT_DIR, name + ".ogg")
            if os.path.exists(out) and not args.force:
                continue
            raw = os.path.join(tmp, name + ".mp3")
            tts(key, text, raw)
            subprocess.run([args.ffmpeg, "-nostdin", "-hide_banner", "-loglevel", "error", "-y",
                            "-i", raw, "-i", IR, "-filter_complex", FILTER,
                            "-ar", "44100", "-ac", "1", "-c:a", "libvorbis", "-q:a", "4", out], check=True)
            done += 1
            print(f"{name}: ok", flush=True)
    print(f"wygenerowano: {done}")


if __name__ == "__main__":
    sys.exit(main())
