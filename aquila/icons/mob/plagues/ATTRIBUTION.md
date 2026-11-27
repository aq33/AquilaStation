# Źródła sprite'ów plag z mapy FTL (`aquila/icons/mob/plagues/`)

Stany przeniesione bez zmian rysunku (kod: `aquila/code/modules/events/hexmap/space_hog.dm`, `abominable_infestation.dm`, `mimite_infestation.dm`).

| Plik / stany u nas | Źródło | Plik i stany w źródle | Licencja |
|---|---|---|---|
| `plagues.dmi`: `hog_overgreased`, `hog_overgreased_dead` | vgstation-coders/vgstation13 (a60da86) | `icons/mob/hog.dmi`, te same stany | CC BY-SA 3.0 |
| `plagues.dmi`: `larva`, `larva_dead`, `larva_implanter`, `broodling`, `broodling_dead` | vlggms/tegustation-bay12 (822d405) | `icons/mob/simple_animal/abominable_infestation/32x32.dmi`, te same stany | CC BY-SA 3.0 |
| `plagues.dmi`: `mimite` | BeeStation/BeeStation-Hornet (64960b4) | `icons/mob/animal.dmi`, ten sam stan | CC BY-SA 3.0 |

`larva` i `larva_implanter` mają po dwa stany o tej samej nazwie: zwykły (1 klatka) i stan ruchu (`movement = 1`, 6 klatek),
który BYOND pokazuje, gdy mob idzie. To nie duplikaty, tylko para stoi/idzie jak w źródle.

Licencje według README i LICENSE repozytoriów (sprawdzone 27.11.2026):
- assety (ikony, dźwięki) wszystkich trzech repozytoriów: [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/),
  „o ile nie zaznaczono inaczej”; przy przeniesionych plikach nie ma innego oznaczenia (w folderze
  `icons/mob/simple_animal/abominable_infestation/` tegustation-bay12 są same pliki `.dmi`, bez osobnej licencji);
- kod vgstation13: GPLv3 (kod sprzed commita 8cfadfbf z 9.11.2024; późniejszy jest na AGPLv3);
- kod tegustation-bay12 (fork Baystation12): AGPLv3 (kod sprzed 8.01.2015 GPLv3);
- kod BeeStation-Hornet: AGPLv3.
