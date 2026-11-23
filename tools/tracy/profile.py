"""Profil świata przez byond-tracy bez GUI: start z AQUILA_TRACY=1, N sekund pracy, tabela najdroższych procek.

Łańcuch: prof.dll zapisuje data/profiler/*.utracy -> rtracy odtwarza go jako serwer Tracy -> tracy-capture zapisuje
.tracy -> tracy-csvexport daje CSV (nazwa procki, suma, liczba wywołań, średnia, maks.). Plik .tracy otwiera też
tracy-profiler.exe (oś czasu ticków). Narzędzia i wersje: tools/tracy/README.md.

Użycie (z katalogu repo, po zbudowaniu nsv13.dmb i prof.dll obok niego):
  python tools/tracy/profile.py --sekundy 120                  # start, lobby, 120 s pracy
  python tools/tracy/profile.py --runda --sekundy 300           # najpierw runda (przez auxtools nie da się: tylko lobby + start_now w configu)
  python tools/tracy/profile.py --plik data/profiler/X.utracy   # tylko analiza istniejącego zapisu
Opcje: --top N, --csv WYNIK.csv, --narzedzia FOLDER (tracy-capture, tracy-csvexport, rtracy; domyślnie ~/tools/tracy).
"""

import argparse
import csv
import glob
import io
import os
import socket
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(REPO, "tools", "local_ci"))
from local_ci import find_byond  # noqa: E402


def tool(folder, name):
	hits = glob.glob(os.path.join(folder, "**", name), recursive=True)
	if not hits:
		raise SystemExit(f"Brak {name} w {folder} (instrukcja: tools/tracy/README.md).")
	return hits[0]


def free_port():
	with socket.socket() as s:
		s.bind(("127.0.0.1", 0))
		return s.getsockname()[1]


def record(seconds, dmb):
	dd = os.path.join(find_byond(None), "bin", "dd.exe")
	if not os.path.exists("prof.dll"):
		raise SystemExit("Brak prof.dll obok .dmb: python tools/tracy/build_prof.py")
	before = set(glob.glob(os.path.join("data", "profiler", "*.utracy")))
	env = dict(os.environ, AQUILA_TRACY="1")
	print(f"start świata z tracy na {seconds} s...")
	proc = subprocess.Popen([dd, dmb, "-port", str(free_port()), "-trusted", "-invisible"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
	try:
		time.sleep(seconds)
	finally:
		proc.kill()
		proc.wait(60)
	after = set(glob.glob(os.path.join("data", "profiler", "*.utracy")))
	new = sorted(after - before, key=os.path.getmtime)
	if not new:
		raise SystemExit("Świat nie zapisał .utracy: w logu świata szukaj „byond-tracy:” (zła wersja BYOND albo brak DLL).")
	return new[-1]


def to_csv(utracy, tools):
	rtracy = tool(tools, "rtracy.exe")
	capture = tool(tools, "tracy-capture.exe")
	export = tool(tools, "tracy-csvexport.exe")
	port = free_port()
	out = os.path.splitext(utracy)[0] + ".tracy"
	server = subprocess.Popen([rtracy, utracy, "-p", str(port)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
	try:
		time.sleep(1)
		subprocess.run([capture, "-a", "127.0.0.1", "-p", str(port), "-o", out, "-f"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3600)
	finally:
		server.kill()
	if not os.path.exists(out):
		raise SystemExit("tracy-capture nie zapisał pliku .tracy")
	result = subprocess.run([export, out], capture_output=True, text=True, encoding="utf-8", errors="replace")
	return out, result.stdout


def main():
	for stream in (sys.stdout, sys.stderr):
		stream.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Profil świata przez byond-tracy.")
	parser.add_argument("--sekundy", type=int, default=120)
	parser.add_argument("--dmb", default="nsv13.dmb")
	parser.add_argument("--plik", help="istniejący .utracy zamiast nowego zapisu")
	parser.add_argument("--top", type=int, default=30)
	parser.add_argument("--csv", help="zapisz pełny CSV")
	parser.add_argument("--narzedzia", default=os.path.join(os.path.expanduser("~"), "tools", "tracy"))
	args = parser.parse_args()

	utracy = args.plik or record(args.sekundy, args.dmb)
	print(f"zapis: {utracy} ({os.path.getsize(utracy) / 1e6:.1f} MB)")
	tracy_file, text = to_csv(utracy, args.narzedzia)
	print(f"plik Tracy: {tracy_file} (tracy-profiler.exe pokazuje oś czasu)")
	if args.csv:
		open(args.csv, "w", encoding="utf-8").write(text)
	rows = list(csv.DictReader(io.StringIO(text)))
	if not rows:
		raise SystemExit("Pusty eksport (zapis za krótki albo uszkodzony).")
	rows.sort(key=lambda r: int(r["total_ns"]), reverse=True)
	print(f"\n{'suma ms':>10} {'%':>6} {'wywołań':>9} {'śr. µs':>9} {'maks. ms':>9}  procka")
	for r in rows[:args.top]:
		print(f"{int(r['total_ns']) / 1e6:10.1f} {float(r['total_perc']):6.2f} {int(r['counts']):9d} {int(r['mean_ns']) / 1e3:9.1f} {int(r['max_ns']) / 1e6:9.2f}  {r['name']}")
	return 0


if __name__ == "__main__":
	sys.exit(main())
