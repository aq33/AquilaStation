#!/bin/sh
# Linux (Debian) counterpart of BUILD.bat: builds TGUI and the DM code.
# Missing BYOND is downloaded into tools/bootstrap/.cache. First run aquila/tools/debian_setup.sh once.
set -e
cd "$(dirname "$0")"
. ./dependencies.sh

# Debian's nodejs package is older than the one the build is written for, so use the vendored Node then.
NodeMajor="$(node --version 2>/dev/null | sed 's/^v\([0-9]*\).*/\1/')"
if [ -z "$NodeMajor" ] || [ "$NodeMajor" -lt "$NODE_VERSION" ]; then
	export TG_BOOTSTRAP_NODE_LINUX=1
fi

exec tools/build/build build "$@"
