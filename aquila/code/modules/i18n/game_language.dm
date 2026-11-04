// Język gry wybierany w preferencjach (etap 1 angielskiej wersji językowej).
// Na razie to sam wybór: tłumaczenie czatu, okien tgui i examine przyjdzie w kolejnych etapach.
// Słownik PL -> EN buduje tools/i18n/extract_pairs.py (strings/i18n/en_pairs.json).

#define GAME_LANGUAGE_PL "pl"
#define GAME_LANGUAGE_EN "en"

GLOBAL_LIST_INIT(game_languages, list(GAME_LANGUAGE_PL, GAME_LANGUAGE_EN))

/datum/preferences
	/// Język interfejsu gracza (GAME_LANGUAGE_PL / GAME_LANGUAGE_EN), zapisywany pod PREFERENCE_TAG_GAME_LANGUAGE
	var/game_language = GAME_LANGUAGE_PL

/datum/preference/choiced/game_language
	db_key = "game_language"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "game_language"

/datum/preference/choiced/game_language/init_possible_values()
	return GLOB.game_languages.Copy()

/datum/preference/choiced/game_language/get_display_names()
	return list(GAME_LANGUAGE_PL = "Polski", GAME_LANGUAGE_EN = "English")

#undef GAME_LANGUAGE_PL
#undef GAME_LANGUAGE_EN
