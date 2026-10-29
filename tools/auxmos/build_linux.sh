#!/usr/bin/env bash
# Builds libauxmos.so for the Debian server and puts it in the repo root, where server_watchdog.sh loads it from.
# Upstream auxmos v$AUXMOS_VERSION with the same features as its Linux release (katmos), plus the crash fixes:
#   byondapi-0.4.7-lasterror.patch    Byond_LastError() crashes BYOND 516 on Linux, errors no longer call it
#   auxmos-2.5.2-b-stale-turf.patch   queued visuals/reaction callbacks skip a turf that has become a wall
# The reboot patches (auxmos-2.5.2-b.patch, byondapi-0.4.7.patch) are left out: the watchdog starts
# a new DreamDaemon every round, so the library is never unloaded under a running process here.
#
# Needs: apt install git curl build-essential g++-multilib libclang-dev, and rustup (https://rustup.rs).
# Options: --work /path (build folder, default /tmp/aquila-auxmos), --no-install (only build, do not copy).
set -euo pipefail

Work="/tmp/aquila-auxmos"
Install=1
while [ $# -gt 0 ]; do
	case "$1" in
		--work) Work="$2"; shift 2 ;;
		--no-install) Install=0; shift ;;
		*) echo "Unknown option: $1"; exit 1 ;;
	esac
done

Root="$(cd "$(dirname "$0")/../.." && pwd)"
Patches="$Root/tools/auxmos"
. "$Root/dependencies.sh"
Toolchain="1.80.0"
ByondapiVersion="0.4.7"
Target="i686-unknown-linux-gnu"

if ! command -v rustup >/dev/null 2>&1; then
	echo "rustup not found. Install it with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
	exit 1
fi
rustup toolchain install "$Toolchain" --profile minimal --target "$Target"

rm -rf "$Work"
mkdir -p "$Work"
git clone --quiet --depth 1 --branch "v$AUXMOS_VERSION" https://github.com/covertcorvid/auxmos "$Work/auxmos"
curl -sSfL "https://static.crates.io/crates/byondapi/byondapi-$ByondapiVersion.crate" | tar -xz -C "$Work"

(cd "$Work/byondapi-$ByondapiVersion" && git apply "$Patches/byondapi-$ByondapiVersion-lasterror.patch")
(cd "$Work/auxmos" && git apply "$Patches/auxmos-$AUXMOS_VERSION-stale-turf.patch")
# The patched byondapi lives next to auxmos, outside its workspace
printf '\n[patch.crates-io]\nbyondapi = { path = "../byondapi-%s" }\n' "$ByondapiVersion" >> "$Work/auxmos/Cargo.toml"

(cd "$Work/auxmos" && cargo "+$Toolchain" build --target "$Target" --release --features katmos)

Built="$Work/auxmos/target/$Target/release/libauxmos.so"
echo "Built $Built"
if [ "$Install" = 1 ]; then
	cp "$Built" "$Root/libauxmos.so"
	echo "Installed to $Root/libauxmos.so. Restart the server to load it (git checkout libauxmos.so brings back the old one)."
fi
