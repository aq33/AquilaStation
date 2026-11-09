"""Testy serwisu czatu głosowego: zgoda na chmurę i /info.

Uruchomienie: python -m unittest tools/voice_chat/test_voice_server.py (z katalogu repozytorium).
Serwis startuje w wątku na wolnym porcie, chmura ma fałszywy adres, więc nic nie wychodzi do internetu.
"""

import argparse
import hashlib
import json
import os
import queue
import struct
import sys
import threading
import unittest
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import voice_server  # noqa: E402

TOKEN = "0123456789abcdef0123456789abcdef"
SECRET = "sekret_testowy"


def make_args(backend, save_dir=""):
	return argparse.Namespace(
		backend=backend, model="", api_key="test", keyterms=[], language="pl", prompt="",
		whisper="http://127.0.0.1:9", secret=SECRET, save_dir=save_dir, verbose=False,
	)


def wav(seconds=1.0, rate=16000):
	samples = int(seconds * rate)
	return (b"RIFF" + struct.pack("<I", 36 + samples * 2) + b"WAVEfmt "
		+ struct.pack("<IHHIIHH", 16, 1, 1, rate, rate * 2, 2, 16)
		+ b"data" + struct.pack("<I", samples * 2) + b"\x10\x00" * samples)


class VoiceServerTest(unittest.TestCase):
	def start_server(self, backend):
		server = voice_server.Server(("127.0.0.1", 0), voice_server.Handler)
		server.args = make_args(backend)
		server.state = voice_server.State()
		threading.Thread(target=server.serve_forever, daemon=True).start()
		self.addCleanup(server.server_close)
		self.addCleanup(server.shutdown)
		self.base = f"http://127.0.0.1:{server.server_address[1]}"
		# Chmura bez sieci: zamiast prawdziwego zapytania zapamiętujemy, że nagranie poszłoby do dostawcy
		self.sent = []
		original = voice_server.BACKENDS[backend]
		voice_server.BACKENDS[backend] = lambda args, data: self.sent.append(len(data)) or "test"
		self.addCleanup(voice_server.BACKENDS.__setitem__, backend, original)
		return server

	def request(self, path, data=None, headers=None):
		req = urllib.request.Request(self.base + path, data=data, headers=headers or {}, method="POST" if data is not None else "GET")
		try:
			with urllib.request.urlopen(req, timeout=5) as resp:
				return resp.status, json.loads(resp.read().decode("utf-8"))
		except urllib.error.HTTPError as e:
			return e.code, json.loads(e.read().decode("utf-8"))

	def sync(self, cmds=()):
		headers = {"X-Voice-Secret": hashlib.sha256(SECRET.encode()).hexdigest(), "Content-Type": "application/json"}
		return self.request("/api/sync", json.dumps({"sessions": {TOKEN: "tester"}, "cmds": list(cmds)}).encode(), headers)

	def connect_page(self):
		"""Otwiera strumień /events jak strona gracza i zwraca identyfikator połączenia."""
		hello = queue.Queue()

		def listen():
			with urllib.request.urlopen(self.base + "/events?t=" + TOKEN, timeout=10) as resp:
				for line in resp:
					line = line.decode("utf-8").strip()
					# Czytamy dalej: zamknięte połączenie to zamknięta karta, a jej nagrań serwis już nie przyjmie
					if line.startswith("data:") and "conn" in line:
						hello.put(json.loads(line[5:])["conn"])

		threading.Thread(target=listen, daemon=True).start()
		return hello.get(timeout=5)

	def record(self, seq, conn, consent=""):
		self.sync([{"token": TOKEN, "cmd": "start", "seq": seq, "channel": "say"}])
		query = f"/audio?t={TOKEN}&c={conn}&seq={seq}" + (f"&consent={consent}" if consent else "")
		return self.request(query, wav(), {"Content-Type": "audio/wav"})

	def test_info_names_cloud_provider(self):
		self.start_server("elevenlabs")
		status, info = self.request("/info")
		self.assertEqual(status, 200)
		self.assertEqual(info["provider"], "elevenlabs")
		self.assertEqual(info["provider_name"], "ElevenLabs")
		self.assertTrue(info["privacy_url"].startswith("https://"))
		self.assertFalse(info["saves_recordings"])

	def test_info_local_whisper_has_no_provider(self):
		self.start_server("whisper")
		status, info = self.request("/info")
		self.assertEqual(status, 200)
		self.assertIsNone(info["provider"])

	def test_cloud_upload_requires_consent(self):
		self.start_server("elevenlabs")
		self.sync()
		conn = self.connect_page()
		status, _ = self.record(1, conn)
		self.assertEqual(status, 403)
		self.assertEqual(self.sent, [], "Nagranie bez zgody poszło do chmury")
		status, _ = self.record(2, conn, consent="openai")
		self.assertEqual(status, 403, "Zgoda na innego dostawcę przepuściła nagranie")
		status, body = self.record(3, conn, consent="elevenlabs")
		self.assertEqual(status, 200)
		self.assertEqual(body["text"], "test")
		self.assertEqual(len(self.sent), 1)


if __name__ == "__main__":
	unittest.main()
