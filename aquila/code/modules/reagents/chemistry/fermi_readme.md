# Fermichem w Aquili

Mechanika reakcji z tg (tgstation@b3949ec362, „Fermichem 2.0”) przeniesiona na naszą chemię. Silnik reakcji jest prawie 1:1 z tg, a API reagentów (`on_mob_life`, `reaction_mob` itd.) zostało nasze.

## Jak działa reakcja

1. `handle_reactions()` (`code/modules/reagents/chemistry/holder.dm`) sprawdza przepisy pasujące do zawartości: składniki, katalizatory, pojemnik, `mob_react`, rdzeń slime (`required_other`), próg temperatury (`required_temp` / `is_cold_recipe`) i `pre_reaction_other_checks()`.
2. Reakcja jest **natychmiastowa**, jeśli przepis ma `REACTION_INSTANT`, nie ma produktów (`results`) albo holder ma flagę `REAGENT_HOLDER_INSTANT_REACT` (granaty, dym, piana, zgniatane rośliny). Wtedy `instant_react()` robi wszystko od razu, a ilość produktów mnoży się przez średnią czystość składników.
3. Pozostałe reakcje stają się `/datum/equilibrium` (`fermi/equilibrium.dm`) i holder trafia do `SSreagents` (co 0,25 s). W każdym kroku:
   - **szybkość** zależy od temperatury: zero poniżej `required_temp`, rośnie (krzywa `temp_exponent_factor`) do `optimal_temp`, dalej `rate_up_lim` jednostek na sekundę;
   - **czystość kroku** zależy od pH roztworu: 100% w oknie `optimal_ph_min`–`optimal_ph_max`, spada (krzywa `ph_exponent_factor`) w pasie `determin_ph_range`, a poza nim 0; jest mnożona przez średnią czystość zawartości;
   - reakcja **zmienia pH** (`H_ion_release` na jednostkę) i **temperaturę** (`thermic_constant`);
   - powyżej `overheat_temp` (poniżej przy `is_cold_recipe`) co krok woła się `overheated()`, a gdy produkt jest czystszy niż `purity_min` – `overly_impure()`. Domyślnie przegrzanie zmniejsza wydajność o 2% na krok, a nieczystość obniża czystość; przepisy z tg mają tu wybuchy, dym itd. (`fermi/recipe_effects.dm`).
4. Reakcja nie wystartuje, jeśli pH jest dalej niż `determin_ph_range` od okna optymalnego.

## Czystość i pH

- Każdy reagent ma `ph`, `purity` i `creation_purity`. pH holdera to średnia ważona objętością (`update_total()`).
- Czystość i pH przenoszą się przy `trans_to`, `copy_to`, `trans_id_to`, `multiply_reagents` i `convert_reagent`; przy łączeniu są uśredniane.
- Dispensery i inne źródła dają czystość 1.
- **W ciele** (holder z `REAGENT_HOLDER_ALIVE`, czyli każdy carbon): reagent o czystości poniżej `inverse_chem_val` zamienia się w całości w `inverse_chem` (`process_mob_reagent_purity()`). Domyślnie to `/datum/reagent/inverse` (Toxic Monomers), a kilkanaście naszych chemów ma własne odwrócenia z tg (`fermi/impure_reagents.dm`).
- Próg przedawkowania skaluje się z czystością przy wejściu do ciała (jak w tg).
- Nasze stare leki poza tym nie reagują na czystość. Lek, który ma działać mocniej przy wysokiej czystości, może użyć `creation_purity` albo `normalise_creation_purity()` jak w tg.

## Bufory i narzędzia

- **Bufory** (`/datum/reagent/reaction_agent/acidic_buffer`, `basic_buffer`) nie mieszają się z roztworem: przy przelaniu zużywają się i przesuwają pH (`intercept_reagents_transfer()`). Są też tester czystości, Tempomyocin (przyspiesza reakcję) i bufor odwracający.
- **Katalizatory** (`/datum/reagent/catalyst_agent`) zmieniają szybkość, zmianę pH albo ciepło reakcji, gdy jest ich w zlewce co najmniej `min_volume`.
- **Podgrzewacz** ma zapas buforów (zmapowane startują z 20 j. każdego) i pokazuje trwające reakcje, ich czystość i przegrzanie; po ulepszeniu laserów pokazuje więcej.
- **Komora reakcyjna** plumbingu (`/obj/machinery/plumbing/reaction_chamber/chem`) ma dwa wejścia na bufory (kwaśny z zachodu, zasadowy ze wschodu) i sama trzyma pH w zadanym zakresie. Nie spuszcza produktów, póki reakcja trwa.
- Książeczka z papierkami pH, analizator chemiczny (protolathe, „Technologia biologiczna”), butelki buforów w szafce chemika.

## Dane przepisów

- `fermi/fermi_data.dm` jest **generowany** skryptem `tools/fermichem/gen_fermi_data.py` z checkoutu tg. Nasz przepis dostaje parametry przepisu z tg o tej samej ścieżce, tych samych składnikach i produktach albo (ostatecznie) tych samych produktach. pH i `inverse_chem` reagentów też idą z tg.
- Przepisy bez odpowiednika w tg mają domyślne wartości tg. Drinki dostają wartości tg dla drinków, a typy bazowe (slime, eksplozje, jedzenie) są w `fermi/fermi_bases.dm`.
- Przepisy z własnym `on_reaction()` i produktami są natychmiastowe, bo ich efekty zakładają, że produkty już są.
- Losowane receptury (`randomized.dm`) losują też okno pH, optimum, przegrzanie i minimalną czystość, jak w tg.

## Dodawanie nowego przepisu

Ustaw zmienne jak w tg (domyślne są w `code/modules/reagents/chemistry/recipes.dm`). Dla reakcji z efektem (wybuch, przedmiot, mob) ustaw `reaction_flags = REACTION_INSTANT` albo nie dawaj produktów. Przy porcie przepisu z tg zostaw jego wartości bez zmian; tylko `on_reaction()` ma u nas dwa argumenty: `(holder, created_volume)`.

## Różnice względem tg

- API reagentów zostało nasze (tick zamiast `seconds_per_tick`, `reaction_mob` zamiast `expose_mob`).
- Nie ma tg-owych standardowych czystości 0,75 dla leków ani 0,5 dla jedzenia – wszystko zaczyna z czystością 1.
- Brak części odwróconych chemów, które wymagają systemów, których nie mamy (Corazargh, Monkey Dust, Cryogelidia i in.) – zostają przy Toxic Monomers.
- Granaty (`chem_splash`) i zgniatane rośliny z genem „Separated Chemicals” reagują od razu (`REAGENT_HOLDER_INSTANT_REACT`), bo ich holder i tak zaraz się rozpryskuje. W tg granat robi tylko reakcje natychmiastowe.
- Reakcje mogą się zaczynać przed startem rundy (tg ich wtedy nie robi), dokończą się po starcie `SSreagents`.
