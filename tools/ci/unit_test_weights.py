#!/usr/bin/env python3
"""Wagi testów dla podziału na części CI (aquila/code/modules/unit_tests/_unit_test_weights.dm).

Części testów mają trwać podobnie długo, a nie mieć po tyle samo testów, więc podział potrzebuje czasów
najwolniejszych testów. Ten skrypt bierze je z logów przebiegu i nadpisuje plik z wagami.

Użycie (z katalogu repo):
    python tools/ci/unit_test_weights.py --run 44193970512      # przebieg CI z GitHuba (wymaga gh)
    python tools/ci/unit_test_weights.py sciezka/do/tests.log   # logi lokalne (data/logs/ci/tests.log), można kilka

Uruchom po dodaniu albo przyspieszeniu wolnych testów (zielony przebieg mastera), gdy części rozjadą się czasowo.
"""

import argparse
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
TARGET = os.path.join(REPO, "aquila", "code", "modules", "unit_tests", "_unit_test_weights.dm")
# Krótsze testy liczą się w DM jako AQUILA_UNIT_TEST_DEFAULT_WEIGHT
THRESHOLD = 1.0
LINE = re.compile(r"(?:PASS|FAIL): (/datum/unit_test/\S+) ([\d.]+)s")


def main():
	parser = argparse.ArgumentParser(description="Zapisuje czasy najwolniejszych testów do pliku z wagami podziału CI.")
	parser.add_argument("logs", nargs="*", help="pliki z liniami PASS/FAIL testów")
	parser.add_argument("--run", help="numer przebiegu CI na GitHubie")
	parser.add_argument("--repo", default="aq33/AquilaStation")
	args = parser.parse_args()

	texts = []
	if args.run:
		result = subprocess.run(["gh", "run", "view", args.run, "--repo", args.repo, "--log"], capture_output=True)
		if result.returncode:
			raise SystemExit(result.stderr.decode("utf-8", "replace"))
		texts.append(result.stdout.decode("utf-8", "replace"))
	for path in args.logs:
		with open(path, encoding="utf-8", errors="replace") as handle:
			texts.append(handle.read())
	if not texts:
		parser.error("podaj --run albo pliki logów")

	durations = {}
	for text in texts:
		for test, seconds in LINE.findall(text):
			durations[test] = max(durations.get(test, 0), float(seconds))
	if not durations:
		raise SystemExit("W logach nie ma linii PASS/FAIL testów.")

	slow = sorted(((seconds, test) for test, seconds in durations.items() if seconds >= THRESHOLD), reverse=True)
	rest = [seconds for seconds in durations.values() if seconds < THRESHOLD]
	lines = [
		"// Plik generowany przez tools/ci/unit_test_weights.py z logów przebiegu testów. Nie edytuj ręcznie.",
		"",
		f"/// Czas w sekundach testów trwających co najmniej {THRESHOLD:g} s. Klucze to teksty, żeby usunięcie testu nie psuło kompilacji",
		"/proc/aquila_unit_test_weights()",
		"\treturn list(",
	]
	lines += [f"\t\t\"{test}\" = {round(seconds, 1):g}," for seconds, test in slow]
	lines += ["\t)", ""]
	with open(TARGET, "w", encoding="utf-8", newline="\n") as handle:
		handle.write("\n".join(lines))

	print(f"{len(durations)} testów, razem {sum(durations.values()):.0f} s; {len(slow)} z wagą, razem {sum(s for s, _ in slow):.0f} s")
	if rest:
		print(f"Pozostałe {len(rest)}: średnio {sum(rest) / len(rest):.2f} s (AQUILA_UNIT_TEST_DEFAULT_WEIGHT w _unit_test_shards.dm)")
	return 0


if __name__ == "__main__":
	sys.exit(main())
