#!/usr/bin/env bash
# One-time setup of a Debian (12 or newer) machine for BUILD.sh and server_watchdog.sh.
# BYOND on Linux is 32-bit, so it needs the i386 libraries. rust_g goes to ~/.byond/bin.
# Run it as the user that will run the server; it asks for sudo for the packages.
set -euo pipefail
cd "$(dirname "$0")/../.."

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

# Debian 13 renamed some libraries (t64), Debian 12 still has the old names.
pick() {
	for name in "$@"; do
		if apt-cache show "$name" >/dev/null 2>&1; then echo "$name"; return; fi
	done
	echo "$1"
}

$SUDO dpkg --add-architecture i386
$SUDO apt-get update
$SUDO apt-get install -y --no-install-recommends \
	ca-certificates curl wget unzip git \
	libc6:i386 libstdc++6:i386 zlib1g:i386 \
	"$(pick libcurl4t64:i386 libcurl4:i386)" \
	"$(pick libssl3t64:i386 libssl3:i386)"

bash tools/ci/install_rust_g.sh

# The repo's yt-dlp.exe runs only on Windows; the jukebox uses ./yt-dlp next to the game on Linux.
# Debian's yt-dlp package is too old for YouTube, so take the latest release. Running this again updates it.
curl -fL "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux" -o yt-dlp
chmod +x yt-dlp
echo "yt-dlp $(./yt-dlp --version)"

echo
echo "Done. Build with ./BUILD.sh, start the server with ./server_watchdog.sh"
