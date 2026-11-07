// Język gry gracza (preferencja game_language), zob. aquila/code/modules/i18n/
#define GAME_LANGUAGE_PL "pl"
#define GAME_LANGUAGE_EN "en"
/// Tag języka gry w tabeli preferencji. Zapis i odczyt robi moduł (game_language.dm), core go nie zna,
/// więc numer jest daleko od kolejnych tagów core (code/__DEFINES/preferences.dm, teraz do 33)
#define PREFERENCE_TAG_GAME_LANGUAGE "90"

// Obcokrajowiec i tłumacz (aquila/code/modules/i18n/foreigner.dm, translation_api.dm)
/// Gracz ma przy sobie tłumacza (źródło: REF przedmiotu)
#define TRAIT_AQ_TRANSLATOR "aq_translator"
/// Źródło języków nadanych obcokrajowcowi przy spawnie
#define LANGUAGE_FOREIGNER "foreigner"
/// Źródło Angielskiego rozumianego dzięki tłumaczowi
#define LANGUAGE_TRANSLATOR "translator"
/// Kody języków DeepL
#define DEEPL_LANG_PL "PL"
#define DEEPL_LANG_EN "EN"
/// DeepL przyjmuje "EN" tylko jako język źródłowy, docelowy musi mieć wariant
#define DEEPL_LANG_EN_TARGET "EN-GB"
