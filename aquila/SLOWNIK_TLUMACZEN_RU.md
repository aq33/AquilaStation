# Słownik tłumaczeń Aquili: wersja rosyjska

Zasady i terminy dla rosyjskiej wersji językowej (`strings/i18n/ru_*.json`, moduł `aquila/code/modules/i18n/`).
Polski słownik (`SLOWNIK_TLUMACZEN.md`) zostaje nadrzędny dla tekstów w kodzie; ten plik mówi tylko, jak oddać je po rosyjsku.
Terminy wzięte z rosyjskich serwerów (SS220 BandaStation i Paradise, White, SS14 Corvax), żeby gracze z tych serwerów znali nazwy.

## 1. Zasady

1. **Źródłem jest polski tekst z kodu (klucz słownika), a angielski oryginał to kontekst.** Gdy polski tekst jest tłumaczeniem angielskiego oryginału, oddaj sens oryginału; gdy Aquila zmieniła treść (statek zamiast stacji, hardsuit zamiast MODsuitu, dopisane informacje), tłumacz polską wersję.
2. **Wstawki zostają co do znaku.** `[user]`, `[src]`, `${data.name}` i każde inne wyrażenie kopiujesz bez zmian, kolejność wolno zmienić. Wyjątek: w warunku z dwoma napisami (`[gender == FEMALE ? "aś" : "eś"]`) tłumaczysz same napisy, warunek zostaje.
3. **Wstawka daje mianownik.** Imion i nazw wstawianych w zdanie nie odmienia się, więc zdanie układaj tak, żeby pasował mianownik (np. „Цель: [target]”, „[user] бьёт — [target]” zamiast formy wymagającej biernika). Gdy się nie da, zostaw mianownik.
4. **Do gracza na „вы”**, małą literą w środku zdania, jak na serwerach SS220: «Вы поднимаете [I].», «Ваша рука немеет!». Instrukcje i przyciski w trybie rozkazującym: «Нажмите», «Используйте».
5. **Czas teraźniejszy** jak w polskim. Czas przeszły po rosyjsku ma rodzaj; jeśli trzeba, forma męska.
6. **HTML, `\n`, `\t`, makra `\improper` i `\proper` zostają** w tych samych miejscach. Znak końcowy (`.`, `!`, `...`) jak w polskim.
7. **Wielkie litery jak w polskim:** przedmioty małą literą (`гаечный ключ`), obszary Każdym Wyrazem Wielkim (`Мостик`, `Инженерный Отсек`), role i statusy z wielkiej pierwszej litery.
8. **Nanotrasen, Syndykat i nazwy frakcji** w formie z rosyjskich serwerów (tabela niżej). Polskie marki i nazwy własne Aquili spolszczone brzmieniowo zapisuj cyrylicą brzmieniowo (`Орлен`, `ИнПост`, `Бедронка`).
9. Cudzysłowy «ёлочки», myślnik ` — `. Litera „ё” tam, gdzie jest w słowniku (не обязательно wszędzie).

## 2. Terminy

| polski (kod) | angielski | rosyjski |
|---|---|---|
| statek | ship | корабль |
| stacja | station | станция |
| załoga | crew | экипаж |
| zmiana, runda | shift, round | смена, раунд |
| Nanotrasen | Nanotrasen | Нанотрейзен |
| Syndykat | Syndicate | Синдикат |
| Centrala, CentCom | Central Command, CentCom | Центральное командование, ЦК |
| Kapitan | Captain | Капитан |
| Kierownik Personelu | Head of Personnel | Глава персонала |
| Szef Ochrony | Head of Security | Глава службы безопасности |
| Główny Inżynier | Chief Engineer | Старший инженер |
| Dyrektor Badań | Research Director | Научный руководитель |
| Ordynator | Chief Medical Officer | Главный врач |
| Kwatermistrz | Quartermaster | Квартирмейстер |
| Oficer Ochrony | Security Officer | Офицер службы безопасности |
| Naczelnik | Warden | Смотритель |
| Detektyw | Detective | Детектив |
| Inżynier | Station Engineer | Инженер |
| Technik Atmosferyczny | Atmospheric Technician | Атмосферный техник |
| Lekarz | Medical Doctor | Врач |
| Chemik | Chemist | Химик |
| Genetyk | Geneticist | Генетик |
| Wirusolog | Virologist | Вирусолог |
| Naukowiec | Scientist | Учёный |
| Robotyk | Roboticist | Робототехник |
| Technik Zaopatrzenia | Cargo Technician | Грузчик |
| Górnik | Shaft Miner | Шахтёр |
| Barman | Bartender | Бармен |
| Kucharz | Cook | Повар |
| Botanik | Botanist | Ботаник |
| Woźny | Janitor | Уборщик |
| Klaun / Mim | Clown / Mime | Клоун / Мим |
| Kapelan | Chaplain | Священник |
| Kurator | Curator | Библиотекарь |
| Prawnik | Lawyer | Адвокат |
| Asystent | Assistant | Ассистент |
| Pilot | Pilot | Пилот |
| Technik Uzbrojenia | Munitions Technician | Техник вооружения |
| Mistrz Broni | Master At Arms | Мастер-оружейник |
| SI / cyborg | AI / cyborg | ИИ / киборг |
| Mostek | Bridge | Мостик |
| Inżynieria | Engineering | Инженерный отдел |
| Medyczny / ambulatorium | Medbay | Медотсек |
| Nauka | Science | Научный отдел |
| Zaopatrzenie | Cargo / Supply | Снабжение |
| Ochrona | Security | Служба безопасности (СБ) |
| Dowództwo | Command | Командование |
| Usługi | Service | Сервисный отдел |
| Uzbrojenie | Munitions | Вооружение |
| Policja / Żandarmeria | Police / Military Police | Полиция / Военная жандармерия |
| zdrajca | traitor | предатель |
| zmiennokształtny | changeling | генокрад |
| kultysta | cultist | культист |
| czarodziej | wizard | волшебник |
| agent nuklearny | nuclear operative | ядерный оперативник |
| rewolucjonista | revolutionary | революционер |
| łom | crowbar | лом |
| klucz francuski | wrench | гаечный ключ |
| śrubokręt | screwdriver | отвёртка |
| przecinak | wirecutters | кусачки |
| multitool | multitool | мультитул |
| spawarka | welding tool | сварочный аппарат |
| skrzynka narzędziowa | toolbox | ящик для инструментов |
| śluza | airlock | шлюз |
| śluza przeciwpożarowa | firelock | пожарный шлюз |
| APC | APC | ЛКП |
| alarm powietrza | air alarm | контроллер воздуха |
| alarm pożarowy | fire alarm | пожарная тревога |
| prom ewakuacyjny | emergency shuttle | эвакуационный шаттл |
| kapsuła ratunkowa | escape pod | спасательная капсула |
| plazma, tlen, azot | plasma, oxygen, nitrogen | плазма, кислород, азот |
| obrażenia fizyczne / oparzenia / toksyny / duszenie | brute / burn / toxin / oxy | механические / ожоги / токсины / удушье |
| wytrzymałość | stamina | выносливость |
| duch, obserwator | ghost, observer | призрак, наблюдатель |
| działo szynowe | railgun | рельсотрон |
| torpeda, pocisk | torpedo, missile | торпеда, ракета |
| myśliwiec | fighter | истребитель |
| napęd FTL | FTL drive | двигатель FTL |
| mapa sektora (overmap) | overmap | звёздная карта |
| frakcja | faction | фракция |
| tryb walki | combat mode | боевой режим |
| prawy przycisk / intencja rozbrajania | right click / disarm intent | правая кнопка / намерение обезоружить |
