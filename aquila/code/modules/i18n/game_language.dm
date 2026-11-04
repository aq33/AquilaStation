// Język gry wybierany w preferencjach.
// Gracz z językiem EN dostaje słownik (strings/i18n/en_chat.json), a klient tłumaczy przy wyświetlaniu:
// panel czatu (tgui/packages/tgui-panel/chat/renderer.jsx) i okna tgui (tgui/packages/tgui/i18nDom.ts).
// Panel statystyk pokazuje wtedy oryginalne angielskie nazwy verbów i zakładek.
// To, co BYOND rysuje sam (dymki, runechat, screentipy), tłumaczy serwer: translate.dm.
// Słowniki buduje tools/i18n/ (opis w build_chat_dict.py).

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

/// Gracz wybrał angielski
/client/proc/wants_english()
	return prefs?.game_language == GAME_LANGUAGE_EN

/// Słownik PL -> EN dla klienta. Wczytywany z dysku przy starcie, więc nowy słownik nie wymaga kompilacji.
/datum/asset/simple/i18n_en_chat
	keep_local_name = TRUE
	assets = list(
		"i18n_en_chat.json" = file("strings/i18n/en_chat.json"),
	)

/// Wysyła panelowi język gracza (i słownik, gdy angielski)
/datum/tgui_panel/proc/send_game_language()
	if(!client || !is_ready())
		return
	if(client.wants_english())
		window.send_asset(get_asset_datum(/datum/asset/simple/i18n_en_chat))
	window.send_message("i18n/setLanguage", list("language" = client.prefs?.game_language || GAME_LANGUAGE_PL))

/datum/tgui_panel/on_message(type, payload)
	. = ..()
	if(type == "ready")
		send_game_language()

// Okna tgui: język w config każdej aktualizacji (zmiana preferencji działa od następnego odświeżenia okna)
/datum/tgui/get_payload(custom_data, with_data, with_static_data)
	. = ..()
	var/list/payload = .
	if(islist(payload) && islist(payload["config"]))
		payload["config"]["language"] = user?.client?.prefs?.game_language || GAME_LANGUAGE_PL

/datum/tgui/send_assets()
	..()
	// send_assets śpi, więc klient mógł zniknąć
	if(!user?.client?.wants_english() || !window)
		return
	if(window.send_asset(get_asset_datum(/datum/asset/simple/i18n_en_chat)))
		user.client.browse_queue_flush()
