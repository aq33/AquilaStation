// Język gry wybierany w preferencjach.
// Gracz z językiem EN dostaje słownik czatu (strings/i18n/en_chat.json), a panel tgui
// tłumaczy wiadomości przy wyświetlaniu (tgui/packages/tgui-panel/chat/i18n.ts).
// Panel statystyk pokazuje wtedy oryginalne angielskie nazwy verbów i zakładek.
// Słowniki buduje tools/i18n/extract_pairs.py i tools/i18n/build_chat_dict.py.

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

/datum/preference/choiced/game_language/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.tgui_panel?.send_game_language()

/// Słownik czatu PL -> EN. Wczytywany z dysku przy starcie, więc nowy słownik nie wymaga kompilacji.
/datum/asset/simple/i18n_en_chat
	keep_local_name = TRUE
	assets = list(
		"i18n_en_chat.json" = file("strings/i18n/en_chat.json"),
	)

/// Wysyła panelowi język gracza (i słownik, gdy angielski)
/datum/tgui_panel/proc/send_game_language()
	if(!client || !is_ready())
		return
	var/language = client.prefs?.game_language || GAME_LANGUAGE_PL
	if(language == GAME_LANGUAGE_EN)
		window.send_asset(get_asset_datum(/datum/asset/simple/i18n_en_chat))
	window.send_message("i18n/setLanguage", list("language" = language))

/datum/tgui_panel/on_message(type, payload)
	. = ..()
	if(type == "ready")
		send_game_language()

#undef GAME_LANGUAGE_PL
#undef GAME_LANGUAGE_EN
