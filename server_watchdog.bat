@echo off
rem Starts the server under the watchdog: it boots again by itself after a round restart, but not after a normal shutdown.
rem Options: -Port 1337, -ByondBin "C:\path\to\BYOND\bin". See aquila\tools\server_watchdog.ps1.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0aquila\tools\server_watchdog.ps1" -Port 2000 %*

