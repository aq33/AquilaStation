"""Szuka offsetów byond-tracy dla nowej wersji byondcore.dll na podstawie wersji ze znanymi offsetami.

byond-tracy (fork ParadiseSS13) ma tabelę offsetów osobno dla każdego buildu BYOND. Gdy nowy build jeszcze
jej nie ma, ten skrypt przenosi offsety ze starszego buildu:
- funkcje (exec_proc, server_tick, send_maps): sygnatura z początku funkcji, bajty pod relokacjami
  i argumenty skoków/wywołań względnych zamaskowane,
- dane (strings, miscs, procdefs i ich długości): instrukcje w kodzie, które odwołują się do tego adresu
  przez relokację, wyszukane w nowym pliku, a z nich odczytany nowy adres (wygrywa najczęstszy wynik).

Użycie:
  python tools/tracy/find_offsets.py STARY.dll "0x0042DB98, ..., 0x00050606" NOWY.dll [OCZEKIWANE]
OCZEKIWANE (opcjonalnie) to znane offsety nowego pliku, wtedy skrypt tylko sprawdza, czy trafił.
Wypisuje wiersz gotowy do wklejenia w offsets/windows.h.
"""

import re
import struct
import sys
from collections import Counter


class PE:
	def __init__(self, path):
		self.data = open(path, "rb").read()
		d = self.data
		pe = struct.unpack_from("<I", d, 0x3C)[0]
		nsec = struct.unpack_from("<H", d, pe + 6)[0]
		optsize = struct.unpack_from("<H", d, pe + 20)[0]
		opt = pe + 24
		self.base = struct.unpack_from("<I", d, opt + 28)[0]
		reloc_rva, reloc_size = struct.unpack_from("<II", d, opt + 96 + 5 * 8)
		self.sections = []
		for i in range(nsec):
			s = pe + 24 + optsize + i * 40
			name = d[s:s + 8].rstrip(b"\0").decode()
			vsize, va, rawsize, rawptr = struct.unpack_from("<IIII", d, s + 8)
			chars = struct.unpack_from("<I", d, s + 36)[0]
			self.sections.append((name, va, max(vsize, rawsize), rawptr, rawsize, chars))
		self.relocs = set()
		pos = self.rva2off(reloc_rva)
		end = pos + reloc_size
		while pos < end:
			page, size = struct.unpack_from("<II", d, pos)
			if size == 0:
				break
			for j in range((size - 8) // 2):
				entry = struct.unpack_from("<H", d, pos + 8 + j * 2)[0]
				if entry >> 12 == 3:  # IMAGE_REL_BASED_HIGHLOW
					self.relocs.add(page + (entry & 0xFFF))
			pos += size
		text = [s for s in self.sections if s[5] & 0x20]
		self.text = text[0]

	def rva2off(self, rva):
		for _, va, size, raw, rawsize, _ in self.sections:
			if va <= rva < va + size:
				return raw + rva - va
		raise ValueError(hex(rva))

	def off2rva(self, off):
		for _, va, size, raw, rawsize, _ in self.sections:
			if raw <= off < raw + rawsize:
				return va + off - raw
		return None

	def text_bytes(self):
		_, va, _, raw, rawsize, _ = self.text
		return raw, self.data[raw:raw + rawsize]


def masked_pattern(pe, rva, length):
	"""Regex z bajtów od rva: relokacje i argumenty E8/E9/Jcc rel32 jako dowolne bajty."""
	off = pe.rva2off(rva)
	raw = pe.data[off:off + length]
	mask = [True] * length
	for i in range(length):
		if rva + i in pe.relocs:
			for k in range(4):
				if i + k < length:
					mask[i + k] = False
	i = 0
	while i < length:
		b = raw[i]
		if b in (0xE8, 0xE9) and mask[i]:
			for k in range(1, 5):
				if i + k < length:
					mask[i + k] = False
			i += 5
			continue
		if b == 0x0F and i + 1 < length and 0x80 <= raw[i + 1] <= 0x8F and mask[i]:
			for k in range(2, 6):
				if i + k < length:
					mask[i + k] = False
			i += 6
			continue
		i += 1
	return b"".join(re.escape(bytes([raw[i]])) if mask[i] else b"." for i in range(length))


def find_function(old, new, rva):
	start, text = new.text_bytes()
	for length in (32, 48, 64, 96, 128, 192, 256):
		pat = masked_pattern(old, rva, length)
		hits = [m.start() for m in re.finditer(pat, text, re.DOTALL)]
		if len(hits) == 1:
			return new.off2rva(start + hits[0])
		if not hits:
			break
	return find_function_by_callers(old, new, rva)


def find_function_by_callers(old, new, rva):
	"""Gdy początek funkcji się zmienił: miejsca z `call rel32` do niej w starym pliku, odszukane w nowym, głosują na cel."""
	old_start, old_text = old.text_bytes()
	start, text = new.text_bytes()
	votes = Counter()
	for m in re.finditer(b"\xE8", old_text):
		i = m.start()
		if i + 5 > len(old_text):
			continue
		site = old.off2rva(old_start + i)
		if site + 5 + struct.unpack_from("<i", old_text, i + 1)[0] != rva:
			continue
		before, after = 16, 12
		pat = masked_pattern(old, site - before, before + 5 + after)
		hits = [h.start() for h in re.finditer(pat, text, re.DOTALL)]
		if len(hits) != 1:
			continue
		new_site = new.off2rva(start + hits[0] + before)
		votes[new_site + 5 + struct.unpack_from("<i", text, hits[0] + before + 1)[0]] += 1
	if not votes:
		return None
	best, count = votes.most_common(1)[0]
	print(f"{'':13} (przez wywołania, głosy: {count} z {sum(votes.values())})", file=sys.stderr)
	return best


def find_data(old, new, rva):
	target = old.base + rva
	start, text = new.text_bytes()
	votes = Counter()
	for site in sorted(old.relocs):
		off = old.rva2off(site) if site < old.text[1] + old.text[2] and site >= old.text[1] else None
		if off is None or struct.unpack_from("<I", old.data, off)[0] != target:
			continue
		# Sygnatura: 12 bajtów przed odwołaniem i 8 po nim, z odwołaniem zamaskowanym
		before, after = 12, 8
		pat_rva = site - before
		pat = masked_pattern(old, pat_rva, before + 4 + after)
		hits = [m.start() for m in re.finditer(pat, text, re.DOTALL)]
		if len(hits) != 1:
			continue
		value = struct.unpack_from("<I", text, hits[0] + before)[0]
		votes[value - new.base] += 1
	if not votes:
		return None, 0
	best, count = votes.most_common(1)[0]
	return best, count


def main():
	old = PE(sys.argv[1])
	offsets = [int(x, 16) for x in re.findall(r"0x[0-9A-Fa-f]+", sys.argv[2])]
	new = PE(sys.argv[3])
	expected = [int(x, 16) for x in re.findall(r"0x[0-9A-Fa-f]+", sys.argv[4])] if len(sys.argv) > 4 else None
	result = list(offsets)
	names = ["strings", "strings_len", "miscs", "miscs_len", "procdefs", "procdefs_len", "procdef_desc", "exec_proc", "server_tick", "send_maps", "prologues"]
	for i in range(6):
		value, count = find_data(old, new, offsets[i])
		result[i] = value or 0
		print(f"{names[i]:13} 0x{offsets[i]:08X} -> {('0x%08X' % value) if value is not None else 'NIE ZNALEZIONO'} (głosy: {count})", file=sys.stderr)
	for i in (7, 8, 9):
		value = find_function(old, new, offsets[i])
		result[i] = value or 0
		print(f"{names[i]:13} 0x{offsets[i]:08X} -> {('0x%08X' % value) if value is not None else 'NIE ZNALEZIONO'}", file=sys.stderr)
		if value is not None:
			# Prolog funkcji musi się zgadzać z ostatnim polem (3 bajty, byond-tracy go sprawdza)
			prologue = new.data[new.rva2off(value)]
			print(f"{'':13} pierwszy bajt 0x{prologue:02X}", file=sys.stderr)
	print("{" + ", ".join(f"0x{v:08X}" for v in result) + "}")
	if expected:
		bad = [names[i] for i in range(11) if result[i] != expected[i]]
		print("ZGODNE z oczekiwanymi" if not bad else "NIEZGODNE: " + ", ".join(bad), file=sys.stderr)
		return 1 if bad else 0
	return 0 if all(result) else 1


if __name__ == "__main__":
	sys.exit(main())
