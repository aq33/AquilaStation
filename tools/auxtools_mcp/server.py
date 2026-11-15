"""Serwer MCP (stdio) nad debuggerem auxtools 3: świat BYOND jako narzędzia dla Claude Code.

Zamiast wywołań CLI z MSYS_NO_PATHCONV i ręcznym --pid agent dostaje narzędzia:
  world_launch   start świata pod debuggerem (wolny port, flagi -D, opcjonalnie od razu runda)
  world_list     światy z załadowanym debuggerem
  world_eval     wyrażenie albo ciało procki DM (opcjonalnie --spawn --wait, czyli z sleep())
  world_cli      dowolna inna komenda auxtools (status, stack, vars, trace, pause, continue, proc, log...)
  world_stop     zatrzymanie świata (tylko po PID, który ten serwer wystartował, chyba że force)
  tgui_data      ui_data() i ui_static_data() obiektu dla danego moba, do podglądu okien (tools/tgui_preview)

Rejestracja: plik .mcp.json w katalogu repo (serwer „aquila-world”). Protokół: JSON-RPC 2.0, jedna wiadomość na linię.
Bez zależności poza biblioteką standardową, więc działa w każdym Pythonie 3.10+.
"""

import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(REPO, "tools", "scenario"))
import scenario  # noqa: E402

PROTOCOL = "2025-06-18"
STARTED = set()


def text(value):
	return {"content": [{"type": "text", "text": value if isinstance(value, str) else json.dumps(value, ensure_ascii=False, indent=1)}]}


def cli():
	return scenario.auxtools_cli()


def run(args, timeout=120, cwd=None):
	proc = subprocess.run([cli(), *args], capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout, cwd=cwd or os.getcwd(), env=dict(os.environ, MSYS_NO_PATHCONV="1"))
	out = proc.stdout.strip()
	if proc.stderr.strip():
		out += ("\n" if out else "") + proc.stderr.strip()
	return proc.returncode, out


def world_launch(dmb="nsv13.dmb", defines=None, round=False, folder=None, limit=600):
	folder = folder or os.getcwd()
	byond = scenario.find_byond(None)
	port = scenario.free_port()
	launch = ["launch", dmb, "--detach", "--json", "--server", "dd", "--port", str(port), "--byond", byond]
	for d in ["CBT", *[d for d in (defines or []) if d != "CBT"]]:
		launch += ["-D", d]
	code, out = run(launch, timeout=300, cwd=folder)
	if code:
		raise RuntimeError("auxtools launch: " + out)
	info = json.loads(out.splitlines()[0])
	STARTED.add(info["pid"])
	world = scenario.World(cli(), info["pid"])
	started = time.time()
	while time.time() - started < limit:
		if world.eval("SSticker && SSticker.current_state >= 1") in (1, True):
			break
		time.sleep(2)
	else:
		return {"pid": info["pid"], "port": port, "log": info.get("log"), "state": "świat nie doszedł do lobby w limicie"}
	if round:
		world.eval("SSticker.start_immediately = TRUE")
		while time.time() - started < limit and world.eval("SSticker.current_state == 3") not in (1, True):
			time.sleep(2)
	# Klient do testu w grze: python tools/playtest/ds.py start --port <port>
	return {"pid": info["pid"], "port": port, "log": info.get("log"), "state": "runda trwa" if round else "lobby"}


def world_eval(pid, code, spawn=False, timeout=120, depth=2):
	args = ["--pid", str(pid), "eval", "-", "--json", "--depth", str(depth)]
	if spawn:
		args += ["--spawn", "--wait", "--timeout", str(timeout)]
	proc = subprocess.run([cli(), *args], input=code, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout + 60, env=dict(os.environ, MSYS_NO_PATHCONV="1"))
	out = proc.stdout.strip()
	try:
		value = json.loads(out)
	except ValueError:
		value = out
	return {"exit": proc.returncode, "value": value, "stderr": proc.stderr.strip() or None}


def world_stop(pid, force=False):
	if pid not in STARTED and not force:
		raise RuntimeError(f"PID {pid} nie był wystartowany przez ten serwer (inne sesje mają własne światy). force=true, jeśli na pewno.")
	code, out = run(["--pid", str(pid), "stop", "--kill"], timeout=90)
	STARTED.discard(pid)
	return out or f"kod {code}"


def tgui_data(pid, obj, user):
	"""obj i user to wyrażenia DM, np. locate(/obj/machinery/chem_dispenser) i GLOB.player_list[1]."""
	body = (
		f"var/datum/target = {obj}\n"
		f"var/mob/user = {user}\n"
		"if(!target) return \"brak obiektu\"\n"
		"if(!user) return \"brak moba\"\n"
		"return json_encode(list(\"ref\" = REF(target), \"type\" = \"[target.type]\", "
		"\"data\" = target.ui_data(user), \"static_data\" = target.ui_static_data(user)))"
	)
	result = world_eval(pid, body, spawn=True, timeout=60)
	value = result["value"]
	if isinstance(value, str) and value.startswith("{"):
		result["value"] = json.loads(value)
	return result


TOOLS = {
	"world_launch": (world_launch, "Startuje nsv13.dmb pod debuggerem auxtools na wolnym porcie i czeka na lobby (opcjonalnie rundę). Zwraca PID.", {
		"dmb": {"type": "string", "description": "plik .dmb (domyślnie nsv13.dmb)"},
		"defines": {"type": "array", "items": {"type": "string"}, "description": "flagi, z którymi zbudowano .dmb (CBT zawsze)"},
		"round": {"type": "boolean", "description": "od razu wystartuj rundę"},
		"folder": {"type": "string", "description": "katalog repo/worktree ze światem (domyślnie bieżący)"},
		"limit": {"type": "integer", "description": "limit czasu startu w sekundach (domyślnie 600)"},
	}, []),
	"world_list": (lambda: run(["list"])[1], "Lista światów BYOND z załadowanym debuggerem (PID, port, stan).", {}, []),
	"world_eval": (world_eval, "Wykonuje wyrażenie albo ciało procki DM w świecie. spawn=true: jako kod świata w następnym ticku, z sleep(), i czeka na wynik.", {
		"pid": {"type": "integer"},
		"code": {"type": "string", "description": "wyrażenie DM albo ciało procki (linie lub ;)"},
		"spawn": {"type": "boolean"},
		"timeout": {"type": "integer", "description": "sekundy, przy spawn"},
		"depth": {"type": "integer", "description": "głębokość rozwijania JSON (domyślnie 2)"},
	}, ["pid", "code"]),
	"world_cli": (lambda pid, args, timeout=120: run(["--pid", str(pid), *args], timeout=timeout)[1], "Inna komenda auxtools dla świata, np. [\"status\"], [\"stack\"], [\"trace\", \"/mob/proc/Life\", \"--count\", \"--for\", \"10\"].", {
		"pid": {"type": "integer"},
		"args": {"type": "array", "items": {"type": "string"}},
		"timeout": {"type": "integer"},
	}, ["pid", "args"]),
	"world_stop": (world_stop, "Zatrzymuje świat. Domyślnie tylko świat wystartowany przez ten serwer.", {
		"pid": {"type": "integer"},
		"force": {"type": "boolean", "description": "zatrzymaj też świat spoza tego serwera"},
	}, ["pid"]),
	"tgui_data": (tgui_data, "Zwraca ui_data() i ui_static_data() obiektu dla moba (wyrażenia DM), do podglądu okna w tools/tgui_preview.", {
		"pid": {"type": "integer"},
		"obj": {"type": "string", "description": "wyrażenie DM dające obiekt z oknem TGUI"},
		"user": {"type": "string", "description": "wyrażenie DM dające moba-widza"},
	}, ["pid", "obj", "user"]),
}


def handle(msg):
	method = msg.get("method")
	if method == "initialize":
		return {"protocolVersion": msg.get("params", {}).get("protocolVersion", PROTOCOL), "capabilities": {"tools": {}}, "serverInfo": {"name": "aquila-world", "version": "1.0"}}
	if method == "tools/list":
		return {"tools": [{"name": name, "description": desc, "inputSchema": {"type": "object", "properties": props, "required": req}} for name, (_, desc, props, req) in TOOLS.items()]}
	if method == "tools/call":
		params = msg["params"]
		func = TOOLS[params["name"]][0]
		try:
			return text(func(**(params.get("arguments") or {})))
		except Exception as error:  # noqa: BLE001 - błąd narzędzia wraca do agenta jako wynik
			return {"isError": True, **text(f"{type(error).__name__}: {error}")}
	if method == "ping":
		return {}
	raise KeyError(method)


def main():
	for line in sys.stdin:
		line = line.strip()
		if not line:
			continue
		msg = json.loads(line)
		if "id" not in msg:
			continue  # powiadomienia (notifications/initialized itp.)
		try:
			reply = {"jsonrpc": "2.0", "id": msg["id"], "result": handle(msg)}
		except KeyError as error:
			reply = {"jsonrpc": "2.0", "id": msg["id"], "error": {"code": -32601, "message": f"nieznana metoda {error}"}}
		sys.stdout.write(json.dumps(reply, ensure_ascii=False) + "\n")
		sys.stdout.flush()


if __name__ == "__main__":
	for stream in (sys.stdin, sys.stdout):
		stream.reconfigure(encoding="utf-8")
	main()
