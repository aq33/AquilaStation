#!/usr/bin/env python3
"""Serwis czatu głosowego Aquili.

Gracz otwiera w przeglądarce stronę z tokenem od gry. Strona trzyma mikrofon,
a gra (SSvoice_chat) mówi jej przez /api/sync, kiedy nagrywać. Nagranie idzie
do whisper-server (whisper.cpp), a rozpoznany tekst wraca do gry tym samym
/api/sync i jest wypowiadany przez postać.

Tylko biblioteka standardowa Pythona. Uruchomienie: patrz README.md obok.
"""

import argparse
import hashlib
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
CHANNELS = ("say", "radio", "department")
MAX_AUDIO_BYTES = 2 * 1024 * 1024
MIN_SECONDS = 0.3
MAX_SECONDS = 20.0
# Nagranie, o które gra poprosiła, a strona go nie przysłała (zamknięta karta), wygasa po tylu sekundach.
PENDING_TTL = MAX_SECONDS + 60

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
		# Jedna otwarta strona na token: (kolejka zdarzeń SSE, identyfikator połączenia).
		# Nowa karta z tym samym tokenem odłącza starą, a nagranie przyjmujemy tylko od bieżącej.
		self.listener = None
		self.replaced = False  # nowa karta odłączyła starą (gra ostrzega gracza)
		self.pending = {}  # seq -> (kanał, time.monotonic() polecenia start)
		self.consent_logged = None  # dostawca, na którego zgodę tej sesji już zapisano w logu

	@property
	def connected(self):
		return self.listener is not None

	def push(self, event, data):
		if self.listener:
			self.listener[0].put((event, data))


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
			for token, ckey in wanted.items():
				if token not in self.sessions:
					self.sessions[token] = Session(token, ckey)
				else:
					self.sessions[token].ckey = ckey
			# Polecenia przed usunięciem sesji: „cancel” dla gracza, który właśnie wyszedł, musi dojść do jego strony.
			for cmd in cmds:
				if not isinstance(cmd, dict):
					continue
				session = self.sessions.get(cmd.get("token"))
				if not session:
					continue
				try:
					seq = int(cmd.get("seq") or 0)
				except (TypeError, ValueError):
					continue
				if cmd.get("cmd") == "start":
					channel = cmd.get("channel")
					if channel not in CHANNELS:
						continue
					session.pending[seq] = (channel, time.monotonic())
					session.push("start", {"seq": seq, "channel": channel, "max": cmd.get("max", 15)})
				elif cmd.get("cmd") == "stop":
					session.push("stop", {"seq": seq})
				elif cmd.get("cmd") == "cancel":
					session.pending.pop(seq, None)
					session.push("cancel", {"seq": seq})
			for token in list(self.sessions):
				if token not in wanted:
					self.sessions.pop(token).push("ended", {})
			now = time.monotonic()
			for session in self.sessions.values():
				for seq, (_, started) in list(session.pending.items()):
					if now - started > PENDING_TTL:
						del session.pending[seq]
			results, self.results = self.results, []
			status = {}
			for token, session in self.sessions.items():
				status[token] = {"connected": session.connected, "replaced": session.replaced}
				session.replaced = False
		return {"results": results, "status": status}

	def take_pending(self, token, seq, conn):
		"""Nagranie przyjmujemy tylko od bieżącej karty i tylko takie, o które gra poprosiła."""
		with self.lock:
			session = self.sessions.get(token)
			if not session or not session.listener or not hmac.compare_digest(session.listener[1].encode(), conn.encode("utf-8", "surrogateescape")):
				return None, None
			entry = session.pending.pop(seq, None)
			return session, entry[0] if entry else None

	def release(self, token, conn):
		"""Karta zamknięta albo odświeżona: zwalniamy jej połączenie od razu, bez czekania na zerwane gniazdo."""
		with self.lock:
			session = self.sessions.get(token)
			if not session or not session.listener or not hmac.compare_digest(session.listener[1].encode(), conn.encode("utf-8", "surrogateescape")):
				return
			q = session.listener[0]
			session.listener = None
		q.put(("ended", {}))

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


def post_multipart(url, fields, wav, headers=None, timeout=30):
	boundary = uuid.uuid4().hex
	body = bytearray()
	for name, value in fields.items():
		# Lista = to samo pole powtórzone (np. keyterms w ElevenLabs).
		for item in (value if isinstance(value, list) else [value]):
			if item:
				body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\"\r\n\r\n{item}\r\n".encode("utf-8")
	body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"mowa.wav\"\r\nContent-Type: audio/wav\r\n\r\n".encode()
	body += wav + f"\r\n--{boundary}--\r\n".encode()
	req = urllib.request.Request(
		url,
		data=bytes(body),
		headers={"Content-Type": f"multipart/form-data; boundary={boundary}", **(headers or {})},
		method="POST",
	)
	with urllib.request.urlopen(req, timeout=timeout) as resp:
		return json.loads(resp.read().decode("utf-8"))


# Dostawcy rozpoznawania mowy. Każdy dostaje nagranie WAV 16 kHz mono i zwraca surowy tekst.
def transcribe_whisper(args, wav):
	fields = {"response_format": "json", "language": args.language, "temperature": "0.0", "prompt": args.prompt}
	return post_multipart(args.whisper.rstrip("/") + "/inference", fields, wav).get("text", "")


def transcribe_openai(args, wav):
	fields = {"model": args.model or "gpt-4o-transcribe", "language": args.language, "prompt": args.prompt, "response_format": "json"}
	headers = {"Authorization": f"Bearer {args.api_key}"}
	return post_multipart("https://api.openai.com/v1/audio/transcriptions", fields, wav, headers).get("text", "")


ELEVENLABS_LANGUAGES = {"pl": "pol", "en": "eng"}


def transcribe_elevenlabs(args, wav):
	fields = {"model_id": args.model or "scribe_v2", "language_code": ELEVENLABS_LANGUAGES.get(args.language, args.language), "tag_audio_events": "false"}
	if args.keyterms:
		fields["keyterms"] = args.keyterms  # słowa z gry, do których model ma się skłaniać (+20% ceny)
	headers = {"xi-api-key": args.api_key}
	return post_multipart("https://api.elevenlabs.io/v1/speech-to-text", fields, wav, headers).get("text", "")


BACKENDS = {
	"whisper": transcribe_whisper,
	"openai": transcribe_openai,
	"elevenlabs": transcribe_elevenlabs,
}
API_KEY_ENV = {"openai": "OPENAI_API_KEY", "elevenlabs": "ELEVENLABS_API_KEY"}

# Zewnętrzne firmy, do których idzie nagranie głosu (strona prosi gracza o zgodę przed włączeniem mikrofonu).
CLOUD_PROVIDERS = {
	"openai": {"name": "OpenAI", "privacy": "https://openai.com/policies/privacy-policy/"},
	"elevenlabs": {"name": "ElevenLabs", "privacy": "https://elevenlabs.io/privacy-policy"},
}


def privacy_info(args):
	"""Co strona musi powiedzieć graczowi: dokąd idzie nagranie i czy serwis je zapisuje."""
	provider = CLOUD_PROVIDERS.get(args.backend)
	return {
		"provider": args.backend if provider else None,
		"provider_name": provider["name"] if provider else None,
		"privacy_url": provider["privacy"] if provider else None,
		"saves_recordings": bool(args.save_dir),
	}


def transcribe(args, wav):
	if args.backend == "whisper":
		return transcribe_whisper(args, wav)
	try:
		return BACKENDS[args.backend](args, wav)
	except (urllib.error.URLError, OSError, ValueError) as e:
		# Chmura nie działa (limit, brak sieci): lokalny Whisper, jeśli stoi.
		print(f"[glos] {args.backend} nie odpowiada ({e}), używam lokalnego Whispera", flush=True)
		return transcribe_whisper(args, wav)


def args_cloud(args):
	return args.backend in CLOUD_PROVIDERS


def read_api_key(path, env_name):
	"""Klucz z pliku: linia NAZWA=wartość albo sam klucz w jedynej linii."""
	with open(path, encoding="utf-8-sig") as f:
		lines = [line.strip() for line in f if line.strip()]
	for line in lines:
		name, sep, value = line.partition("=")
		if sep and name.strip() == env_name:
			return value.strip()
	if len(lines) == 1 and "=" not in lines[0]:
		return lines[0]
	return ""


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
		if self.close_connection:
			# Treść żądania nie została odczytana: na tym połączeniu nie może przyjść następne zapytanie.
			self.send_header("Connection", "close")
		self.end_headers()
		self.wfile.write(body)

	def read_body(self, limit):
		"""Treść żądania albo None (zła lub za duża długość; wtedy połączenie zostanie zamknięte)."""
		try:
			length = int(self.headers.get("Content-Length") or 0)
		except ValueError:
			length = -1
		if length < 0 or length > limit:
			self.close_connection = True
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
		if url.path == "/info":
			return self.send_body(200, privacy_info(self.server.args))
		self.send_body(404, {"error": "nie ma takiej strony"})

	def do_POST(self):
		url = urlparse(self.path)
		query = parse_qs(url.query)
		if url.path == "/api/sync":
			return self.api_sync()
		if url.path == "/audio":
			return self.audio(self.token_arg(query), query)
		if url.path == "/bye":
			self.read_body(4096)
			token = self.token_arg(query)
			if token:
				self.server.state.release(token, (query.get("c") or [""])[0])
			return self.send_body(200, {"ok": True})
		self.send_body(404, {"error": "nie ma takiej strony"})

	def api_sync(self):
		secret = self.server.args.secret
		# Gra wysyła SHA-256 sekretu (hex): nagłówek HTTP przyjmuje tylko ASCII, a sekret może mieć polskie litery.
		# Porównujemy bajty, bo compare_digest na str rzuca wyjątek dla znaków spoza ASCII.
		given = self.headers.get("X-Voice-Secret", "").strip().lower().encode("latin-1", "replace")
		expected = hashlib.sha256(secret.encode("utf-8")).hexdigest().encode("ascii")
		if secret and not hmac.compare_digest(given, expected):
			self.close_connection = True
			return self.send_body(403, {"error": "zły sekret"})
		body = self.read_body(1024 * 1024)
		if body is None:
			return self.send_body(413, {"error": "za duże zapytanie"})
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
			conn = uuid.uuid4().hex
			if session.listener:
				# Ta sama strona otwarta drugi raz (albo przez kogoś z linkiem): stara karta się odłącza.
				session.listener[0].put(("replaced", {}))
				session.replaced = True
			session.listener = (q, conn)
			ckey = session.ckey
		try:
			self.send_response(200)
			self.send_header("Content-Type", "text/event-stream; charset=utf-8")
			self.send_header("Cache-Control", "no-store")
			self.send_header("Connection", "close")
			self.end_headers()
			self.write_event("hello", {"ckey": ckey, "conn": conn})
			while True:
				try:
					event, data = q.get(timeout=15)
				except queue.Empty:
					self.wfile.write(b": ping\n\n")
					self.wfile.flush()
					continue
				self.write_event(event, data)
				if event in ("ended", "replaced"):
					break
		except (BrokenPipeError, ConnectionResetError, ConnectionAbortedError):
			pass
		finally:
			with state.lock:
				if session.listener and session.listener[0] is q:
					session.listener = None
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
		conn = (query.get("c") or [""])[0]
		session, channel = self.server.state.take_pending(token, seq, conn) if token else (None, None)
		if not channel:
			# Strona może wysłać tylko to, o co poprosiła gra (gracz trzymał klawisz).
			return self.send_body(409, {"error": "gra nie czeka na to nagranie"})
		state = self.server.state
		# Bez zgody gracza nagranie nie wychodzi do chmury (np. stara strona z pamięci przeglądarki, która nie pytała)
		consent = (query.get("consent") or [""])[0]
		if args_cloud(self.server.args):
			if consent != self.server.args.backend:
				state.add_result(session, seq, channel, "", "brak zgody na wysyłanie głosu, odśwież stronę czatu głosowego")
				return self.send_body(403, {"error": "brak zgody"})
			if session.consent_logged != consent:
				# Ślad w logu usługi (journal), kto i kiedy zgodził się na wysyłanie głosu do tej firmy
				session.consent_logged = consent
				print(f"[glos] zgoda: {session.ckey} wysyła głos do {CLOUD_PROVIDERS[consent]['name']}", flush=True)
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
			state.add_result(session, seq, channel, "", "rozpoznawanie mowy nie odpowiada")
			print(f"[glos] błąd rozpoznawania ({self.server.args.backend}): {e}", flush=True)
			return self.send_body(502, {"error": "rozpoznawanie mowy nie odpowiada"})
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
	p.add_argument("--backend", choices=sorted(BACKENDS), default="whisper", help="whisper = lokalny whisper-server, openai / elevenlabs = chmura")
	p.add_argument("--model", default="", help="model dostawcy w chmurze (domyślnie gpt-4o-transcribe / scribe_v2)")
	p.add_argument("--api-key", default="", help="klucz API chmury; domyślnie ze zmiennej OPENAI_API_KEY / ELEVENLABS_API_KEY")
	p.add_argument("--api-key-file", default="", help="plik z kluczem (NAZWA=wartość albo sam klucz)")
	p.add_argument("--keyterms-file", default="", help="plik ze słowami z gry (jedno na linię) dla ElevenLabs keyterms")
	p.add_argument("--language", default="pl")
	p.add_argument("--prompt", default="Halo, tu kapitan. Ochrona, proszę na mostek. Medyczny, mamy rannego. Inżynieria, sprawdźcie zasilanie. Uwaga, syndykat na pokładzie!", help="podpowiedź dla Whispera: naturalne zdania ze słownictwem gry działają lepiej niż lista słów")
	p.add_argument("--secret", default=os.environ.get("VOICE_CHAT_SECRET", ""), help="musi się zgadzać z VOICE_CHAT_SECRET w configu gry")
	p.add_argument("--save-dir", default="", help="zapisuj nagrania i rozpoznany tekst do tego folderu (diagnostyka)")
	p.add_argument("--verbose", action="store_true")
	args = p.parse_args()
	sys.stdout.reconfigure(encoding="utf-8")  # konsola Windows domyślnie psuje polskie znaki
	args.keyterms = []
	if args.keyterms_file:
		with open(args.keyterms_file, encoding="utf-8") as f:
			args.keyterms = [line.strip() for line in f if line.strip() and not line.startswith("#")][:1000]
	if args.backend in API_KEY_ENV and not args.api_key:
		args.api_key = os.environ.get(API_KEY_ENV[args.backend], "")
		if not args.api_key and args.api_key_file:
			args.api_key = read_api_key(args.api_key_file, API_KEY_ENV[args.backend])
		if not args.api_key:
			p.error(f"brak klucza API: ustaw {API_KEY_ENV[args.backend]} albo --api-key")
	server = Server((args.host, args.port), Handler)
	server.args = args
	server.state = State()
	backend = args.whisper if args.backend == "whisper" else f"{args.backend} {args.model or '(domyślny model)'}"
	print(f"[glos] nasłuch na http://{args.host}:{args.port}, rozpoznawanie: {backend}", flush=True)
	server.serve_forever()


if __name__ == "__main__":
	main()
