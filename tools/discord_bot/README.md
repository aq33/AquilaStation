# Bot wojny na Discorda

Komenda `/wojna` pokazuje stan wojny frakcji w kampanii: ile układów i flot ma każda frakcja, kto trzyma kwatery
główne, zajęte układy, DEFCON, głowice atomowe, dowódców i nemezis, ostatnie położenie okrętu załogi.

Komenda `/mapa` wysyła obrazek mapy: trzy sektory hex z terenem, układy w kolorach frakcji, które je trzymają,
kwatery główne (biała ramka: zajęta przez wroga) i okręt załogi. Nieodkryte układy i floty nie są rysowane.

Bot działa poza grą. Czyta tylko pliki `config/starmap/hexmap.json` i `starmap.json`, które serwer zapisuje na koniec
rundy (i przy restarcie). Nie łączy się z serwerem i nie pokazuje stanu na żywo, tylko stan z ostatniego zapisu
(data w stopce). Pozycji flot nie podaje, żeby nie odkrywać graczom mgły wojny.

## Uruchomienie

1. W [Discord Developer Portal](https://discord.com/developers/applications) załóż aplikację, w zakładce Bot skopiuj
   token. Bota dodaj na serwer linkiem z OAuth2 → URL Generator, zakres `bot` i `applications.commands`
   (uprawnienia nie są potrzebne).
2. Na maszynie z serwerem gry:

   ```
   pip install -r tools/discord_bot/requirements.txt
   set DISCORD_TOKEN=<token>
   set DISCORD_GUILD_ID=<id serwera Discorda>
   python tools/discord_bot/bot.py
   ```

`DISCORD_GUILD_ID` jest opcjonalny: z nim komenda pojawia się od razu, bez niego Discord rozsyła ją globalnie z
opóźnieniem. Gdy serwer gry działa w innym folderze, wskaż go zmienną `AQUILA_STARMAP_DIR`
(folder z `hexmap.json`).

Tokenu nie wpisuj do repozytorium.

## Podgląd bez Discorda

```
python tools/discord_bot/war_status.py [folder z hexmap.json]
python tools/discord_bot/war_map.py [folder z hexmap.json] [plik.png]
```

Pierwsze wypisuje w terminalu to samo, co `/wojna`, drugie zapisuje obrazek z `/mapa`.

Stałe (kwatery, progi DEFCON, stopnie dowódców, wymiary siatki hex) są skopiowane z `aquila/code/modules/overmap/hexmap/`. Po ich
zmianie w grze popraw je w `war_status.py` i `war_map.py`.
