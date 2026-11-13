"""Scenariusze w działającym świecie przez debugger auxtools 3: odtworzenie zgłoszonego błędu bez klienta.

Scenariusz to plik z ciałem procki DM (bez nagłówka), np. tools/scenario/examples/smoke.txt. Działa jako kod świata
(eval --spawn), więc może wołać procki, tworzyć obiekty i czekać przez sleep(). Zwrócenie TRUE albo "OK" oznacza
sukces; każda inna wartość albo runtime to porażka, a zwrócony tekst trafia do wyniku.

Użycie (z katalogu repo, po zbudowaniu nsv13.dmb):
    python tools/scenario/scenario.py tools/scenario/examples/smoke.txt
    python tools/scenario/scenario.py moj.txt --runda          # najpierw wystartuj rundę (stan PLAYING)
    python tools/scenario/scenario.py moj.txt --zostaw         # nie zatrzymuj świata, wypisz jego PID
    python tools/scenario/scenario.py moj.txt -D UNIT_TESTS    # flagi, z którymi zbudowano .dmb

Po scenariuszu skrypt dołącza audyt logów rundy (tools/round_audit) i kończy z kodem 1, gdy scenariusz się nie udał.

Świat startuje z hot-reloadem, bo tylko wtedy eval zna makra #define projektu (ITEM_SLOT_*, COMSIG_* itp.).
Nie edytuj więc plików .dm w tym folderze w trakcie scenariusza: zapis podmieni procki w działającym świecie.
"""

import argparse
import glob
import json
import os
import socket
import subprocess
import sys
import time
import urllib.request

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(REPO, "tools", "local_ci"))
sys.path.insert(0, os.path.join(REPO, "tools", "round_audit"))
from local_ci import CACHE, find_byond  # noqa: E402
import round_audit  # noqa: E402

AUXTOOLS_VERSION = "3.0.1"


def auxtools_cli():
	"""CLI auxtools: AUXTOOLS_CLI, PATH, rozszerzenie VS Code albo pobranie wydania do tools/bootstrap/.cache."""
	explicit = os.environ.get("AUXTOOLS_CLI")
	if explicit and os.path.exists(explicit):
		return explicit
	from shutil import which
	found = which("auxtools")
	if found:
		return found
	ext = sorted(glob.glob(os.path.join(os.path.expanduser("~"), ".vscode", "extensions", "sohpea.auxtools-*", "bin", "win32", "auxtools.exe")))
	if ext:
		return ext[-1]
	folder = os.path.join(CACHE, f"auxtools-{AUXTOOLS_VERSION}")
	os.makedirs(folder, exist_ok=True)
	for name in ("auxtools.exe", "debug_server.dll"):
		target = os.path.join(folder, name)
		if not os.path.exists(target):
			url = f"https://github.com/auxtools/auxtools/releases/download/v{AUXTOOLS_VERSION}/{name}"
			print(f"pobieram {url}")
			urllib.request.urlretrieve(url, target + ".part")
			os.replace(target + ".part", target)
	return os.path.join(folder, "auxtools.exe")


def free_port():
	with socket.socket() as s:
		s.bind(("127.0.0.1", 0))
		return s.getsockname()[1]


class World:
	def __init__(self, cli, pid):
		self.cli = cli
		self.pid = pid

	def call(self, *args, timeout=120):
		proc = subprocess.run([self.cli, "--pid", str(self.pid), *args], capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout, env=dict(os.environ, MSYS_NO_PATHCONV="1"))
		return proc.returncode, proc.stdout.strip(), proc.stderr.strip()

	def eval(self, expression):
		code, out, err = self.call("eval", expression, "--json")
		if code:
			return None
		try:
			return json.loads(out)
		except ValueError:
			return out

	def wait_for(self, expression, label, limit):
		started = time.time()
		while time.time() - started < limit:
			if self.eval(expression) in (1, True):
				return True
			time.sleep(2)
		raise SystemExit(f"Świat nie doszedł do stanu „{label}” w {limit} s.")


def main():
	for stream in (sys.stdout, sys.stderr):
		if hasattr(stream, "reconfigure"):
			stream.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Scenariusz DM w świecie uruchomionym pod auxtools.")
	parser.add_argument("scenariusz", help="plik z ciałem procki DM")
	parser.add_argument("--dmb", default="nsv13.dmb")
	parser.add_argument("-D", dest="defines", action="append", default=[], help="flagi kompilacji .dmb (CBT dodawane zawsze)")
	parser.add_argument("--runda", action="store_true", help="wystartuj rundę przed scenariuszem")
	parser.add_argument("--zostaw", action="store_true", help="nie zatrzymuj świata po scenariuszu")
	parser.add_argument("--limit", type=int, default=600, help="limit czasu na start świata i na scenariusz (s)")
	parser.add_argument("--byond", help="folder BYOND (domyślnie wersja z dependencies.sh)")
	args = parser.parse_args()

	cli = auxtools_cli()
	byond = find_byond(args.byond)
	defines = ["CBT", *[d for d in args.defines if d != "CBT"]]
	launch = [cli, "launch", args.dmb, "--detach", "--json", "--server", "dd", "--port", str(free_port()), "--byond", byond]
	for d in defines:
		launch += ["-D", d]
	proc = subprocess.run(launch, cwd=os.getcwd(), capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=300)
	if proc.returncode:
		raise SystemExit("auxtools launch nie wystartował świata:\n" + proc.stdout + proc.stderr)
	info = json.loads(proc.stdout)
	world = World(cli, info["pid"])
	print(f"Świat: PID {world.pid}, log launchera {info['log']}")
	ok = False
	try:
		world.wait_for("SSticker && SSticker.current_state >= 1", "lobby", args.limit)
		if args.runda:
			world.eval("SSticker.start_immediately = TRUE")
			world.wait_for("SSticker.current_state == 3", "runda trwa", args.limit)
		print("Scenariusz...")
		code, out, err = world.call("eval", "--file", args.scenariusz, "--spawn", "--wait", "--timeout", str(args.limit), "--json", timeout=args.limit + 60)
		result = None
		if out:
			try:
				result = json.loads(out)
			except ValueError:
				result = out
		ok = code == 0 and (result in (1, True, "OK"))
		print(f"Wynik: {'OK' if ok else 'PORAŻKA'} (kod {code}): {json.dumps(result, ensure_ascii=False) if result is not None else ''}")
		if err:
			print(err)
	finally:
		if args.zostaw:
			print(f"Świat zostaje: PID {world.pid}. Zatrzymanie: \"{cli}\" --pid {world.pid} stop --kill")
		else:
			world.call("stop", "--kill", timeout=60)
	rounds = round_audit.find_rounds(os.path.join(os.getcwd(), "data", "logs"))
	if rounds:
		report, _ = round_audit.render(round_audit.audit(rounds[-1]), None, 15)
		print()
		print(report)
	return 0 if ok else 1


if __name__ == "__main__":
	sys.exit(main())
