// Język gry wybierany w preferencjach.
// Gracz z językiem EN dostaje słownik (strings/i18n/en_chat.json), a klient tłumaczy przy wyświetlaniu:
// panel czatu (tgui/packages/tgui-panel/chat/renderer.jsx) i okna tgui (tgui/packages/tgui/i18nDom.ts).
// Panel statystyk pokazuje wtedy oryginalne angielskie nazwy verbów i zakładek.
// To, co BYOND rysuje sam (dymki, runechat, screentipy), tłumaczy serwer: translate.dm.
// Słowniki buduje tools/i18n/ (opis w build_chat_dict.py).
// Moduł nie zmienia kodu gry: wszystko to nadpisania procedur z aquila/code/modules/i18n/ (dołączone
// na końcu aquila/aquila.dm) i loader tgui (tgui/i18n-jsx.cjs). Odpięcie: usunąć ten blok include
// i loader z tgui/webpack.config.js.

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

// Zapis w tabeli preferencji osobnym zapytaniem, bez zmian w preferences2.dm
/datum/preferences/load_from_database()
	. = ..()
	load_game_language()

/datum/preferences/proc/load_game_language()
	if(!SSdbcore.IsConnected() || !parent?.ckey)
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery(
		"SELECT preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey AND preference_tag=:ptag",
		list("ckey" = parent.ckey, "ptag" = PREFERENCE_TAG_GAME_LANGUAGE)
	)
	if(query.Execute() && query.NextRow())
		game_language = query.item[1]
		game_language_chosen = TRUE
	qdel(query)
	game_language = sanitize_inlist(game_language, GLOB.game_languages, initial(game_language))

/datum/preferences/save_preferences()
	. = ..()
	// bez wyboru nie zapisujemy domyślnego języka, inaczej okno wyboru (language_choice.dm) już by nie wróciło
	if(!game_language_chosen || !SSdbcore.IsConnected() || !parent?.ckey || IS_GUEST_KEY(parent.ckey))
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("preferences")] (ckey, preference_tag, preference_value) VALUES (:ckey, :ptag, :pvalue) ON DUPLICATE KEY UPDATE preference_value=:pvalue2",
		list("ckey" = parent.ckey, "ptag" = PREFERENCE_TAG_GAME_LANGUAGE, "pvalue" = game_language, "pvalue2" = game_language)
	)
	query.Execute()
	qdel(query)

/datum/preference/choiced/game_language/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	prefs.game_language_chosen = TRUE // zmiana w oknie preferencji też jest wyborem
	if(!C)
		return
	// Okna otwarte przed zmianą nie dostały słownika w send_assets(), a język przyjdzie im z następną aktualizacją
	if(C.wants_english())
		var/datum/asset/dictionary = get_asset_datum(/datum/asset/simple/i18n_en_windows)
		var/flush_queue = FALSE
		for(var/datum/tgui/ui as anything in C.mob?.tgui_open_uis)
			if(ui.window)
				flush_queue |= ui.window.send_asset(dictionary)
		if(flush_queue)
			C.browse_queue_flush()
	C.tgui_panel?.send_game_language()
	C.escape_menu?.send_game_language()
	if(C.tgui_say?.window?.is_ready())
		C.tgui_say.load() // etykiety kanałów w oknie mówienia (niegotowe okno dostanie język przy starcie)
	// napisy na guzikach HUD-u (aquila/code/modules/i18n/hud_icons.dm)
	C.mob?.hud_used?.update_ui_style(ui_style2icon(C.prefs?.UI_style))

/// Gracz wybrał angielski
/client/proc/wants_english()
	return prefs?.game_language == GAME_LANGUAGE_EN

/// Słownik PL -> EN dla klienta. Wczytywany z dysku przy starcie, więc nowy słownik nie wymaga kompilacji.
/datum/asset/simple/i18n_en_chat
	keep_local_name = TRUE
	assets = list(
		"i18n_en_chat.json" = file("strings/i18n/en_chat.json"),
	)

/// Mniejszy słownik dla okien tgui i menu Esc (bez tekstów tylko z czatu): każde okno to osobna
/// przeglądarka, która parsuje go od nowa (tools/i18n/build_chat_dict.py, en_windows.json)
/datum/asset/simple/i18n_en_windows
	keep_local_name = TRUE
	assets = list(
		"i18n_en_windows.json" = file("strings/i18n/en_windows.json"),
	)

// Bez preloadu (ASSET_SIMPLE_PRELOAD wysyła wszystkie zasoby każdemu): słowniki dostają tylko gracze z EN
/datum/asset_transport/Initialize(list/assets)
	..()
	preload -= "i18n_en_chat.json"
	preload -= "i18n_en_windows.json"

/// Wysyła panelowi język gracza (i słownik, gdy angielski)
/datum/tgui_panel/proc/send_game_language()
	if(!client || !is_ready())
		return
	if(client.wants_english() && window.send_asset(get_asset_datum(/datum/asset/simple/i18n_en_chat)))
		// Klient i tak czeka na plik i ponawia pobieranie (tgui/i18n.ts), ale im wcześniej dojdzie, tym lepiej
		client.browse_queue_flush()
		if(!client)
			return
	window.send_message("i18n/setLanguage", list("language" = client.prefs?.game_language || GAME_LANGUAGE_PL))

/// Menu pod Esc (aquila/code/modules/escape_menu, woła je New): język gracza i słownik, gdy angielski
/datum/escape_menu/New(client/client)
	. = ..()
	send_game_language()

/datum/escape_menu/proc/send_game_language()
	if(!client || !window)
		return
	if(client.wants_english())
		window.send_asset(get_asset_datum(/datum/asset/simple/i18n_en_windows))
	window.send_message("i18n/setLanguage", list("language" = client.prefs?.game_language || GAME_LANGUAGE_PL))
	send_update(list("gameLanguage" = client.prefs?.game_language || GAME_LANGUAGE_PL)) // przełącznik w menu

/// Okno mówienia (tgui-say): etykiety kanałów po angielsku (tgui/packages/tgui-say/constants)
/datum/tgui_say/load()
	. = ..()
	if(. && window)
		window.send_message("i18n/setLanguage", list("language" = client?.prefs?.game_language || GAME_LANGUAGE_PL))

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
	if(window.send_asset(get_asset_datum(/datum/asset/simple/i18n_en_windows)))
		user.client.browse_queue_flush()
