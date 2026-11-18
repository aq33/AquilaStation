#!/usr/bin/env python3
"""Ostrzega, gdy testy jednostkowe zaczynają wydłużać CI. Nie blokuje PR-a: kod wyjścia 1 znaczy „są ostrzeżenia”.

Przebieg CI ma trwać 6–7 minut (październik–listopad 2026: z 3,6 do 21 min, bo każdy PR dokładał testy po trochu).
Skrypt czyta czasy z logu testów jednej części i ostrzega, gdy:
  - test trwa dłużej niż TEST_LIMIT sekund i nie ma go na liście znanych wolnych testów
    (aquila/code/modules/unit_tests/_unit_test_weights.dm) albo trwa ponad SLOWDOWN razy dłużej, niż tam zapisano,
  - wszystkie testy części trwają razem dłużej niż PART_LIMIT sekund.

Znany wolny test przestaje ostrzegać po świadomym odświeżeniu listy: python tools/ci/unit_test_weights.py --run <id>.

Użycie:
    python tools/ci/check_test_times.py ci_test/data/logs/ci/tests.log        # w jobie CI: adnotacje ::warning
    python tools/ci/check_test_times.py tools/bootstrap/.cache/ci_test_1/data/logs/ci/tests.log
"""

import argparse
import os
import re
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
WEIGHTS = os.path.join(REPO, "aquila", "code", "modules", "unit_tests", "_unit_test_weights.dm")
# Nowy test dłuższy niż tyle sekund dostaje ostrzeżenie
TEST_LIMIT = 10
# Znany wolny test dostaje ostrzeżenie, gdy trwa tyle razy dłużej, niż zapisano (runnery różnią się szybkością)
SLOWDOWN = 1.5
# Suma czasów testów jednej części w sekundach (listopad 2026: 115–177 s przy czterech częściach)
PART_LIMIT = 240
LINE = re.compile(r"(?:PASS|FAIL): (/datum/unit_test/\S+) ([\d.]+)s")
WEIGHT = re.compile(r"^\s*\"(/datum/unit_test/[^\"]+)\" = ([\d.]+),")


def read_weights(path):
	weights = {}
	if os.path.exists(path):
		with open(path, encoding="utf-8") as handle:
			for line in handle:
				match = WEIGHT.match(line)
				if match:
					weights[match.group(1)] = float(match.group(2))
	return weights


def check(durations, weights, test_limit=TEST_LIMIT, slowdown=SLOWDOWN, part_limit=PART_LIMIT):
	"""Lista ostrzeżeń (tytuł, treść) dla czasów testów jednej części."""
	warnings = []
	for test, seconds in sorted(durations.items(), key=lambda item: -item[1]):
		if seconds <= test_limit:
			continue
		known = weights.get(test)
		name = test.rsplit("/", 1)[-1]
		if known is None:
			warnings.append(("Wolny test", f"{name} trwał {seconds:.0f} s (limit dla nowego testu: {test_limit} s). Skróć go: wspólna scena dla kilku sprawdzeń, bez czekania na prawdziwy czas. Jeśli musi tyle trwać, dopisz go do listy przez tools/ci/unit_test_weights.py."))
		elif seconds > known * slowdown:
			warnings.append(("Test zwolnił", f"{name} trwał {seconds:.0f} s, a na liście wag ma {known:g} s (ostrzeżenie od {known * slowdown:.0f} s)."))
	total = sum(durations.values())
	if total > part_limit:
		warnings.append(("Długa część testów", f"Testy tej części trwały razem {total:.0f} s (limit {part_limit} s). Odśwież wagi podziału (tools/ci/unit_test_weights.py) albo dopisz część do matrix.shard w continuous_integration.yml."))
	return warnings


def main():
	parser = argparse.ArgumentParser(description="Ostrzeżenia o wolnych testach jednostkowych.")
	parser.add_argument("logs", nargs="+", help="log testów jednej części (tests.log)")
	parser.add_argument("--weights", default=WEIGHTS)
	args = parser.parse_args()
	if hasattr(sys.stdout, "reconfigure"):
		sys.stdout.reconfigure(encoding="utf-8", errors="replace")

	weights = read_weights(args.weights)
	in_ci = os.environ.get("GITHUB_ACTIONS") == "true"
	found = False
	for path in args.logs:
		if not os.path.exists(path):
			continue  # kompilacja nie doszła do testów: nie ma czego mierzyć
		durations = {}
		with open(path, encoding="utf-8", errors="replace") as handle:
			for test, seconds in LINE.findall(handle.read()):
				durations[test] = max(durations.get(test, 0), float(seconds))
		warnings = check(durations, weights)
		found = found or bool(warnings)
		label = f"{os.path.relpath(path)}: " if len(args.logs) > 1 else ""
		for title, text in warnings:
			print(f"::warning title={title}::{text}" if in_ci else f"{label}{title}: {text}")
		summary = os.environ.get("GITHUB_STEP_SUMMARY")
		if in_ci and summary and durations:
			slowest = sorted(durations.items(), key=lambda item: -item[1])[:8]
			with open(summary, "a", encoding="utf-8") as handle:
				handle.write(f"Testów: {len(durations)}, razem {sum(durations.values()):.0f} s (limit części {PART_LIMIT} s)\n\n")
				handle.write("| Najwolniejsze testy | s |\n|---|---|\n")
				handle.writelines(f"| {test.rsplit('/', 1)[-1]} | {seconds:.1f} |\n" for test, seconds in slowest)
	return 1 if found else 0


if __name__ == "__main__":
	sys.exit(main())
