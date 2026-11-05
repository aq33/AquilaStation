# Sensory: ustalenia po MVP (lokalny draft)

Data: 2026-11-05. Status: **lokalny draft, bez PR.** Docelowo pójdzie do reworku walki i podziału DRADIS na konsole i role, w tym operatora radaru.

## Stan gałęzi `claude/aquilla-sensor-systems-176351`

Zrobione i zacommitowane lokalnie (`8bfe8837ee`):

- `aquila/code/modules/overmap/sensor_signature.dm`:
  - sygnatura okrętu: masa, ciąg, tłumiki, ogień, uszkodzenia, pożar;
  - zasięg wykrycia dla graczy i AI;
  - nadpisanie `is_sensor_visible`;
  - przełącznik admina.
- `aquila/code/modules/overmap/dradis_uncertainty.dm`:
  - niepewne kontakty w danych DRADIS;
  - kontakt „Źródło ostrzału”;
  - ostrzeżenie o namiarze w PvP.
- `aquila/code/modules/unit_tests/aquila_sensor_signature.dm`: test przechodzi lokalnie.

Niezrobione:
- `Dradis.tsx`: kontakty dostają już pole `uncertainty`, ale interfejs go jeszcze nie rysuje;
- zestaw komory testowej;
- wpisy na wiki.

## Ustalenia z makiet

### Sensory kosztują moc i sygnaturę
Każdy włączony sensor zużywa moc konsoli i podnosi sygnaturę okrętu. Wartości są do testów.

| Sensor | Moc | Sygnatura | Po wyłączeniu |
|---|---|---|---|
| Radar pasywny | 2 kW | +0,05 | nie widać okrętów, które nadają radarem lub oznaczają; profil traci pasma EM i radaru |
| IR | 1 kW | +0,10 | brak wykrywania po cieple; profil prawie bezużyteczny |
| Optyka | 0,5 kW | +0,02 | brak gwarantowanego zasięgu 15 pól |
| Impuls radarowy | 10 kW jednorazowo | maksimum przez 5 s | (akcja, nie sensor) |

Wszystko wyłączone daje „cichą jazdę”: okręt jest prawie niewidoczny i prawie ślepy. AI ma sensory zawsze włączone.

### Identyfikacja przez dopasowanie wzorca
Inspiracja z opisu użytkownika gry S.O.N.A.R. (szczegółów gry nie weryfikowałem).

- Kontakt ma profil w 8 pasmach: niskie i wysokie IR, emisje EM, radar.
- Profil to wzorzec klasy celu z szumem. Szum rośnie z odległością i ze słabym sygnałem, a znika przy impulsie radaru.
- Bez IR albo bez radaru pasywnego brakuje części pasm.
- Operator nakłada na profil wzorce z katalogu i przypisuje klasę. Gra nie pokazuje procentu dopasowania i nie mówi, czy trafił.
- Przypisaną klasę widzą działonowy i pilot.
- Prawda wychodzi w zasięgu identyfikacji, a wtedy błędne oznaczenie zostaje poprawione.
- Przy małej liczbie graczy identyfikacja z bliska działa sama. Dopasowanie daje tylko przewagę czasu i dystansu.
- Katalog: jeden wzorzec na klasę (fregata, niszczyciel, krążownik, frachtowiec, kuter piracki, okręty z nazwą), nie na każdy typ okrętu.
- Docelowo panel trafi do konsoli operatora radaru.

### Ślad kontaktu jako obiekt (pod walkę na odległość)
Dziś namiar to referencja do okrętu z tego samego systemu (`overmap.dm:657`). Przy walce na odległość, np. rakietami z innego systemu, strzela się do **śladu**, czyli do tego, co sensory wiedzą o celu.

`/datum/sensor_track` (para obserwator–cel) przechowuje:
- ostatnią znaną pozycję i jej wiek;
- niepewność pozycji (zastępuje `sensor_offsets` i `hit_ghosts`);
- kanały wykrycia;
- klasę przypisaną przez operatora;
- jakość śladu.

Ślad żyje dalej, gdy cel zniknie z sensorów: starzeje się i jego niepewność rośnie.

Co to daje w przyszłości:
- **Strzał do śladu:** rakieta leci w ostatnią znaną pozycję. Starszy i słabszy ślad oznacza większy rozrzut.
- **Głowica samonaprowadzająca na końcu lotu:** po dolocie rakieta sama musi złapać cel. Zimny okręt, który zmienił kurs, może jej uniknąć. Kontrą są istniejące wabiki i tryb przeciwrakietowy.
- **Ślady z innego systemu** przychodzą przez łącze danych od zwiadowcy, sojusznika albo boi sensorowej.
- **Operator radaru** decyduje, czy ślad jest dość dobry, żeby wydać na niego rakietę.
- **Obrona:** cicha jazda, zmiana kursu po wykryciu odpalenia, niszczenie zwiadowców.

## Kolejność pod rework

1. `/datum/sensor_track` w miejsce list `sensor_offsets` / `hit_ghosts`.
2. Przełączniki sensorów (moc i sygnatura) oraz ich wpływ na wykrywanie.
3. Profile, katalog wzorców i przypisywanie klasy.
4. TGUI według makiety (osobna konsola operatora radaru, gdy będzie podział).
5. Strzał do śladu i głowice samonaprowadzające.
