# Czat głosowy

Gracz trzyma klawisz w grze i mówi, a jego postać wypowiada rozpoznany tekst (zwykła mowa albo radio).

## Jak to działa

1. W grze: zakładka OOC → **Czat głosowy**. Gra otwiera w zwykłej przeglądarce gracza stronę z tokenem.
2. Strona prosi o mikrofon (raz, przeglądarka to zapamiętuje). Kartę zostawia się otwartą.
3. Klawisz **N** (mowa), **U** (radio, kanał ogólny jak `;`) albo **J** (kanał działu jak `:h`): wciśnięcie mówi stronie „nagrywaj”, puszczenie „stop”.
4. Strona wysyła nagranie (WAV 16 kHz) do `voice_server.py`, ten do Whispera, a tekst wraca do gry i postać go mówi.

Mikrofon nie działa w oknach samego BYOND: Dream Seeker 516 odrzuca prośbę o mikrofon bez pytania
(sprawdzone testem, `raport/glos_01_rozpoznanie.md`). Stąd strona w zwykłej przeglądarce.

Gra rozmawia z serwisem tylko przez `POST /api/sync` (lista sesji graczy obecnych na serwerze, polecenia start/stop,
odbiór tekstu), więc działa także, gdy serwis stoi na innej maszynie (patrz „Serwer gry na innej maszynie”).
Strona może wysłać nagranie tylko wtedy, gdy gra o nie poprosiła (gracz trzymał klawisz).

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

`voice_server.py --backend elevenlabs` (Scribe v2) albo `--backend openai` (gpt-4o-transcribe). Klucz ze zmiennej
`ELEVENLABS_API_KEY` / `OPENAI_API_KEY` albo z pliku `--api-key-file` (`NAZWA=wartość` albo sam klucz).
`--keyterms-file keyterms.txt` podaje ElevenLabs słownictwo gry (+20% ceny). Gdy chmura nie odpowiada,
serwis używa lokalnego Whispera. `start.bat` sam wybiera ElevenLabs, jeśli istnieje `%USERPROFILE%\whisper-models\klucze.txt`.

Na 12 nagraniach z gry (błędne słowa / czas): lokalny large-v3 10% / 0,26 s, ElevenLabs Scribe v2 7% / 0,7 s,
Scribe v2 ze słowami z gry 3% / 0,9 s. Nagrania głosu idą wtedy do zewnętrznej firmy.

Nagrania głosu idą wtedy do zewnętrznej firmy, więc strona przed włączeniem mikrofonu pokazuje graczowi,
do kogo trafia nagranie (z linkiem do zasad przetwarzania danych), i włącza mikrofon dopiero po zgodzie.
Zgoda jest zapamiętana w przeglądarce, można ją cofnąć na stronie. Serwis sprawdza ją przy każdym nagraniu
(`consent` w `/audio`) i bez niej nic nie wysyła. Strona pyta o dostawcę przez `GET /info`
(też: czy włączone jest `--save-dir`, wtedy strona to pokazuje).

## Zachowanie

- Tekst przechodzi przez zwykłe `say` (języki postaci, filtry, logi).
- Nagrywanie zaczyna tylko fizycznie wciśnięty klawisz: bind sprawdza `keys_held` klienta, a podsystem, sesje graczy
  i bindy głosu są zablokowane przed VV i Advanced ProcCall (`GENERAL_PROTECT_DATUM`), więc nikt nie włączy mikrofonu
  ani nie podejrzy tokenów z poziomu gry. Kto ma sekret `/api/sync`, nadal może sterować stronami, więc sekret trzymaj
  tylko na serwerze gry i w usłudze.
- Strona daje krótki dźwięk przy starcie nagrania (można wyłączyć na stronie).
- Przy wyłączonym czacie (`VOICE_CHAT_ENABLED` zakomentowane) klawisze N/U/J nic nie robią, a komendy OOC nie ma.
- Wciśnięcie krótsze niż 0,3 s jest anulowane, nagranie najdłużej `VOICE_CHAT_MAX_SECONDS` (domyślnie 15 s).
- Cisza nie jest wysyłana do Whispera, a typowe zmyślenia Whispera na ciszy („Napisy stworzone przez społeczność Amara.org” itp.) są odrzucane.
- Tokeny graczy są w `data/voice_chat_tokens.json`, więc otwarta karta działa też w kolejnej rundzie.
  Token nieużywany przez 30 dni wygasa, a każde kliknięcie „Czat głosowy” daje nowy link i unieważnia stary
  (wyjątek: strona otwarta mniej niż 30 s temu, która jeszcze się łączy). Link w czacie jest schowany pod słowem „link”.
- Na jeden token działa jedna karta. Nowa karta z tym samym linkiem odłącza starą, gra ostrzega gracza,
  a nagranie serwis przyjmuje tylko od bieżącej karty. Zamknięcie albo odświeżenie karty zwalnia połączenie od razu (`/bye`).
- Strona łączy się z grą dopiero z działającym mikrofonem, więc „Czat głosowy połączony” znaczy, że nagrywanie działa.
- Klawisze głosu działają też z wciśniętym Shiftem (sprint), Ctrl albo Alt. Klawisze N/U/J są dopisywane graczowi raz
  (`data/offered_keybinds.json`); usunięte w Preferencjach nie wracają.
- Klawisz mówienia bez połączonej strony otwiera ją najwyżej raz na minutę i tylko temu, kto już z niej korzystał.
  Pozostali dostają podpowiedź w czacie.
- Pojedynczy błąd `/api/sync` (np. restart serwisu) nie rozłącza graczy: polecenia wracają do kolejki,
  a strony są uznawane za rozłączone dopiero po trzech błędach z rzędu.

## Diagnostyka

`voice_server.py --save-dir <folder>` zapisuje każde nagranie (WAV) i surowy tekst Whispera, żeby porównywać modele i ustawienia na prawdziwych głosach.

## Wdrożenie na VPS (Linux)

Pliki w `deploy/`: `Caddyfile` (HTTPS i ukrycie `/api` przed internetem), `aquila-voice.service` (systemd), `env.example`.

1. Domena (np. DuckDNS) wskazuje na IP serwera, porty 80 i 443 otwarte (Let's Encrypt potrzebuje 80).
2. `sudo mkdir -p /etc/aquila-voice`, skopiuj `env.example` jako `/etc/aquila-voice/env`, wpisz sekret
   (`openssl rand -hex 32`) i klucz ElevenLabs, `sudo chmod 600 /etc/aquila-voice/env`.
3. Popraw ścieżki i użytkownika w `aquila-voice.service`, skopiuj do `/etc/systemd/system/`,
   `sudo systemctl daemon-reload && sudo systemctl enable --now aquila-voice`.
4. Dopisz blok z `deploy/Caddyfile` do `/etc/caddy/Caddyfile` (z wpisaną domeną), `sudo systemctl reload caddy`.
5. `config/voice_chat.txt` serwera gry: `VOICE_CHAT_ENABLED`, `VOICE_CHAT_PUBLIC_URL https://twoja.domena`,
   `VOICE_CHAT_SECRET` taki sam jak w `env`. `VOICE_CHAT_SERVICE_URL` zostaje `http://127.0.0.1:8179`.
6. Sprawdzenie: `curl https://twoja.domena/health` daje `{"ok": true}`, a `curl https://twoja.domena/api/sync` daje 404.

### Serwer gry na innej maszynie niż serwis

Serwis zostaje na `127.0.0.1` za Caddy, a `/api` przepuszczamy tylko z adresu IP serwera gry:

1. W `Caddyfile` zamień `@api path /api/*` na wariant z `not remote_ip` (zakomentowany w pliku) z IP serwera gry.
2. W `config/voice_chat.txt` serwera gry: `VOICE_CHAT_SERVICE_URL https://twoja.domena` (sekret idzie wtedy przez HTTPS).
3. Sprawdzenie z serwera gry: `curl -X POST -H "X-Voice-Secret: <sekret>" https://twoja.domena/api/sync` daje JSON z `status`,
   a z innego komputera 404.

Sekret najlepiej z `openssl rand -hex 32`. Polskie litery w sekrecie działają, ale nie ma po co ich używać.

Bez karty graficznej na serwerze lokalny Whisper będzie za wolny, więc VPS używa ElevenLabs. Gdy ElevenLabs
nie odpowiada, gracz dostaje komunikat „rozpoznawanie mowy nie odpowiada”.
