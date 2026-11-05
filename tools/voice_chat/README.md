# Czat głosowy

Gracz trzyma klawisz w grze i mówi, a jego postać wypowiada rozpoznany tekst (zwykła mowa albo radio).

## Jak to działa

1. W grze: zakładka OOC → **Czat głosowy**. Gra otwiera w zwykłej przeglądarce gracza stronę z tokenem.
2. Strona prosi o mikrofon (raz, przeglądarka to zapamiętuje). Kartę zostawia się otwartą.
3. Klawisz **N** (mowa) albo **U** (radio): wciśnięcie mówi stronie „nagrywaj”, puszczenie „stop”.
4. Strona wysyła nagranie (WAV 16 kHz) do `voice_server.py`, ten do Whispera, a tekst wraca do gry i postać go mówi.

Mikrofon nie działa w oknach samego BYOND: Dream Seeker 516 odrzuca prośbę o mikrofon bez pytania
(sprawdzone testem, `raport/glos_01_rozpoznanie.md`). Stąd strona w zwykłej przeglądarce.

Gra rozmawia z serwisem tylko przez `POST /api/sync` (lista sesji, polecenia start/stop, odbiór tekstu),
więc działa także, gdy serwis stoi na innej maszynie. Strona może wysłać nagranie tylko wtedy,
gdy gra o nie poprosiła (gracz trzymał klawisz).

## Uruchomienie lokalne (test)

1. Whisper: `pacman -S mingw-w64-ucrt-x86_64-whisper.cpp` w MSYS2 (ma backend Vulkan, działa na kartach AMD i NVIDIA)
   i model `ggml-large-v3.bin` (3,1 GB) w `%USERPROFILE%\whisper-models\`.
   Na nagraniach z gry pełny large-v3 mylił 10% słów, turbo 16% (0,2 s i 0,13 s na zdanie na RX 9070 XT).
2. `tools\voice_chat\start.bat` (whisper-server na porcie 8178, serwis na 8179).
3. W `config\voice_chat.txt` odkomentuj `VOICE_CHAT_ENABLED` i ustaw ten sam `VOICE_CHAT_SECRET` co w `start.bat`.
4. Restart serwera gry.

Mikrofon w przeglądarce działa bez HTTPS tylko pod `localhost`, więc test lokalny działa dla gracza
na tym samym komputerze. Dla innych graczy `VOICE_CHAT_PUBLIC_URL` musi być adresem HTTPS
(np. reverse proxy Caddy/nginx przed portem 8179).

## Rozpoznawanie w chmurze

`voice_server.py --backend openai` (gpt-4o-transcribe, klucz w `OPENAI_API_KEY`) albo `--backend elevenlabs`
(Scribe, klucz w `ELEVENLABS_API_KEY`). `--model` zmienia model dostawcy. Nagrania idą wtedy do zewnętrznej firmy.

## Zachowanie

- Tekst przechodzi przez zwykłe `say` (języki postaci, filtry, logi).
- Wciśnięcie krótsze niż 0,3 s jest anulowane, nagranie najdłużej `VOICE_CHAT_MAX_SECONDS` (domyślnie 15 s).
- Cisza nie jest wysyłana do Whispera, a typowe zmyślenia Whispera na ciszy („Napisy stworzone przez społeczność Amara.org” itp.) są odrzucane.
- Tokeny graczy są w `data/voice_chat_tokens.json`, więc otwarta karta działa też w kolejnej rundzie.

## Diagnostyka

`voice_server.py --save-dir <folder>` zapisuje każde nagranie (WAV) i surowy tekst Whispera, żeby porównywać modele i ustawienia na prawdziwych głosach.
