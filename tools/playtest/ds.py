"""Sterowanie Dream Seekerem bez zabierania myszy i klawiatury: test w grze z poziomu skryptu albo agenta.

Zrzuty: PrintWindow każdego widocznego okna procesu klienta (mapa, okna TGUI bez tytułu), więc działa też,
gdy okno jest zasłonięte. Kliknięcia i klawisze: PostMessage do okna potomnego pod punktem (mapa, czat,
przyciski TGUI w Chrome_RenderWidgetHostHWND), bez ruszania kursora użytkownika.
Klient z 127.0.0.1 dostaje rangę !localhost! (ENABLE_LOCALHOST_RANK), więc ma wszystkie czasowniki admina.

Użycie (z katalogu repo, stan sesji w data/playtest.json):
  python tools/playtest/ds.py start                  # Dream Daemon na wolnym porcie + Dream Seeker 1400x900
  python tools/playtest/ds.py start --port 41999     # tylko klient do działającego świata (np. world_launch z MCP)
  python tools/playtest/ds.py shot zrzut.png         # okno główne; --wszystkie dokłada okna TGUI (zrzut_1.png ...)
  python tools/playtest/ds.py okna                   # lista okien klienta (uchwyt, rozmiar, tytuł)
  python tools/playtest/ds.py click 640 400          # współrzędne na zrzucie okna głównego; --prawy, --ctrl, --shift, --alt
  python tools/playtest/ds.py click 120 80 --okno 2  # klik w okno nr 2 z listy (np. okno TGUI)
  python tools/playtest/ds.py klawisz F5             # klawisz (nazwa VK albo litera), --okno jak wyżej
  python tools/playtest/ds.py pisz "Say \\"test\\""   # tekst do pola wejścia klienta + Enter
  python tools/playtest/ds.py stop                   # zamyka tylko procesy wystartowane przez start
"""

import argparse
import ctypes
import ctypes.wintypes as wt
import json
import os
import socket
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
STATE = os.path.join(REPO, "data", "playtest.json")
sys.path.insert(0, os.path.join(REPO, "tools", "local_ci"))

user32 = ctypes.WinDLL("user32", use_last_error=True)
gdi32 = ctypes.WinDLL("gdi32")
user32.SetProcessDPIAware()

WM_KEYDOWN, WM_KEYUP, WM_CHAR = 0x0100, 0x0101, 0x0102
WM_MOUSEMOVE, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_RBUTTONDOWN, WM_RBUTTONUP = 0x0200, 0x0201, 0x0202, 0x0204, 0x0205
MK_LBUTTON, MK_RBUTTON, MK_SHIFT, MK_CONTROL = 0x1, 0x2, 0x4, 0x8
VK = {"ENTER": 0x0D, "RETURN": 0x0D, "TAB": 0x09, "ESC": 0x1B, "ESCAPE": 0x1B, "SPACE": 0x20, "BACKSPACE": 0x08,
	"UP": 0x26, "DOWN": 0x28, "LEFT": 0x25, "RIGHT": 0x27, "DELETE": 0x2E, "HOME": 0x24, "END": 0x23, "INSERT": 0x2D,
	"SHIFT": 0x10, "CTRL": 0x11, "ALT": 0x12, **{f"F{i}": 0x6F + i for i in range(1, 13)}}

WNDENUMPROC = ctypes.WINFUNCTYPE(wt.BOOL, wt.HWND, wt.LPARAM)


def free_port():
	with socket.socket() as s:
		s.bind(("127.0.0.1", 0))
		return s.getsockname()[1]


def port_open(port):
	with socket.socket() as s:
		s.settimeout(0.5)
		return s.connect_ex(("127.0.0.1", port)) == 0


def load_state():
	try:
		return json.load(open(STATE, encoding="utf-8"))
	except (OSError, ValueError):
		return {}


def save_state(state):
	os.makedirs(os.path.dirname(STATE), exist_ok=True)
	json.dump(state, open(STATE, "w", encoding="utf-8"), indent=1)


def windows_of(pid, visible_only=True):
	found = []

	def callback(hwnd, _):
		owner = wt.DWORD()
		user32.GetWindowThreadProcessId(hwnd, ctypes.byref(owner))
		if owner.value == pid and (not visible_only or user32.IsWindowVisible(hwnd)):
			rect = wt.RECT()
			user32.GetWindowRect(hwnd, ctypes.byref(rect))
			title = ctypes.create_unicode_buffer(256)
			user32.GetWindowTextW(hwnd, title, 256)
			w, h = rect.right - rect.left, rect.bottom - rect.top
			if w >= 50 and h >= 50:
				found.append({"hwnd": hwnd, "w": w, "h": h, "title": title.value, "x": rect.left, "y": rect.top})
		return True

	user32.EnumWindows(WNDENUMPROC(callback), 0)
	# Okno główne (największe) pierwsze, potem okna TGUI od największego
	return sorted(found, key=lambda f: -f["w"] * f["h"])


def client_pid(state):
	pid = state.get("ds_pid")
	if not pid:
		raise SystemExit("Brak klienta: python tools/playtest/ds.py start")
	return pid


def target_window(state, index):
	wins = windows_of(client_pid(state))
	if not wins:
		raise SystemExit("Klient nie ma widocznych okien (zminimalizowany albo zamknięty).")
	if index >= len(wins):
		raise SystemExit(f"Klient ma {len(wins)} okien, nie ma okna nr {index}.")
	return wins[index]


def screenshot(hwnd, path):
	from PIL import Image
	rect = wt.RECT()
	user32.GetWindowRect(hwnd, ctypes.byref(rect))
	w, h = rect.right - rect.left, rect.bottom - rect.top
	hdc = user32.GetWindowDC(hwnd)
	mem = gdi32.CreateCompatibleDC(hdc)
	bmp = gdi32.CreateCompatibleBitmap(hdc, w, h)
	gdi32.SelectObject(mem, bmp)
	user32.PrintWindow(hwnd, mem, 2)  # PW_RENDERFULLCONTENT: też zasłonięte okna i WebView2

	class BITMAPINFOHEADER(ctypes.Structure):
		_fields_ = [("biSize", wt.DWORD), ("biWidth", wt.LONG), ("biHeight", wt.LONG), ("biPlanes", wt.WORD), ("biBitCount", wt.WORD),
			("biCompression", wt.DWORD), ("biSizeImage", wt.DWORD), ("biXPelsPerMeter", wt.LONG), ("biYPelsPerMeter", wt.LONG),
			("biClrUsed", wt.DWORD), ("biClrImportant", wt.DWORD)]

	header = BITMAPINFOHEADER(ctypes.sizeof(BITMAPINFOHEADER), w, -h, 1, 32, 0, 0, 0, 0, 0, 0)
	buffer = ctypes.create_string_buffer(w * h * 4)
	gdi32.GetDIBits(mem, bmp, 0, h, buffer, ctypes.byref(header), 0)
	gdi32.DeleteObject(bmp)
	gdi32.DeleteDC(mem)
	user32.ReleaseDC(hwnd, hdc)
	Image.frombuffer("RGBA", (w, h), buffer, "raw", "BGRA", 0, 1).convert("RGB").save(path)


def deepest_child(hwnd, screen_x, screen_y):
	"""Najgłębsze widoczne okno potomne pod punktem ekranu (mapa, pole tekstowe, widok WebView2)."""
	# ChildWindowFromPointEx nie schodzi do okien WebView2 (panel statystyk, czat, TGUI), więc pełne drzewo
	candidates = []

	def depth(h):
		d = 0
		while h and h != hwnd:
			h = user32.GetParent(h)
			d += 1
		return d

	def callback(child, _):
		if user32.IsWindowVisible(child) and class_name(child) != "Intermediate D3D Window":
			rect = wt.RECT()
			user32.GetWindowRect(child, ctypes.byref(rect))
			if rect.left <= screen_x < rect.right and rect.top <= screen_y < rect.bottom:
				candidates.append((depth(child), -(rect.right - rect.left) * (rect.bottom - rect.top), child))
		return True

	user32.EnumChildWindows(hwnd, WNDENUMPROC(callback), 0)
	return max(candidates)[2] if candidates else hwnd


def lparam(x, y):
	return (y & 0xFFFF) << 16 | (x & 0xFFFF)


def post_click(win, x, y, right=False, ctrl=False, shift=False, alt=False):
	screen_x, screen_y = win["x"] + x, win["y"] + y
	target = deepest_child(win["hwnd"], screen_x, screen_y)
	pt = wt.POINT(screen_x, screen_y)
	user32.ScreenToClient(target, ctypes.byref(pt))
	flags = (MK_CONTROL if ctrl else 0) | (MK_SHIFT if shift else 0)
	down, up, button = (WM_RBUTTONDOWN, WM_RBUTTONUP, MK_RBUTTON) if right else (WM_LBUTTONDOWN, WM_LBUTTONUP, MK_LBUTTON)
	if alt:
		user32.PostMessageW(target, WM_KEYDOWN, VK["ALT"], 0)
	user32.PostMessageW(target, WM_MOUSEMOVE, flags, lparam(pt.x, pt.y))
	user32.PostMessageW(target, down, flags | button, lparam(pt.x, pt.y))
	time.sleep(0.05)
	user32.PostMessageW(target, up, flags, lparam(pt.x, pt.y))
	if alt:
		user32.PostMessageW(target, WM_KEYUP, VK["ALT"], 0)
	return target


def class_name(hwnd):
	buf = ctypes.create_unicode_buffer(128)
	user32.GetClassNameW(hwnd, buf, 128)
	return buf.value


def find_input(main):
	"""Pole wejścia czasowników klienta (RichEdit/Edit w skórce BYOND), najniższe na oknie głównym."""
	edits = []

	def callback(hwnd, _):
		if user32.IsWindowVisible(hwnd) and class_name(hwnd).lower().startswith(("edit", "richedit")):
			rect = wt.RECT()
			user32.GetWindowRect(hwnd, ctypes.byref(rect))
			edits.append((rect.bottom, rect.right - rect.left, hwnd))
		return True

	user32.EnumChildWindows(main, WNDENUMPROC(callback), 0)
	if not edits:
		return None
	return max(edits)[2]


def cmd_start(args):
	from local_ci import find_byond
	state = load_state()
	if state.get("ds_pid") and windows_of(state["ds_pid"]):
		raise SystemExit(f"Klient już działa (PID {state['ds_pid']}). Najpierw: ds.py stop")
	bin_dir = os.path.join(find_byond(None), "bin")
	port = args.port
	state = {}
	if not port:
		port = free_port()
		dd = subprocess.Popen([os.path.join(bin_dir, "dd.exe"), args.dmb, "-port", str(port), "-trusted", "-invisible"], cwd=os.getcwd(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
		state["dd_pid"] = dd.pid
		print(f"Dream Daemon PID {dd.pid}, port {port}, czekam na świat...")
		started = time.time()
		while not port_open(port):
			if dd.poll() is not None:
				raise SystemExit("Dream Daemon się zamknął przy starcie (zdarza się na 516 po „Wiremod Composite Templates”, ponów).")
			if time.time() - started > args.limit:
				raise SystemExit("Świat nie otworzył portu w limicie czasu.")
			time.sleep(2)
	ds = subprocess.Popen([os.path.join(bin_dir, "dreamseeker.exe"), f"byond://127.0.0.1:{port}"])
	state.update({"ds_pid": ds.pid, "port": port})
	save_state(state)
	started = time.time()
	main = None
	while time.time() - started < 120:
		wins = windows_of(ds.pid, visible_only=False)
		main = next((w for w in wins if w["w"] >= 100), None)
		if main:
			break
		time.sleep(1)
	if not main:
		raise SystemExit("Nie znalazłem okna Dream Seekera.")
	user32.ShowWindow(main["hwnd"], 9)  # SW_RESTORE: klient startuje zminimalizowany
	width, height = (int(v) for v in args.rozmiar.lower().split("x"))
	user32.SetWindowPos(main["hwnd"], 0, 40, 40, width, height, 0x0004 | 0x0010)  # NOZORDER | NOACTIVATE
	print(f"Dream Seeker PID {ds.pid} połączony z 127.0.0.1:{port}. Zasoby ładują się kilka-kilkanaście sekund.")


def cmd_shot(args):
	state = load_state()
	wins = windows_of(client_pid(state))
	if not wins:
		raise SystemExit("Klient nie ma widocznych okien.")
	base, ext = os.path.splitext(args.plik)
	for i, win in enumerate(wins if args.wszystkie else wins[:1]):
		path = args.plik if i == 0 else f"{base}_{i}{ext}"
		screenshot(win["hwnd"], path)
		print(f"{path}: okno {i} {win['w']}x{win['h']} „{win['title']}”")


def cmd_okna(args):
	for i, win in enumerate(windows_of(client_pid(load_state()))):
		print(f"{i}: {win['w']}x{win['h']} na ({win['x']},{win['y']}) „{win['title']}” hwnd={win['hwnd']}")


def cmd_click(args):
	win = target_window(load_state(), args.okno)
	target = post_click(win, args.x, args.y, args.prawy, args.ctrl, args.shift, args.alt)
	print(f"klik w ({args.x},{args.y}) okna {args.okno} -> {class_name(target)}")


def cmd_klawisz(args):
	win = target_window(load_state(), args.okno)
	name = args.klawisz.upper()
	code = VK.get(name) or (ord(name) if len(name) == 1 else None)
	if not code:
		raise SystemExit(f"Nieznany klawisz {args.klawisz}")
	target = deepest_child(win["hwnd"], win["x"] + win["w"] // 2, win["y"] + win["h"] // 3)
	user32.PostMessageW(target, WM_KEYDOWN, code, 1)
	time.sleep(0.05)
	user32.PostMessageW(target, WM_KEYUP, code, 1 | 0xC0000000)
	print(f"klawisz {name} -> {class_name(target)}")


def cmd_pisz(args):
	win = target_window(load_state(), 0)
	field = find_input(win["hwnd"])
	if not field:
		raise SystemExit("Nie znalazłem pola wejścia w oknie klienta.")
	for char in args.tekst:
		user32.PostMessageW(field, WM_CHAR, ord(char), 1)
	if not args.bez_enter:
		user32.PostMessageW(field, WM_KEYDOWN, VK["ENTER"], 1)
		user32.PostMessageW(field, WM_CHAR, 0x0D, 1)
		user32.PostMessageW(field, WM_KEYUP, VK["ENTER"], 1 | 0xC0000000)
	print(f"wpisano {len(args.tekst)} znaków do {class_name(field)}")


def cmd_stop(args):
	state = load_state()
	for key in ("ds_pid", "dd_pid"):
		pid = state.get(key)
		if pid:
			subprocess.run(["taskkill", "/PID", str(pid), "/F"], capture_output=True)
			print(f"zamknięty PID {pid}")
	save_state({})


def main():
	for stream in (sys.stdout, sys.stderr):
		stream.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Sterowanie Dream Seekerem (zrzuty, kliknięcia, klawisze).")
	sub = parser.add_subparsers(dest="cmd", required=True)
	p = sub.add_parser("start")
	p.add_argument("--port", type=int, help="podłącz się do działającego świata zamiast startować własny")
	p.add_argument("--dmb", default="nsv13.dmb")
	p.add_argument("--rozmiar", default="1400x900")
	p.add_argument("--limit", type=int, default=600)
	p.set_defaults(func=cmd_start)
	p = sub.add_parser("shot")
	p.add_argument("plik")
	p.add_argument("--wszystkie", action="store_true")
	p.set_defaults(func=cmd_shot)
	sub.add_parser("okna").set_defaults(func=cmd_okna)
	p = sub.add_parser("click")
	p.add_argument("x", type=int)
	p.add_argument("y", type=int)
	p.add_argument("--okno", type=int, default=0)
	for flag in ("prawy", "ctrl", "shift", "alt"):
		p.add_argument(f"--{flag}", action="store_true")
	p.set_defaults(func=cmd_click)
	p = sub.add_parser("klawisz")
	p.add_argument("klawisz")
	p.add_argument("--okno", type=int, default=0)
	p.set_defaults(func=cmd_klawisz)
	p = sub.add_parser("pisz")
	p.add_argument("tekst")
	p.add_argument("--bez-enter", action="store_true")
	p.set_defaults(func=cmd_pisz)
	sub.add_parser("stop").set_defaults(func=cmd_stop)
	args = parser.parse_args()
	args.func(args)


if __name__ == "__main__":
	main()
