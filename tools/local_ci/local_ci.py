"""Lokalne CI Aquili: te same sprawdzenia co .github/workflows/continuous_integration.yml, uruchamiane przed pushem.

Użycie (z katalogu repo, Windows):
    tools\\local_ci\\local_ci.bat                 # lintery, kompilacja DM, dreamchecker, TGUI
    tools\\local_ci\\local_ci.bat --szybko        # bez TGUI (najwolniejszy krok poza mapami i testami)
    tools\\local_ci\\local_ci.bat --pelne         # do tego wszystkie mapy (-DALL_MAPS) i testy jednostkowe
    tools\\local_ci\\local_ci.bat --tylko grep,dm # wybrane kroki (nazwy: --lista)

Kompilacja idzie do kopii .dme (ci_local_*.dme), więc nsv13.dmb i działający serwer zostają nietknięte.
Do tools/bootstrap/.cache pobiera dreamcheckera w wersji z dependencies.sh (SPACEMAN_DMM_VERSION)
i jq w wersji ze stałej JQ_VERSION poniżej.
"""

import argparse
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CACHE = os.path.join(REPO, "tools", "bootstrap", ".cache")
JQ_VERSION = "1.7.1"
DME = "nsv13.dme"


def dependency(key):
	with open(os.path.join(REPO, "dependencies.sh"), encoding="utf-8") as f:
		for line in f:
			m = re.match(rf"^export {key}=(.+)$", line.strip())
			if m:
				return m.group(1)
	raise SystemExit(f"Brak {key} w dependencies.sh")


def download(url, target):
	if os.path.exists(target):
		return target
	os.makedirs(os.path.dirname(target), exist_ok=True)
	print(f"   pobieram {url}")
	tmp = target + ".part"
	urllib.request.urlretrieve(url, tmp)
	os.replace(tmp, target)
	return target


def bootstrap_python():
	exe = os.path.join(CACHE, f"python-{dependency('PYTHON_VERSION')}", "python.exe")
	if not os.path.exists(exe):
		# pierwsze uruchomienie: skrypt bootstrapu ściąga Pythona i paczki z tools/requirements.txt
		subprocess.run([os.path.join(REPO, "tools", "bootstrap", "python.bat"), "-c", "pass"], cwd=REPO, check=True)
	return exe


def git_bash():
	git = shutil.which("git")
	if git:
		folder = os.path.dirname(os.path.realpath(git))
		# git.exe bywa w Git/cmd, Git/bin albo Git/mingw64/bin, więc idziemy w górę aż do bin/bash.exe
		for _ in range(4):
			candidate = os.path.join(folder, "bin", "bash.exe")
			if os.path.exists(candidate):
				return candidate
			folder = os.path.dirname(folder)
	default = os.path.join(os.environ.get("ProgramFiles", r"C:\Program Files"), "Git", "bin", "bash.exe")
	if os.path.exists(default):
		return default
	# bash z System32 to WSL, który nie widzi ścieżek Windows tak jak Git Bash
	raise RuntimeError("Nie znalazłem Git Bash (bin/bash.exe obok git.exe)")


def find_byond(explicit=None):
	"""Folder BYOND w wersji z dependencies.sh."""
	want = f"{dependency('BYOND_MAJOR')}.{dependency('BYOND_MINOR')}"
	candidates = [explicit, os.environ.get("BYOND_SYSTEM"), os.path.join(CACHE, f"byond-{want}", "byond")]
	pf = os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")
	candidates += glob.glob(os.path.join(pf, "*", "BYOND")) + glob.glob(os.path.join(pf, "BYOND"))
	candidates += glob.glob(os.path.join(CACHE, "byond-*", "byond"))
	for folder in candidates:
		if not folder:
			continue
		dm = os.path.join(folder, "bin", "dm.exe")
		if not os.path.exists(dm):
			continue
		out = subprocess.run([dm], capture_output=True, text=True, errors="replace").stdout
		m = re.search(r"version (\d+\.\d+)", out)
		if m and m.group(1) == want:
			return folder
	raise SystemExit(f"Nie znalazłem BYOND {want}. Podaj --byond albo zbuduj raz przez BUILD.bat (pobierze go do tools/bootstrap/.cache).")


class Runner:
	def __init__(self, args):
		self.args = args
		self.results = []
		self._byond = None
		self._bash = None
		self._python = None

	@property
	def byond(self):
		if not self._byond:
			self._byond = find_byond(self.args.byond)
		return self._byond

	@property
	def bash(self):
		if not self._bash:
			self._bash = git_bash()
		return self._bash

	@property
	def python(self):
		if not self._python:
			self._python = bootstrap_python()
		return self._python

	def run(self, cmd, env=None, cwd=REPO, timeout=None):
		full_env = dict(os.environ)
		if env:
			full_env.update(env)
		proc = subprocess.run(cmd, cwd=cwd, env=full_env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout)
		return proc.returncode, (proc.stdout or "") + (proc.stderr or "")

	def bash_script(self, script, *script_args, env=None):
		jq_dir = os.path.dirname(self.jq())
		path_env = {"MSYS_NO_PATHCONV": "1", "PYTHONUTF8": "1"}
		# skrypty CI wołają python3; na Windows to często atrapa ze Sklepu, więc podstawiamy Pythona z bootstrapu
		shim = os.path.join(CACHE, "local_ci_bin")
		os.makedirs(shim, exist_ok=True)
		with open(os.path.join(shim, "python3"), "w", newline="\n") as f:
			f.write(f'#!/bin/sh\nexec "{self.python.replace(os.sep, "/")}" "$@"\n')
		if env:
			path_env.update(env)
		return self.run([self.bash, "-c", f'export PATH="$(cygpath -u "{shim}"):$(cygpath -u "{jq_dir}"):$PATH"; ' + " ".join([script, *script_args])], env=path_env)

	def jq(self):
		return download(f"https://github.com/jqlang/jq/releases/download/jq-{JQ_VERSION}/jq-windows-amd64.exe", os.path.join(CACHE, f"jq-{JQ_VERSION}", "jq.exe"))

	def dreamchecker(self):
		version = dependency("SPACEMAN_DMM_VERSION")
		return download(f"https://github.com/SpaceManiac/SpacemanDMM/releases/download/{version}/dreamchecker.exe", os.path.join(CACHE, f"spacemandmm-{version}", "dreamchecker.exe"))

	def compile_copy(self, name, defines, timeout=1800):
		"""Kompiluje kopię nsv13.dme, żeby nie ruszać nsv13.dmb ani .rsc zablokowanego przez działający serwer."""
		dme = f"ci_local_{name}.dme"
		shutil.copyfile(os.path.join(REPO, DME), os.path.join(REPO, dme))
		cmd = [os.path.join(self.byond, "bin", "dm.exe")] + [f"-D{d}" for d in ["CBT", *defines]] + [dme]
		try:
			code, out = self.run(cmd, timeout=timeout)
		finally:
			os.remove(os.path.join(REPO, dme))
		summary = [line for line in out.splitlines() if re.search(r"error|warning", line, re.I)]
		return code, dme[:-4], "\n".join(summary[-60:]) or out[-3000:]

	def cleanup_copy(self, base):
		for ext in (".dmb", ".rsc", ".lk", ".int", ".dyn.rsc"):
			path = os.path.join(REPO, base + ext)
			if os.path.exists(path):
				try:
					os.remove(path)
				except OSError:
					pass


# --- kroki --------------------------------------------------------------------------------------------------

def step_filedirs(r):
	return r.bash_script("bash", "tools/ci/check_filedirs.sh", DME)


def step_changelog(r):
	# check_changelogs.sh przerabia changelog i kasuje pliki .yml, więc lokalnie robimy to na kopii
	import hashlib
	with open(os.path.join(REPO, "html", "changelogs", "example.yml"), "rb") as f:
		# CI liczy sumę z checkoutu na Linuksie (LF), a na Windows git może zamienić końce linii na CRLF
		if hashlib.md5(f.read().replace(b"\r\n", b"\n")).hexdigest() != "49bc6b1b9ed56c83cceb6674bd97cb34":
			return 1, "html/changelogs/example.yml został zmieniony (CI sprawdza jego sumę md5)"
	with tempfile.TemporaryDirectory() as tmp:
		html = os.path.join(tmp, "html")
		shutil.copytree(os.path.join(REPO, "html", "changelogs"), os.path.join(html, "changelogs"))
		shutil.copytree(os.path.join(REPO, "html", "templates"), os.path.join(html, "templates"))
		shutil.copyfile(os.path.join(REPO, "html", "changelog.html"), os.path.join(html, "changelog.html"))
		return r.run([r.python, os.path.join(REPO, "tools", "changelog", "ss13_genchangelog.py"), os.path.join(html, "changelog.html"), os.path.join(html, "changelogs")])


def step_json(r):
	files = []
	for root, dirs, names in os.walk(REPO):
		dirs[:] = [d for d in dirs if d not in ("node_modules", ".git", ".yarn") and not d.startswith(".cache")]
		files += [os.path.relpath(os.path.join(root, n), REPO) for n in names if n.endswith(".json")]
	return r.run([r.python, "tools/json_verifier.py", *files])


def step_grep(r):
	return r.bash_script("bash", "tools/ci/check_grep.sh")


def step_altclick(r):
	return r.run([r.python, "tools/ci/check_alt_click_loot.py"], env={"PYTHONUTF8": "1"})


def step_mapconn(r):
	return r.run([r.python, "tools/ci/check_map_connections.py"], env={"PYTHONUTF8": "1"})


def step_dmi(r):
	return r.run([r.python, "-m", "dmi.test"], cwd=os.path.join(REPO, "tools"))


def step_mapmerge(r):
	return r.run([r.python, "-m", "mapmerge2.dmm_test"], cwd=os.path.join(REPO, "tools"))


def base_branch(explicit):
	"""master z remote'u, który wskazuje na repo Aquili (u jednych aq33, u innych origin)."""
	if explicit:
		return explicit
	remotes = subprocess.run(["git", "remote", "-v"], cwd=REPO, capture_output=True, text=True).stdout
	for line in remotes.splitlines():
		parts = line.split()
		if len(parts) >= 2 and re.search(r"aq33/(AquilaStation|NSV13)(\.git)?$", parts[1], re.I):
			return f"{parts[0]}/master"
	return "origin/master"


def step_i18n(r):
	base = base_branch(r.args.baza)
	# brak bazy to błąd narzędzia, nie brakujące tłumaczenia: bez tego krok po cichu by nic nie sprawdzał
	if subprocess.run(["git", "rev-parse", "--verify", "--quiet", base], cwd=REPO, capture_output=True).returncode:
		raise RuntimeError(f"Nie ma gałęzi bazowej {base}; podaj --baza albo zrób git fetch")
	code, out = r.run([r.python, "tools/i18n/list_missing.py", "--changed", base], env={"PYTHONUTF8": "1"})
	return code, out


def step_tgui(r):
	return r.run([os.path.join(REPO, "tools", "build", "build.bat"), "--ci", "lint", "tgui-test", "tgui"], timeout=3600)


def step_dm(r):
	code, base, out = r.compile_copy("dm", [])
	r.cleanup_copy(base)
	m = re.search(r"(\d+) errors?, (\d+) warnings?", out)
	if m and (m.group(1) != "0" or m.group(2) != "0"):
		code = code or 1
	return code, out


def step_dreamchecker(r):
	return r.run([r.dreamchecker(), "-e", DME], timeout=1800)


def step_maps(r):
	code, out = r.run([os.path.join(REPO, "tools", "build", "build.bat"), "dm-maps-include"])
	if code:
		return code, out
	try:
		code, base, out = r.compile_copy("maps", ["CIBUILDING", "CITESTING", "ALL_MAPS"], timeout=3600)
	finally:
		templates = os.path.join(REPO, "_maps", "templates.dm")
		if os.path.exists(templates):
			os.remove(templates)
	r.cleanup_copy(base)
	m = re.search(r"(\d+) errors?, (\d+) warnings?", out)
	if m and m.group(1) != "0":
		code = code or 1
	return code, out


TEST_DEPLOY = os.path.join(CACHE, "ci_test")


def deploy_tests(base):
	"""Osobna kopia świata jak tools/deploy.sh w CI: własne config/ i data/, więc testy nie piszą do bazy
	z config/dbconfig.txt ani do persistencji dewelopera (data/*.json). Bez SQL, jak lokalny serwer bez bazy."""
	shutil.rmtree(TEST_DEPLOY, ignore_errors=True)
	os.makedirs(TEST_DEPLOY)
	for ext in (".dmb", ".rsc"):
		shutil.copyfile(os.path.join(REPO, base + ext), os.path.join(TEST_DEPLOY, base + ext))
	for folder in ("_maps", "code/datums/greyscale/json_configs", "icons", "sound/runtime", "strings",
			"html/changelogs/archive", "tgui/public", "tgui/packages/tgfont/dist", "config"):
		source = os.path.join(REPO, folder)
		if os.path.isdir(source):
			# z plikami .dm jak deploy.sh: testy czytają np. _maps/_basemap.dm
			shutil.copytree(source, os.path.join(TEST_DEPLOY, folder))
	for pattern in ("*.dll", "yt-dlp.exe"):
		for path in glob.glob(os.path.join(REPO, pattern)):
			shutil.copy2(path, TEST_DEPLOY)
	# config.txt z CI, ale bez bazy: lokalnie nie ma bee_ci, a dbconfig.txt dewelopera wskazuje jego bazę
	with open(os.path.join(REPO, "tools", "ci", "ci_config.txt"), encoding="utf-8") as f:
		ci_config = [line for line in f if not re.match(r"\s*(SQL_ENABLED|ADDRESS|PORT|FEEDBACK_)", line)]
	with open(os.path.join(TEST_DEPLOY, "config", "config.txt"), "w", encoding="utf-8") as f:
		f.writelines(ci_config)
	with open(os.path.join(TEST_DEPLOY, "config", "dbconfig.txt"), "w", encoding="utf-8") as f:
		f.write("# local_ci: testy bez bazy danych\n")


def step_tests(r):
	"""Testy jednostkowe jak w run_all_tests: build z -DCIBUILDING, osobna kopia świata, wynik z clean_run.lk i tests.log."""
	code, base, out = r.compile_copy("tests", ["CIBUILDING"])
	if code:
		r.cleanup_copy(base)
		return code, out
	try:
		deploy_tests(base)
	finally:
		r.cleanup_copy(base)
	results = os.path.join(TEST_DEPLOY, "data", "unit_tests.json")
	log_dir = "ci"
	log_path = os.path.join(TEST_DEPLOY, "data", "logs", log_dir)
	dd = os.path.join(r.byond, "bin", "dd.exe")
	started = time.time()
	proc = subprocess.Popen([dd, base + ".dmb", "-close", "-trusted", "-verbose", "-params", f"log-directory={log_dir}"], cwd=TEST_DEPLOY, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
	clean_run = os.path.join(log_path, "clean_run.lk")
	runtime_log = os.path.join(log_path, "runtime.log")
	shutdown_seen = None
	try:
		while proc.poll() is None:
			if time.time() - started > r.args.limit_testow:
				proc.kill()
				return 1, f"Testy nie skończyły się w {r.args.limit_testow} s, Dream Daemon zabity."
			# 516 potrafi wisieć po zamknięciu świata (zob. tools/ci/run_server.sh): po „Shutdown complete” czekamy 15 s i zabijamy
			if shutdown_seen is None and os.path.exists(runtime_log):
				with open(runtime_log, encoding="utf-8", errors="replace") as f:
					if "Shutdown complete" in f.read():
						shutdown_seen = time.time()
			if shutdown_seen and time.time() - shutdown_seen > 15:
				proc.kill()
				break
			time.sleep(2)
	finally:
		if proc.poll() is None:
			proc.kill()
		time.sleep(2)

	# Wynik jak w CI: clean_run.lk z „Success!” znaczy brak runtime'ów i nieudanych testów
	entries = []
	tests_log = os.path.join(log_path, "tests.log")
	if os.path.exists(tests_log):
		with open(tests_log, encoding="utf-8", errors="replace") as f:
			for line in f:
				m = re.search(r"\] (PASS|FAIL): (\S+)", line)
				if m:
					entries.append([m.group(1), m.group(2), ""])
				elif entries and "REASON" in line:
					entries[-1][2] += line.strip() + " "
	failed = [e for e in entries if e[0] == "FAIL"]
	success = os.path.exists(clean_run) and "Success" in open(clean_run, encoding="utf-8", errors="replace").read()
	lines = [f"Testów: {len(entries)}, nieudanych: {len(failed)}, clean_run.lk: {'Success' if success else 'brak'} (logi: {os.path.relpath(log_path, REPO)})"]
	lines += [f"- {name}: {reason[:600]}" for _, name, reason in failed]
	code = 0 if success and not failed else 1
	# unit_tests.json zapisuje RunUnitTests() dopiero po ostatnim teście: bez niego przebieg urwał się w połowie,
	# nawet gdy clean_run.lk mówi „Success!” (CI uznaje taki przebieg za udany)
	if not os.path.exists(results):
		last = entries[-1][1] if entries else "żaden"
		lines.append(f"Przebieg urwany: brak data/unit_tests.json, ostatni zakończony test: {last}. Kolejne testy się nie wykonały.")
		code = 1
	return code, "\n".join(lines)


STEPS = [
	("filedirs", "Zaznaczone foldery w .dme", step_filedirs, "base"),
	("changelog", "Changelog", step_changelog, "base"),
	("json", "Poprawność plików JSON", step_json, "base"),
	("grep", "check_grep.sh", step_grep, "base"),
	("altclick", "Alt+klik a RPG Loot", step_altclick, "base"),
	("mapconn", "Rury i kable na mapach", step_mapconn, "base"),
	("dmi", "Testy biblioteki dmi", step_dmi, "base"),
	("mapmerge", "Testy mapmerge2", step_mapmerge, "base"),
	("i18n", "Teksty bez angielskiego (ostrzeżenia)", step_i18n, "base"),
	("tgui", "TGUI: lint, testy, build", step_tgui, "tgui"),
	("dm", "Kompilacja DM", step_dm, "base"),
	("dreamchecker", "dreamchecker", step_dreamchecker, "base"),
	("maps", "Wszystkie mapy (-DALL_MAPS)", step_maps, "full"),
	("tests", "Testy jednostkowe", step_tests, "full"),
]
WARN_ONLY = {"i18n"}


def main():
	if hasattr(sys.stdout, "reconfigure"):
		sys.stdout.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Lokalne CI Aquili (kroki jak w continuous_integration.yml).")
	parser.add_argument("--szybko", action="store_true", help="pomiń TGUI")
	parser.add_argument("--pelne", action="store_true", help="dodaj wszystkie mapy i testy jednostkowe")
	parser.add_argument("--tylko", help="tylko te kroki, po przecinku")
	parser.add_argument("--pomin", help="pomiń te kroki, po przecinku")
	parser.add_argument("--lista", action="store_true", help="pokaż kroki i wyjdź")
	parser.add_argument("--baza", help="gałąź bazowa dla sprawdzenia tłumaczeń (domyślnie master z remote'u wskazującego na aq33/AquilaStation)")
	parser.add_argument("--byond", help="folder BYOND (domyślnie wersja z dependencies.sh)")
	parser.add_argument("--limit-testow", type=int, default=3600, help="limit czasu testów jednostkowych w sekundach")
	args = parser.parse_args()

	if args.lista:
		for key, title, _, group in STEPS:
			print(f"{key:13} {title} [{ {'base': 'domyślny', 'tgui': 'domyślny, bez --szybko', 'full': 'tylko --pelne'}[group] }]")
		return 0

	only = set(args.tylko.split(",")) if args.tylko else None
	skip = set(args.pomin.split(",")) if args.pomin else set()
	known = {s[0] for s in STEPS}
	for name in (only or set()) | skip:
		if name not in known:
			raise SystemExit(f"Nieznany krok: {name}. Lista: --lista")

	runner = Runner(args)
	failed = []
	for key, title, func, group in STEPS:
		if only is not None:
			if key not in only:
				continue
		elif key in skip or (group == "tgui" and args.szybko) or (group == "full" and not args.pelne):
			continue
		print(f"== {title} ({key})", flush=True)
		started = time.time()
		crashed = False
		try:
			code, out = func(runner)
		except subprocess.TimeoutExpired:
			code, out, crashed = 1, "Przekroczony limit czasu.", True
		except (Exception, SystemExit) as exc:  # krok nie może przerwać reszty
			code, out, crashed = 1, f"{type(exc).__name__}: {exc}", True
		elapsed = time.time() - started
		# awaria samego kroku (brak narzędzia, gałęzi) to zawsze błąd, także w krokach tylko ostrzegających
		if code and key in WARN_ONLY and not crashed:
			status = "OSTRZEŻENIE"
		elif code:
			status = "BŁĄD"
			failed.append(key)
		else:
			status = "OK"
		print(f"   {status} ({elapsed:.0f} s)")
		if code or args.tylko:
			text = out.strip()
			if text:
				print("   " + "\n   ".join(text.splitlines()[-80:]))
		runner.results.append((key, status, elapsed))

	print()
	print("Podsumowanie: " + ", ".join(f"{k} {s}" for k, s, _ in runner.results))
	if failed:
		print("Nie przeszło: " + ", ".join(failed))
	return 1 if failed else 0


if __name__ == "__main__":
	sys.exit(main())
