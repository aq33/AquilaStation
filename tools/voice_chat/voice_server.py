#!/usr/bin/env python3
"""Serwis czatu głosowego Aquili.

Gracz otwiera w przeglądarce stronę z tokenem od gry. Strona trzyma mikrofon,
a gra (SSvoice_chat) mówi jej przez /api/sync, kiedy nagrywać. Nagranie idzie
do whisper-server (whisper.cpp), a rozpoznany tekst wraca do gry tym samym
/api/sync i jest wypowiadany przez postać.

Tylko biblioteka standardowa Pythona. Uruchomienie: patrz README.md obok.
"""

import argparse
import hmac
import json
import os
import queue
import re
import struct
import sys
import threading
import time
import urllib.error
import urllib.request
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

HERE = os.path.dirname(os.path.abspath(__file__))
TOKEN_RE = re.compile(r"^[0-9a-f]{32}$")
CHANNELS = ("say", "radio")
MAX_AUDIO_BYTES = 2 * 1024 * 1024
MIN_SECONDS = 0.3
MAX_SECONDS = 20.0

# Zdania, które Whisper wymyśla na ciszy albo szumie (z napisów filmów, na których go uczono).
HALLUCINATIONS = (
	"amara.org",
	"napisy stworzone",
	"napisy wykonane",
	"napisy przygotował",
	"dziękuję za obejrzenie",
	"dzięki za obejrzenie",
	"dziękuję za uwagę",
	"subskrybuj",
	"zasubskrybuj",
	"tłumaczenie:",
	"www.",
)


class Session:
	def __init__(self, token, ckey):
		self.token = token
		self.ckey = ckey
		self.listeners = []  # kolejki zdarzeń otwartych stron (SSE)
		self.pending = {}  # seq -> kanał nagrania, na które gra czeka

	@property
	def connected(self):
		return bool(self.listeners)

	def push(self, event, data):
		for q in list(self.listeners):
			q.put((event, data))


class State:
	def __init__(self):
		self.lock = threading.Lock()
		self.sessions = {}
		self.results = []

	def sync(self, sessions, cmds):
		"""Gra przysyła pełną listę sesji i nowe polecenia, dostaje wyniki i stan stron."""
		with self.lock:
			wanted = {}
			for token, ckey in sessions.items():
				if TOKEN_RE.match(str(token)):
					wanted[token] = str(ckey)
			for token in list(self.sessions):
				if token not in wanted:
					self.sessions.pop(token).push("ended", {})
			for token, ckey in wanted.items():
				if token not in self.sessions:
					self.sessions[token] = Session(token, ckey)
				else:
					self.sessions[token].ckey = ckey
			for cmd in cmds:
				session = self.sessions.get(cmd.get("token"))
				if not session:
					continue
				seq = int(cmd.get("seq", 0))
				if cmd.get("cmd") == "start":
					channel = cmd.get("channel")
					if channel not in CHANNELS:
						continue
					session.pending[seq] = channel
					session.push("start", {"seq": seq, "channel": channel, "max": cmd.get("max", 15)})
				elif cmd.get("cmd") == "stop":
					session.push("stop", {"seq": seq})
				elif cmd.get("cmd") == "cancel":
					session.pending.pop(seq, None)
					session.push("cancel", {"seq": seq})
			results, self.results = self.results, []
			status = {t: {"connected": s.connected} for t, s in self.sessions.items()}
		return {"results": results, "status": status}

	def take_pending(self, token, seq):
		with self.lock:
			session = self.sessions.get(token)
			if not session:
				return None, None
			return session, session.pending.pop(seq, None)

	def add_result(self, session, seq, channel, text, error=None):
		with self.lock:
			self.results.append({"token": session.token, "seq": seq, "channel": channel, "text": text, "error": error})
		session.push("result", {"seq": seq, "text": text, "error": error})


def wav_seconds(data):
	"""Długość nagrania WAV PCM w sekundach albo None, gdy to nie WAV."""
	if len(data) < 44 or data[0:4] != b"RIFF" or data[8:12] != b"WAVE":
		return None
	pos = 12
	byte_rate = None
	while pos + 8 <= len(data):
		chunk_id = data[pos:pos + 4]
		size = struct.unpack("<I", data[pos + 4:pos + 8])[0]
		if chunk_id == b"fmt ":
			byte_rate = struct.unpack("<I", data[pos + 16:pos + 20])[0]
		elif chunk_id == b"data" and byte_rate:
			return min(size, len(data) - pos - 8) / byte_rate
		pos += 8 + size + (size & 1)
	return None


def clean_text(text):
	text = " ".join(line.strip() for line in text.splitlines())
	text = re.sub(r"\[[^\]]*\]|\([^)]*\)|\*[^*]*\*", " ", text)  # [muzyka], (śmiech), *kaszel*
	text = re.sub(r"\s+", " ", text).strip().lstrip("-– ").strip()
	lowered = text.lower()
	if any(h in lowered for h in HALLUCINATIONS):
		return ""
	if not re.search(r"\w", text):
		return ""
	return text[:300]


def transcribe(args, wav):
	boundary = uuid.uuid4().hex
	fields = {
		"response_format": "json",
		"language": args.language,
		"temperature": "0.0",
		"prompt": args.prompt,
	}
	body = bytearray()
	for name, value in fields.items():
		body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\"\r\n\r\n{value}\r\n".encode("utf-8")
	body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"mowa.wav\"\r\nContent-Type: audio/wav\r\n\r\n".encode()
	body += wav + f"\r\n--{boundary}--\r\n".encode()
	req = urllib.request.Request(
		args.whisper.rstrip("/") + "/inference",
		data=bytes(body),
		headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
		method="POST",
	)
	with urllib.request.urlopen(req, timeout=30) as resp:
		return json.loads(resp.read().decode("utf-8")).get("text", "")


def save_recording(args, session, seq, wav):
	"""Zapis nagrania do porównywania modeli (--save-dir). Zwraca ścieżkę bez rozszerzenia."""
	if not args.save_dir:
		return None
	os.makedirs(args.save_dir, exist_ok=True)
	path = os.path.join(args.save_dir, f"{time.strftime('%Y%m%d-%H%M%S')}_{session.ckey}_{seq}")
	with open(path + ".wav", "wb") as f:
		f.write(wav)
	return path


class Server(ThreadingHTTPServer):
	daemon_threads = True

	def handle_error(self, request, client_address):
		# Zamknięta karta zrywa połączenie SSE, to nie błąd.
		if isinstance(sys.exc_info()[1], (ConnectionResetError, ConnectionAbortedError, BrokenPipeError)):
			return
		super().handle_error(request, client_address)


class Handler(BaseHTTPRequestHandler):
	server_version = "AquilaVoice/1"
	protocol_version = "HTTP/1.1"

	def log_message(self, fmt, *a):
		if self.server.args.verbose:
			super().log_message(fmt, *a)

	def send_body(self, code, body, ctype="application/json; charset=utf-8"):
		if isinstance(body, (dict, list)):
			body = json.dumps(body, ensure_ascii=False)
		if isinstance(body, str):
			body = body.encode("utf-8")
		self.send_response(code)
		self.send_header("Content-Type", ctype)
		self.send_header("Content-Length", str(len(body)))
		self.send_header("Cache-Control", "no-store")
		self.end_headers()
		self.wfile.write(body)

	def read_body(self, limit):
		length = int(self.headers.get("Content-Length") or 0)
		if length > limit:
			return None
		return self.rfile.read(length)

	def token_arg(self, query):
		token = (query.get("t") or [""])[0]
		return token if TOKEN_RE.match(token) else None

	def do_GET(self):
		url = urlparse(self.path)
		query = parse_qs(url.query)
		if url.path == "/":
			with open(os.path.join(HERE, "page.html"), "rb") as f:
				return self.send_body(200, f.read(), "text/html; charset=utf-8")
		if url.path == "/events":
			return self.events(self.token_arg(query))
		if url.path == "/health":
			return self.send_body(200, {"ok": True})
		self.send_body(404, {"error": "nie ma takiej strony"})

	def do_POST(self):
		url = urlparse(self.path)
		query = parse_qs(url.query)
		if url.path == "/api/sync":
			return self.api_sync()
		if url.path == "/audio":
			return self.audio(self.token_arg(query), query)
		self.send_body(404, {"error": "nie ma takiej strony"})

	def api_sync(self):
		secret = self.server.args.secret
		if secret and not hmac.compare_digest(self.headers.get("X-Voice-Secret", ""), secret):
			return self.send_body(403, {"error": "zły sekret"})
		body = self.read_body(1024 * 1024)
		try:
			data = json.loads(body or b"{}")
		except ValueError:
			return self.send_body(400, {"error": "zły JSON"})
		sessions = data.get("sessions") or {}
		cmds = data.get("cmds") or []
		if not isinstance(sessions, dict) or not isinstance(cmds, list):
			return self.send_body(400, {"error": "zły format"})
		self.send_body(200, self.server.state.sync(sessions, cmds))

	def events(self, token):
		state = self.server.state
		with state.lock:
			session = state.sessions.get(token) if token else None
			if not session:
				return self.send_body(404, {"error": "sesja wygasła"})
			q = queue.Queue()
			session.listeners.append(q)
			ckey = session.ckey
		try:
			self.send_response(200)
			self.send_header("Content-Type", "text/event-stream; charset=utf-8")
			self.send_header("Cache-Control", "no-store")
			self.send_header("Connection", "close")
			self.end_headers()
			self.write_event("hello", {"ckey": ckey})
			while True:
				try:
					event, data = q.get(timeout=15)
				except queue.Empty:
					self.wfile.write(b": ping\n\n")
					self.wfile.flush()
					continue
				self.write_event(event, data)
				if event == "ended":
					break
		except (BrokenPipeError, ConnectionResetError, ConnectionAbortedError):
			pass
		finally:
			with state.lock:
				if q in session.listeners:
					session.listeners.remove(q)
		self.close_connection = True

	def write_event(self, event, data):
		self.wfile.write(f"event: {event}\ndata: {json.dumps(data, ensure_ascii=False)}\n\n".encode("utf-8"))
		self.wfile.flush()

	def audio(self, token, query):
		try:
			seq = int((query.get("seq") or ["0"])[0])
		except ValueError:
			return self.send_body(400, {"error": "zły numer"})
		body = self.read_body(MAX_AUDIO_BYTES)
		if body is None:
			return self.send_body(413, {"error": "za długie nagranie"})
		session, channel = self.server.state.take_pending(token, seq) if token else (None, None)
		if not channel:
			# Strona może wysłać tylko to, o co poprosiła gra (gracz trzymał klawisz).
			return self.send_body(409, {"error": "gra nie czeka na to nagranie"})
		state = self.server.state
		if (query.get("silent") or ["0"])[0] == "1" or not body:
			state.add_result(session, seq, channel, "", "cisza")
			return self.send_body(200, {"text": ""})
		seconds = wav_seconds(body)
		if seconds is None:
			state.add_result(session, seq, channel, "", "zły format nagrania")
			return self.send_body(400, {"error": "to nie jest WAV"})
		if seconds < MIN_SECONDS:
			state.add_result(session, seq, channel, "", "za krótko")
			return self.send_body(200, {"text": ""})
		if seconds > MAX_SECONDS:
			state.add_result(session, seq, channel, "", "za długo")
			return self.send_body(413, {"error": "za długie nagranie"})
		saved = save_recording(self.server.args, session, seq, body)
		started = time.monotonic()
		try:
			raw = transcribe(self.server.args, body)
		except (urllib.error.URLError, OSError, ValueError) as e:
			state.add_result(session, seq, channel, "", "Whisper nie odpowiada")
			print(f"[glos] błąd Whispera: {e}", flush=True)
			return self.send_body(502, {"error": "Whisper nie odpowiada"})
		text = clean_text(raw)
		took = time.monotonic() - started
		print(f"[glos] {session.ckey} ({channel}, {seconds:.1f} s nagrania, {took:.2f} s): {raw.strip()!r} -> {text!r}", flush=True)
		if saved:
			with open(saved + ".txt", "w", encoding="utf-8") as f:
				f.write(raw.strip() + "\n")
		state.add_result(session, seq, channel, text, None if text else "nie rozpoznano mowy")
		self.send_body(200, {"text": text})


def main():
	p = argparse.ArgumentParser(description="Serwis czatu głosowego Aquili")
	p.add_argument("--host", default="127.0.0.1")
	p.add_argument("--port", type=int, default=8179)
	p.add_argument("--whisper", default="http://127.0.0.1:8178", help="adres whisper-server")
	p.add_argument("--language", default="pl")
	p.add_argument("--prompt", default="Halo, tu kapitan. Ochrona, proszę na mostek. Medyczny, mamy rannego. Inżynieria, sprawdźcie zasilanie. Uwaga, syndykat na pokładzie!", help="podpowiedź dla Whispera: naturalne zdania ze słownictwem gry działają lepiej niż lista słów")
	p.add_argument("--secret", default=os.environ.get("VOICE_CHAT_SECRET", ""), help="musi się zgadzać z VOICE_CHAT_SECRET w configu gry")
	p.add_argument("--save-dir", default="", help="zapisuj nagrania i rozpoznany tekst do tego folderu (diagnostyka)")
	p.add_argument("--verbose", action="store_true")
	args = p.parse_args()
	sys.stdout.reconfigure(encoding="utf-8")  # konsola Windows domyślnie psuje polskie znaki
	server = Server((args.host, args.port), Handler)
	server.args = args
	server.state = State()
	print(f"[glos] nasłuch na http://{args.host}:{args.port}, Whisper: {args.whisper}", flush=True)
	server.serve_forever()


if __name__ == "__main__":
	main()
