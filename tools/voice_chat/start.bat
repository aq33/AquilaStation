@echo off
rem Uruchamia Whispera (whisper-server z whisper.cpp) i serwis czatu głosowego.
rem Ścieżki zmień pod swój komputer. Sekret musi się zgadzać z VOICE_CHAT_SECRET w config\voice_chat.txt.
chcp 65001 >nul

set WHISPER_BIN=C:\msys64\ucrt64\bin
set WHISPER_MODEL=%USERPROFILE%\whisper-models\ggml-large-v3.bin
set WHISPER_PORT=8178
set VOICE_PORT=8179
if "%VOICE_CHAT_SECRET%"=="" set VOICE_CHAT_SECRET=test_lokalny

if not exist "%WHISPER_MODEL%" (
	echo Brak modelu Whispera: %WHISPER_MODEL%
	echo Pobierz go: https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin
	pause
	exit /b 1
)

start "Whisper" /min "%WHISPER_BIN%\whisper-server.exe" -m "%WHISPER_MODEL%" -l pl --host 127.0.0.1 --port %WHISPER_PORT%
python -u "%~dp0voice_server.py" --port %VOICE_PORT% --whisper http://127.0.0.1:%WHISPER_PORT% --secret %VOICE_CHAT_SECRET%
