// Wybór silnika statku przez inżynierów (aquila/code/modules/mapping/engine_choice.dm)
#define ENGINE_CHOICE_RANDOM "random"
#define ENGINE_CHOICE_TESLA "tesla"
#define ENGINE_CHOICE_STORMDRIVE "stormdrive"
#define ENGINE_CHOICE_SUPERMATTER "supermatter"
#define ENGINE_CHOICE_HFR "hfr"
/// Tag preferowanego silnika w tabeli preferencji. Zapis i odczyt robi moduł, core go nie zna (jak PREFERENCE_TAG_GAME_LANGUAGE)
#define PREFERENCE_TAG_PREFERRED_ENGINE "91"
// Pola slotu silnika (GLOB.engine_choice_slots, engine_choice_snapshot())
#define ENGINE_SLOT_ORIGIN 1
#define ENGINE_SLOT_TEMPLATE 2
/// Słabe referencje obiektów, które stały na polach slotu przed wczytaniem szablonu (mapa bazowa)
#define ENGINE_SLOT_KEEP 3
/// Pole => list(typ turfu, baseturfs) z mapy bazowej, sprzed wczytania szablonu
#define ENGINE_SLOT_BASE_TURFS 4
