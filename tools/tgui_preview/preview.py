"""Podgląd okna TGUI w zwykłej przeglądarce z danymi z działającego świata albo z pliku, bez klienta BYOND.

Strona to tgui.html w wersji, jaką składa /datum/tgui_window: helpers.min.js, bundle z tgui/public i jedna wiadomość
„update” z config/data/static_data (jak /datum/tgui/proc/get_payload). Zrzut robi Chrome albo Edge w trybie headless,
a błędy JS z okna (np. „Cannot read properties of undefined”) trafiają do pliku .log obok zrzutu.

Użycie (bundle zbudowany: tools\\build\\build.bat tgui):
  python tools/tgui_preview/preview.py ChemDispenser --data dane.json --png raport/okno.png
  python tools/tgui_preview/preview.py ChemDispenser --pid 1234 --obj "locate(/obj/machinery/chem_dispenser)" --user "GLOB.mob_list[1]" --png okno.png
dane.json: {"data": {...}, "static_data": {...}} albo same dane okna. Świat z --pid: tools/auxtools_mcp (world_launch).
Ikony ze spritesheetów (asset cache) nie są ładowane, więc w podglądzie ich brak; tekst, układ i błędy są prawdziwe.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))

BROWSERS = [
	r"C:\Program Files\Google\Chrome\Application\chrome.exe",
	r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
	"google-chrome",
	"chromium",
]

# Błędy JS z okna: zapis do <title>, bo headless --dump-dom pozwala je odczytać bez protokołu debugowania
ERROR_HOOK = """
<script>
window.__previewErrors__ = [];
window.addEventListener('error', function (e) {
  var text = String(e.message) + (e.error && e.error.stack ? '\\n' + e.error.stack : '');
  window.__previewErrors__.push(text);
  if (window.parent !== window) { window.parent.postMessage({ previewError: text }, '*'); }
});
</script>
"""

# Strona zewnętrzna: okno w iframe o dokładnym rozmiarze (headless Chrome ma minimum 500 px szerokości
# i wlicza ramkę do wysokości), błędy z iframe w <pre> pod nim, czytane przez --dump-dom
OUTER = """<!doctype html><html><head><meta charset="utf-8"></head>
<body style="margin:0;background:#000">
<iframe src="{inner}" style="position:absolute;left:0;top:0;width:{w}px;height:{h}px;border:0"></iframe>
<pre id="preview-errors" style="position:absolute;left:0;top:{below}px;color:#f55;font-size:10px;margin:0"></pre>
<script>
window.addEventListener('message', function (e) {{
  if (e.data && e.data.previewError) {{
    var log = document.getElementById('preview-errors');
    log.textContent += (log.textContent ? '\\n\\n' : '') + e.data.previewError;
  }}
}});
</script>
</body></html>
"""


def build_page(interface, payload, public, size, title):
	read = lambda name: open(os.path.join(public, name), encoding="utf-8").read()
	html = read("tgui.html")
	config = {
		"title": title or interface,
		"status": 2,
		"interface": {"name": interface, "layout": "default"},
		"refreshing": False,
		"window": {"key": "preview", "size": list(size), "locked": False},
		"client": {"ckey": "podglad", "address": "127.0.0.1", "computer_id": "0"},
		"user": {"name": "Podgląd", "observer": False},
	}
	message = {"type": "update", "payload": {"config": config, "data": payload.get("data") or {}, "static_data": payload.get("static_data") or {}}}
	html = html.replace("[tgui:windowId]", "preview").replace("[tgui:strictMode]", "1")
	html = html.replace("<!-- tgui:helpers -->", ERROR_HOOK + "<script>\n" + read("helpers.min.js") + "\n</script>")
	if os.path.exists(os.path.join(public, "ntos-error.min.css")):
		html = html.replace("<!-- tgui:ntos-error -->", "<style>\n" + read("ntos-error.min.css") + "\n</style>")
	assets = "<script>\nByond.loadCss('tgui.bundle.css', true);\nByond.loadJs('tgui.bundle.js', true);\n</script>\n"
	html = html.replace("<!-- tgui:assets -->", assets)
	# Wiadomość po załadowaniu bundle'a, jak send_full_update po „ready”
	inject = "<script>\nwindow.addEventListener('load', function () { window.update(" + json.dumps(json.dumps(message, ensure_ascii=False), ensure_ascii=False) + "); });\n</script>"
	html = html.replace("<!-- tgui:inline-js -->", inject)
	return html


def from_world(pid, obj, user):
	sys.path.insert(0, os.path.join(REPO, "tools", "auxtools_mcp"))
	import server  # noqa: E402
	result = server.tgui_data(pid, obj, user)
	value = result["value"]
	if not isinstance(value, dict):
		raise SystemExit(f"Świat nie zwrócił danych okna: {json.dumps(result, ensure_ascii=False)}")
	return value


def browser():
	for candidate in BROWSERS:
		path = candidate if os.path.isabs(candidate) else shutil.which(candidate)
		if path and os.path.exists(path):
			return path
	raise SystemExit("Nie znalazłem Chrome ani Edge do zrzutu.")


def main():
	for stream in (sys.stdout, sys.stderr):
		stream.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Podgląd okna TGUI bez klienta BYOND.")
	parser.add_argument("interface", help="nazwa okna jak w ui = new(user, src, \"Nazwa\")")
	parser.add_argument("--data", help="plik JSON z danymi (data/static_data albo same dane)")
	parser.add_argument("--pid", type=int, help="PID świata pod auxtools, z którego wziąć dane")
	parser.add_argument("--obj", help="wyrażenie DM: obiekt z oknem (z --pid)")
	parser.add_argument("--user", help="wyrażenie DM: mob, dla którego liczyć dane (z --pid)")
	parser.add_argument("--public", default=os.path.join(REPO, "tgui", "public"), help="folder z tgui.html i bundle'ami")
	parser.add_argument("--size", default="500x600", help="rozmiar okna SZERxWYS")
	parser.add_argument("--title")
	parser.add_argument("--png", help="zapisz zrzut do pliku PNG")
	parser.add_argument("--html", help="zapisz stronę podglądu (domyślnie folder tymczasowy)")
	args = parser.parse_args()

	if not os.path.exists(os.path.join(args.public, "tgui.bundle.js")):
		raise SystemExit(f"Brak {args.public}\\tgui.bundle.js: zbuduj bundle (tools\\build\\build.bat tgui).")
	if args.pid:
		payload = from_world(args.pid, args.obj, args.user)
	elif args.data:
		payload = json.load(open(args.data, encoding="utf-8"))
	else:
		payload = {}
	if "data" not in payload and "static_data" not in payload:
		payload = {"data": payload}
	width, height = (int(x) for x in args.size.lower().split("x"))

	# Strony muszą leżeć obok bundle'i (Byond.loadJs ładuje je ścieżką względną); w .gitignore jako _podglad_*
	inner = f"_podglad_{args.interface}_okno.html"
	open(os.path.join(args.public, inner), "w", encoding="utf-8").write(build_page(args.interface, payload, args.public, (width, height), args.title))
	target = args.html or os.path.join(args.public, f"_podglad_{args.interface}.html")
	open(target, "w", encoding="utf-8").write(OUTER.format(inner=inner, w=width, h=height, below=height + 10))
	print(f"strona: {target}")
	if not args.png:
		return 0

	exe = browser()
	profile = tempfile.mkdtemp(prefix="tgui-preview-")
	url = "file:///" + os.path.abspath(target).replace("\\", "/")
	# Okno przeglądarki większe od okna TGUI (minimum 500 px, ramka, miejsce na błędy), potem przycięcie do iframe
	common = [exe, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1", f"--user-data-dir={profile}", "--allow-file-access-from-files", f"--window-size={max(width, 500) + 50},{height + 400}", "--virtual-time-budget=4000"]
	subprocess.run([*common, f"--screenshot={os.path.abspath(args.png)}", url], capture_output=True, timeout=120)
	dom = subprocess.run([*common, "--dump-dom", url], capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=120).stdout
	shutil.rmtree(profile, ignore_errors=True)
	if not args.html:
		os.remove(target)
		os.remove(os.path.join(args.public, inner))
	from PIL import Image
	with Image.open(args.png) as shot:
		shot.crop((0, 0, width, height)).save(args.png)
	errors = ""
	start = dom.find('id="preview-errors"')
	if start >= 0:
		errors = dom[dom.find(">", start) + 1:dom.find("</pre>", start)].strip()
	log = os.path.splitext(args.png)[0] + ".log"
	with open(log, "w", encoding="utf-8") as f:
		f.write(errors or "brak błędów JS\n")
	print(f"zrzut: {args.png}")
	if errors:
		print(f"BŁĘDY w oknie (szczegóły: {log}):\n{errors[:2000]}")
		return 1
	print("brak błędów JS")
	return 0


if __name__ == "__main__":
	sys.exit(main())
