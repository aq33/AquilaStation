"""Buduje prof.dll (byond-tracy, fork ParadiseSS13) dla naszego buildu BYOND i kładzie go obok nsv13.dmb.

Kroki:
1. pobiera prof.c i tabele offsetów z gałęzi z offsetami do 516.1687 (PR ParadiseSS13/byond-tracy#27, przypięty commit),
2. dopisuje offsety buildów nowszych niż tabela (EXTRA_OFFSETS, policzone przez find_offsets.py),
3. kompiluje zig cc pod 32-bitowy Windows z nakładką threads_win32.h (mingw nie ma C11 <threads.h>).

Użycie:  python tools/tracy/build_prof.py [--zig ŚCIEŻKA_DO_zig.exe] [--out nsv13-folder]
zig: https://ziglang.org/download/ (sprawdzone na 0.17.1). Opis całości: tools/tracy/README.md
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
SOURCE = "https://raw.githubusercontent.com/Useroth/byond-tracy/0756e95c8403dfef213d0e1beeb35e3d00b0cfce/"
FILES = ["prof.c", "offsets/windows.h", "offsets/linux.h"]

# build: offsety Windows; policzone find_offsets.py z 516.1687 (oraz niezależnie z 516.1673, ten sam wynik)
EXTRA_OFFSETS = {
	1688: "0x00430BF0, 0x00430BF4, 0x00430C00, 0x00430C04, 0x00430C10, 0x00430C14, 0x001C002C, 0x0013E750, 0x00229950, 0x001DB7B0, 0x00050606",
}


def main():
	parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
	parser.add_argument("--zig", default=shutil.which("zig") or "zig")
	parser.add_argument("--out", default=REPO, help="folder, do którego trafi prof.dll (domyślnie katalog repo)")
	args = parser.parse_args()

	work = tempfile.mkdtemp(prefix="byond-tracy-")
	os.makedirs(os.path.join(work, "offsets"))
	os.makedirs(os.path.join(work, "shim"))
	for name in FILES:
		print(f"pobieram {name}")
		urllib.request.urlretrieve(SOURCE + name, os.path.join(work, name))
	shutil.copy(os.path.join(HERE, "threads_win32.h"), os.path.join(work, "shim", "threads.h"))

	path = os.path.join(work, "offsets", "windows.h")
	text = open(path, encoding="utf-8").read()
	newest = max(EXTRA_OFFSETS)
	lines = []
	for line in text.splitlines():
		if line.startswith("#define BYOND_MAX_BUILD"):
			current = int(line.split()[-1])
			line = f"#define BYOND_MAX_BUILD {max(current, newest)}"
		if line.strip() == "};":
			for build, offsets in sorted(EXTRA_OFFSETS.items()):
				if f"BYOND_VERSION_ADJUSTED({build})" not in text:
					lines.append(f"\t[BYOND_VERSION_ADJUSTED({build})] = {{{offsets}}},")
		lines.append(line)
	open(path, "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")

	target = os.path.join(args.out, "prof.dll")
	cmd = [args.zig, "cc", "-target", "x86-windows-gnu", "-std=c11", "-shared", "-O2", "-DNDEBUG", "-Ishim", "prof.c", "-lws2_32", "-o", target]
	print(" ".join(cmd))
	result = subprocess.run(cmd, cwd=work)
	if result.returncode:
		return result.returncode
	print(f"gotowe: {target}")
	shutil.rmtree(work, ignore_errors=True)
	return 0


if __name__ == "__main__":
	sys.exit(main())
