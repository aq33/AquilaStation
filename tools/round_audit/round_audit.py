"""Audyt logów rundy testowej: runtime'y, ostrzeżenia, qdel, wydajność, czasy startu, błędy map i configu.

Użycie (z katalogu repo):
    python tools/round_audit/round_audit.py                      # najnowsza runda z data/logs
    python tools/round_audit/round_audit.py data/logs/2026/11/12/round-21.33.49
    python tools/round_audit/round_audit.py --porownaj poprzednia  # różnica względem poprzedniej rundy
    python tools/round_audit/round_audit.py --porownaj <folder> --out raport/audyt_rundy_01.md
    python tools/round_audit/round_audit.py --ci                 # ostatni przebieg testów z tools/local_ci

Raport jest po polsku, w Markdownie. Kod wyjścia 1, gdy są nowe runtime'y względem porównywanej rundy
(albo jakiekolwiek runtime'y bez porównania), więc skrypt nadaje się też do pętli testowych.
"""

import argparse
import csv
import glob
import os
import re
import statistics
import sys
from collections import OrderedDict

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
TIMESTAMP = re.compile(r"^\[(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d(?:\.\d+)?)\] ?(.*)$")


def read_entries(path):
	"""Wpisy WRITE_LOG: linia z [czasem], a dalsze linie wpisu zaczynają się od ' - '."""
	if not os.path.exists(path):
		return []
	entries = []
	with open(path, encoding="utf-8", errors="replace") as f:
		for raw in f:
			line = raw.rstrip("\n").rstrip("\r")
			m = TIMESTAMP.match(line)
			if m:
				entries.append([m.group(1), m.group(2), []])
			elif entries and line.startswith(" - "):
				entries[-1][2].append(line[3:])
			elif entries:
				entries[-1][2].append(line)
	return entries


def normalize(text):
	text = re.sub(r"\[0x[0-9a-fA-F]+\]", "[ref]", text)
	text = re.sub(r"0x[0-9a-fA-F]{5,}", "0x…", text)
	return re.sub(r"(?<![\w/])-?\d+(?:\.\d+)?(?![\w/])", "N", text)


def parse_runtimes(entries):
	runtimes = OrderedDict()
	for stamp, head, rest in entries:
		if not head.startswith("runtime error: "):
			continue
		message = head[len("runtime error: "):].strip()
		proc = source = src = ""
		stack = []
		in_stack = False
		for line in rest:
			s = line.strip()
			if s.startswith("proc name:"):
				proc = s[len("proc name:"):].strip()
			elif s.startswith("source file:"):
				source = s[len("source file:"):].strip()
			elif s.startswith("src:"):
				src = s[len("src:"):].strip()
			elif s.startswith("call stack:"):
				in_stack = True
			elif in_stack and s and not s.startswith("(This error"):
				stack.append(s)
		caller = ""
		if source.startswith("code/__HELPERS/stack_trace.dm") and len(stack) > 1:
			# stack_trace() zawsze wskazuje na siebie, ważne jest, kto go wywołał
			caller = stack[1]
		key = (source, normalize(message))
		item = runtimes.setdefault(key, {"source": source, "message": message, "proc": proc, "src": src, "stack": stack, "caller": caller, "count": 0, "first": stamp, "last": stamp})
		item["count"] += 1
		item["last"] = stamp
	return runtimes


def parse_prefixed(entries, prefix):
	"""Wpisy z danym prefiksem; różniące się tylko ścieżką typu albo liczbą liczą się razem."""
	found = OrderedDict()
	for _, head, rest in entries:
		if head.startswith(prefix):
			text = head[len(prefix):].strip()
			key = re.sub(r"/(?:datum|obj|mob|turf|area|atom)[\w/]*", "/TYP", normalize(text))
			item = found.setdefault(key, {"text": text, "count": 0})
			item["count"] += 1
	return found


def parse_inits(entries):
	inits = []
	total = None
	for _, head, _ in entries:
		m = re.match(r"Initialized (.+?) subsystem within ([\d.]+) seconds?!", head)
		if m:
			inits.append((float(m.group(2)), m.group(1)))
			continue
		m = re.match(r"Initializations complete within ([\d.]+) seconds?!", head)
		if m:
			total = float(m.group(1))
	return sorted(inits, reverse=True), total


def parse_qdel(path):
	"""qdel.log: 'Path: /typ' i pod nim ' - \\tPole: wartość'."""
	items = OrderedDict()
	current = None
	if not os.path.exists(path):
		return items
	with open(path, encoding="utf-8", errors="replace") as f:
		for raw in f:
			line = raw.rstrip("\r\n")
			m = TIMESTAMP.match(line)
			body = m.group(2) if m else (line[3:] if line.startswith(" - ") else line)
			body = body.strip()
			if body.startswith("QDEL: "):
				body = body[len("QDEL: "):]
			if body.startswith("Path: "):
				current = items.setdefault(body[len("Path: "):].strip(), {})
			elif current is not None and body.startswith("Total Hard Deletes"):
				current["Total Hard Deletes"] = body[len("Total Hard Deletes"):].strip()
			elif current is not None and body == "SUSPENDED FOR LAG":
				current["SUSPENDED FOR LAG"] = "tak"
			elif current is not None and ":" in body:
				key, value = body.split(":", 1)
				current[key.strip()] = value.strip()
	return items


def number(value):
	m = re.match(r"-?[\d.]+", value or "")
	return float(m.group(0)) if m else 0.0


def parse_perf(round_dir):
	files = glob.glob(os.path.join(round_dir, "perf-*.csv"))
	if not files:
		return None
	with open(files[0], encoding="utf-8", errors="replace") as f:
		rows = list(csv.DictReader(f))
	rows = [r for r in rows if number(r.get("time")) > 0]
	if not rows:
		return None

	def column(name):
		return [number(r.get(name)) for r in rows if r.get(name) not in (None, "")]

	def p95(values):
		values = sorted(values)
		return values[min(len(values) - 1, int(len(values) * 0.95))] if values else 0

	out = {"samples": len(rows), "minutes": (number(rows[-1]["time"]) - number(rows[0]["time"])) / 600}
	for name in ("tidi", "maptick", "num_timers", "players", "send_maps", "air_turf_cost", "air_eg_cost", "air_pipenets_cost", "air_rebuilds_cost"):
		values = column(name)
		if values:
			out[name] = (statistics.mean(values), p95(values), max(values))
	return out


def log_lines(path, skip=("Loading config file", "Starting up round ID", "-------------------------", "Loaded default arena")):
	result = []
	for _, head, rest in read_entries(path):
		if head and not any(head.startswith(s) or s in head for s in skip):
			result.append(head)
	return result


def find_rounds(logs_root):
	# data/logs/RRRR/MM/DD/round-GG.MM.SS: kolejność nazw to kolejność czasu (mtime folderu bywa nadpisany)
	return sorted(os.path.abspath(p) for p in glob.glob(os.path.join(logs_root, "*", "*", "*", "round-*")))


def audit(round_dir):
	runtime_entries = read_entries(os.path.join(round_dir, "runtime.log"))
	inits, total_init = parse_inits(runtime_entries)
	return {
		"dir": round_dir,
		"runtimes": parse_runtimes(runtime_entries),
		"warnings": parse_prefixed(runtime_entries, "## WARNING:"),
		"uncaught": parse_prefixed(runtime_entries, "uncaught runtime error:"),
		"testing": parse_prefixed(runtime_entries, "## TESTING:"),
		"inits": inits,
		"total_init": total_init,
		"qdel": parse_qdel(os.path.join(round_dir, "qdel.log")),
		"perf": parse_perf(round_dir),
		"map_errors": log_lines(os.path.join(round_dir, "map_errors.log")),
		"config_errors": log_lines(os.path.join(round_dir, "config_error.log")),
		"tests": [head for _, head, _ in read_entries(os.path.join(round_dir, "tests.log")) if head.startswith(("FAIL", "PASS", "SKIP"))],
		"clean_run": os.path.exists(os.path.join(round_dir, "clean_run.lk")),
	}


def rel(path):
	try:
		return os.path.relpath(path)
	except ValueError:
		return path


def location_link(source):
	m = re.match(r"(.+?),(\d+)$", source)
	return f"[{source}]({m.group(1)}:{m.group(2)})" if m else (source or "?")


def render(data, previous, top):
	lines = [f"# Audyt rundy `{rel(data['dir'])}`", ""]
	runtimes = data["runtimes"]
	new_keys = set(runtimes) - set(previous["runtimes"]) if previous else set(runtimes)
	gone = [previous["runtimes"][k] for k in previous["runtimes"] if k not in runtimes] if previous else []

	total = sum(r["count"] for r in runtimes.values())
	summary = [
		f"- Runtime'y: **{total}** wystąpień, **{len(runtimes)}** różnych" + (f", nowych względem `{rel(previous['dir'])}`: **{len(new_keys)}**, zniknęło: **{len(gone)}**" if previous else ""),
		f"- „uncaught runtime error” (błąd poza obsługą runtime'ów, zwykle przy zamykaniu albo w world/Error): {sum(u['count'] for u in data['uncaught'].values())}",
		f"- Ostrzeżenia `## WARNING`: {sum(w['count'] for w in data['warnings'].values())} ({len(data['warnings'])} różnych)",
		f"- qdel: twarde usunięcia w {sum(1 for v in data['qdel'].values() if number(v.get('Total Hard Deletes')) > 0)} typach, nieudane w {sum(1 for v in data['qdel'].values() if number(v.get('Failures')) > 0)}, bez wskazówki w {sum(1 for v in data['qdel'].values() if 'No hint' in v)}, spanie w Destroy w {sum(1 for v in data['qdel'].values() if 'Sleeps' in v)}",
		f"- Błędy map: {len(data['map_errors'])}, błędy configu: {len(data['config_errors'])}",
		f"- Start: {data['total_init']:.1f} s" if data["total_init"] else "- Start: brak wpisu „Initializations complete” (świat nie wystartował do końca?)",
		f"- Czyste zamknięcie (clean_run.lk): {'tak' if data['clean_run'] else 'nie'}",
	]
	if data["tests"]:
		fails = [t for t in data["tests"] if t.startswith("FAIL")]
		summary.append(f"- Testy jednostkowe: {len(data['tests'])}, nieudane: {len(fails)}")
	lines += ["## Podsumowanie", ""] + summary + [""]

	if runtimes:
		lines += ["## Runtime'y", "", "Od najczęstszych. ★ = nowy względem porównywanej rundy." if previous else "Od najczęstszych.", ""]
		for key, r in sorted(runtimes.items(), key=lambda kv: -kv[1]["count"])[:top]:
			star = "★ " if previous and key in new_keys else ""
			lines.append(f"### {star}{r['count']}× {r['message']}")
			lines.append("")
			lines.append(f"- Miejsce: {location_link(r['source'])}, procka `{r['proc']}`")
			if r["caller"]:
				lines.append(f"- Wywołał stack_trace(): `{r['caller']}`")
			if r["src"]:
				lines.append(f"- src: `{r['src']}`")
			lines.append(f"- Pierwszy: {r['first']}, ostatni: {r['last']}")
			if previous and key in previous["runtimes"]:
				lines.append(f"- W porównywanej rundzie: {previous['runtimes'][key]['count']}×")
			if r["stack"]:
				lines += ["", "```", *r["stack"][:12], "```"]
			lines.append("")
		if len(runtimes) > top:
			lines += [f"…i {len(runtimes) - top} innych (zwiększ --top).", ""]
	if gone:
		lines += ["## Runtime'y, których już nie ma", ""] + [f"- {g['count']}× {g['message']} ({location_link(g['source'])})" for g in gone] + [""]

	if data["warnings"]:
		lines += ["## Ostrzeżenia `## WARNING`", ""]
		lines += [f"- {w['count']}× {w['text']}" + (" (i podobne, różniące się typem)" if w["count"] > 1 else "") for w in sorted(data["warnings"].values(), key=lambda w: -w["count"])[:top]] + [""]
	if data["uncaught"]:
		lines += ["## „uncaught runtime error”", ""] + [f"- {u['count']}× {u['text'] or '(bez treści)'}" for u in data["uncaught"].values()] + [""]

	qdel = data["qdel"]
	problems = [(path, v) for path, v in qdel.items() if number(v.get("Total Hard Deletes")) > 0 or number(v.get("Failures")) > 0 or "No hint" in v or "Sleeps" in v or "SUSPENDED FOR LAG" in v]
	if problems:
		lines += ["## qdel: problemy", "", "| Typ | Twarde usunięcia | Nieudane | Bez wskazówki | Inne |", "|---|---|---|---|---|"]
		for path, v in sorted(problems, key=lambda pv: (-number(pv[1].get("Total Hard Deletes")), -number(pv[1].get("Failures")))):
			other = ", ".join(f"{k}: {val}" for k, val in v.items() if k not in ("qdel() Count", "Destroy() Cost", "Total Hard Deletes", "Failures", "No hint"))
			lines.append(f"| `{path}` | {v.get('Total Hard Deletes', '')} | {v.get('Failures', '')} | {v.get('No hint', '')} | {other} |")
		lines.append("")
	if qdel:
		costly = sorted(qdel.items(), key=lambda pv: -number(pv[1].get("Destroy() Cost")))[:10]
		lines += ["## qdel: najdroższe Destroy()", "", "| Typ | Liczba qdel | Łączny koszt |", "|---|---|---|"]
		lines += [f"| `{path}` | {v.get('qdel() Count', '')} | {v.get('Destroy() Cost', '')} |" for path, v in costly] + [""]

	perf = data["perf"]
	if perf:
		lines += [f"## Wydajność ({perf['samples']} próbek, {perf['minutes']:.1f} min)", "", "| Miara | Średnio | p95 | Maks. |", "|---|---|---|---|"]
		names = {"tidi": "Time dilation (%)", "maptick": "Maptick (%)", "num_timers": "Timery", "players": "Gracze", "send_maps": "SendMaps (ms)", "air_turf_cost": "Atmos: kafelki (ms)", "air_eg_cost": "Atmos: grupy (ms)", "air_pipenets_cost": "Atmos: rury (ms)", "air_rebuilds_cost": "Atmos: przebudowy (ms)"}
		for key, title in names.items():
			if key in perf:
				avg, p, mx = perf[key]
				lines.append(f"| {title} | {avg:.2f} | {p:.2f} | {mx:.2f} |")
		if previous and previous["perf"]:
			lines.append("")
			lines.append("Porównanie średnich: " + ", ".join(f"{names[k]} {previous['perf'][k][0]:.2f} → {perf[k][0]:.2f}" for k in ("tidi", "maptick", "send_maps") if k in perf and k in previous["perf"]))
		lines.append("")

	if data["inits"]:
		lines += ["## Najwolniejsze podsystemy przy starcie", "", "| Podsystem | Sekundy |", "|---|---|"]
		lines += [f"| {name} | {sec:.2f} |" for sec, name in data["inits"][:10]] + [""]

	for title, key in (("Błędy map", "map_errors"), ("Błędy configu", "config_errors")):
		if data[key]:
			lines += [f"## {title}", ""] + [f"- {line}" for line in data[key][:top]] + [""]
	fails = [t for t in data["tests"] if t.startswith("FAIL")]
	if fails:
		lines += ["## Nieudane testy", ""] + [f"- {t}" for t in fails] + [""]
	return "\n".join(lines), new_keys


def main():
	for stream in (sys.stdout, sys.stderr):
		if hasattr(stream, "reconfigure"):
			stream.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Audyt logów rundy testowej.")
	parser.add_argument("runda", nargs="?", help="folder rundy (domyślnie najnowszy w data/logs)")
	parser.add_argument("--logi", default=os.path.join("data", "logs"), help="folder z logami (domyślnie data/logs w bieżącym katalogu)")
	parser.add_argument("--porownaj", help="folder rundy do porównania albo „poprzednia”")
	parser.add_argument("--top", type=int, default=30, help="ile pozycji pokazać w listach (domyślnie 30)")
	parser.add_argument("--out", help="zapisz raport do pliku zamiast wypisywać")
	parser.add_argument("--ci", action="store_true", help="ostatni przebieg testów lokalnego CI (tools/local_ci, osobna kopia świata)")
	args = parser.parse_args()

	rounds = [r for r in find_rounds(args.logi) if os.path.exists(os.path.join(r, "runtime.log"))]
	if args.ci:
		# testy local_ci działają w kopii świata, z log-directory=ci (jak run_server.sh), poza data/logs/RRRR/MM/DD
		args.runda = args.runda or os.path.join(REPO, "tools", "bootstrap", ".cache", "ci_test", "data", "logs", "ci")
	round_dir = os.path.abspath(args.runda) if args.runda else (rounds[-1] if rounds else None)
	if not round_dir or not os.path.isdir(round_dir):
		raise SystemExit(f"Nie znalazłem rundy (szukałem w {args.logi}).")
	previous_dir = None
	if args.porownaj == "poprzednia":
		older = [r for r in rounds if r < round_dir]
		previous_dir = older[-1] if older else None
		if not previous_dir:
			print("Brak wcześniejszej rundy do porównania.", file=sys.stderr)
	elif args.porownaj:
		previous_dir = os.path.abspath(args.porownaj)

	data = audit(round_dir)
	previous = audit(previous_dir) if previous_dir else None
	report, new_keys = render(data, previous, args.top)
	if args.out:
		os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
		with open(args.out, "w", encoding="utf-8") as f:
			f.write(report + "\n")
		print(f"Raport zapisany: {args.out}")
	else:
		print(report)
	return 1 if new_keys else 0


if __name__ == "__main__":
	sys.exit(main())
