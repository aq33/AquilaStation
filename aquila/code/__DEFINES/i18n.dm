// Język gry gracza (preferencja game_language), zob. aquila/code/modules/i18n/
#define GAME_LANGUAGE_PL "pl"
#define GAME_LANGUAGE_EN "en"
/// Tag języka gry w tabeli preferencji. Zapis i odczyt robi moduł (game_language.dm), core go nie zna,
/// więc numer jest daleko od kolejnych tagów core (code/__DEFINES/preferences.dm, teraz do 33)
#define PREFERENCE_TAG_GAME_LANGUAGE "90"
