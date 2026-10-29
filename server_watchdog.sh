#!/bin/sh
# Linux (Debian) counterpart of server_watchdog.bat: starts the server under the watchdog.
# It boots again by itself after a round restart, but not after a normal shutdown.
# Options: --port 1337, --byond-bin /path/to/byond/bin. See aquila/tools/server_watchdog.sh.
exec bash "$(dirname "$0")/aquila/tools/server_watchdog.sh" --port 2137 "$@"
