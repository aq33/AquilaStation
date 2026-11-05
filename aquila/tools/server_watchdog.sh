#!/usr/bin/env bash
# Linux (Debian) counterpart of server_watchdog.ps1, same rules:
# runs DreamDaemon and starts it again after every round restart.
# A round restart (/world/Reboot) leaves data/watchdog_restart; the watchdog then kills the process,
# because a BYOND 516 soft reboot hangs for minutes, and starts a fresh one.
# If DreamDaemon exits without the marker (normal shutdown) or Ctrl+C is pressed, the watchdog ends too.
# Options: --port 1337, --byond-bin /path/to/byond/bin (or the BYOND_BIN variable).
set -uo pipefail

Port=1337
ByondBin="${BYOND_BIN:-}"
while [ $# -gt 0 ]; do
	case "$1" in
		-p|--port|-Port) Port="$2"; shift 2 ;;
		-b|--byond-bin|-ByondBin) ByondBin="$2"; shift 2 ;;
		*) echo "Unknown option: $1"; exit 1 ;;
	esac
done

Root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$Root"
Marker="$Root/data/watchdog_restart"
. ./dependencies.sh

if [ -z "$ByondBin" ]; then
	for dir in \
		"$Root/tools/bootstrap/.cache/byond-$BYOND_MAJOR.$BYOND_MINOR/byond/bin" \
		"$HOME/BYOND/byond/bin" \
		"/usr/local/byond/bin" \
		"$(dirname "$(command -v DreamDaemon 2>/dev/null || echo .)")"; do
		if [ -x "$dir/DreamDaemon" ]; then ByondBin="$dir"; break; fi
	done
fi
DD="$ByondBin/DreamDaemon"
if [ ! -x "$DD" ]; then
	echo "DreamDaemon not found. Run ./BUILD.sh first or pass --byond-bin <BYOND bin folder>."
	exit 1
fi
if [ ! -f "$Root/nsv13.dmb" ]; then
	echo "nsv13.dmb not found. Run ./BUILD.sh first."
	exit 1
fi
if [ ! -f "$Root/librust_g.so" ] && [ ! -f "$HOME/.byond/bin/librust_g.so" ]; then
	echo "librust_g.so not found. Run aquila/tools/debian_setup.sh first."
	exit 1
fi

# libbyond.so sits next to DreamDaemon, libauxmos.so in the repo root.
export LD_LIBRARY_PATH="$ByondBin:$Root:$HOME/.byond/bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export AQUILA_WATCHDOG=1

DDPid=""
stop_dd() {
	if [ -n "$DDPid" ] && kill -0 "$DDPid" 2>/dev/null; then
		kill "$DDPid" 2>/dev/null
		for _ in 1 2 3 4 5; do
			kill -0 "$DDPid" 2>/dev/null || break
			sleep 1
		done
		kill -9 "$DDPid" 2>/dev/null
	fi
	[ -n "$DDPid" ] && wait "$DDPid" 2>/dev/null
}
trap 'echo "[$(date +%T)] Stopping, watchdog ends."; rm -f "$Marker"; stop_dd; exit 0' INT TERM

while true; do
	rm -f "$Marker"
	echo "[$(date +%T)] Starting DreamDaemon on port $Port"
	"$DD" "$Root/nsv13.dmb" "$Port" -trusted &
	DDPid=$!
	while kill -0 "$DDPid" 2>/dev/null && [ ! -f "$Marker" ]; do sleep 1; done
	if [ ! -f "$Marker" ]; then
		wait "$DDPid" 2>/dev/null
		echo "[$(date +%T)] DreamDaemon stopped without a restart request, watchdog ends."
		break
	fi
	echo "[$(date +%T)] Round restart requested, restarting DreamDaemon"
	sleep 1 # let the world finish writing its logs
	stop_dd
done
