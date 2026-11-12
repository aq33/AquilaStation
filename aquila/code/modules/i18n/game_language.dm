// Język gry wybierany w preferencjach.
// Gracz z językiem innym niż polski (EN, RU) dostaje słownik (strings/i18n/<język>_chat.json), a klient tłumaczy
// przy wyświetlaniu: panel czatu (tgui/packages/tgui-panel/chat/renderer.jsx) i okna tgui (tgui/packages/tgui/i18nDom.ts).
// Panel statystyk pokazuje wtedy nazwy verbów i zakładek w języku gracza (po angielsku: oryginały z DM).
// To, co BYOND rysuje sam (dymki, runechat, screentipy), tłumaczy serwer: translate.dm.
// Słowniki buduje tools/i18n/ (opis w build_chat_dict.py).
// Moduł nie zmienia kodu gry: wszystko to nadpisania procedur z aquila/code/modules/i18n/ (dołączone
// na końcu aquila/aquila.dm) i loader tgui (tgui/i18n-jsx.cjs). Odpięcie: usunąć ten blok include
// i loader z tgui/webpack.config.js.

GLOBAL_LIST_INIT(game_languages, list(GAME_LANGUAGE_PL, GAME_LANGUAGE_EN, GAME_LANGUAGE_RU))

/// Nazwa języka w jego własnym języku (okno wyboru, preferencje, menu Esc)
GLOBAL_LIST_INIT(game_language_names, list(
	GAME_LANGUAGE_PL = "Polski",
	GAME_LANGUAGE_EN = "English",
	GAME_LANGUAGE_RU = "Русский",
))

/// Język -> słownik klienta dla panelu czatu
GLOBAL_LIST_INIT(i18n_chat_assets, list(
	GAME_LANGUAGE_EN = /datum/asset/simple/i18n_en_chat,
	GAME_LANGUAGE_RU = /datum/asset/simple/i18n_ru_chat,
))

/// Język -> mniejszy słownik klienta dla okien tgui i menu Esc
GLOBAL_LIST_INIT(i18n_window_assets, list(
	GAME_LANGUAGE_EN = /datum/asset/simple/i18n_en_windows,
	GAME_LANGUAGE_RU = /datum/asset/simple/i18n_ru_windows,
))

/// Kod języka DeepL dla tłumaczenia czatu między graczami (chat_translation.dm)
GLOBAL_LIST_INIT(game_language_deepl, list(
	GAME_LANGUAGE_PL = DEEPL_LANG_PL,
	GAME_LANGUAGE_EN = DEEPL_LANG_EN,
	GAME_LANGUAGE_RU = DEEPL_LANG_RU,
))

/datum/preferences
	/// Język interfejsu gracza (GAME_LANGUAGE_*), zapisywany pod PREFERENCE_TAG_GAME_LANGUAGE
	var/game_language = GAME_LANGUAGE_PL

/datum/preference/choiced/game_language
	db_key = "game_language"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "game_language"

/datum/preference/choiced/game_language/init_possible_values()
	return GLOB.game_languages.Copy()

/datum/preference/choiced/game_language/get_display_names()
	return GLOB.game_language_names.Copy()

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
	var/datum/asset/dictionary = C.i18n_window_asset()
	if(dictionary)
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
	// lobby wybiera plik ikon przy tworzeniu: nowy HUD lobby w nowym języku
	var/mob/dead/new_player/player = C.mob
	if(istype(player) && player.lobby_hud)
		QDEL_NULL(player.lobby_hud)
		player.show_lobby_hud()

/// Wiersze telewizorka w lobby w języku gracza (stan rundy: „Start za”, „Graczy” itd.)
/datum/aq_lobby_hud/tv_lines()
	. = ..()
	if(!client_ref?.translated_language())
		return
	var/list/lines = .
	for(var/i in 1 to length(lines))
		lines[i] = i18n_for_client(client_ref, lines[i])

/// Język gry gracza (GAME_LANGUAGE_*)
/client/proc/game_language()
	return prefs?.game_language || GAME_LANGUAGE_PL

/// Język, na który tłumaczymy teksty gry dla tego gracza, albo null, gdy gra po polsku
/client/proc/translated_language()
	var/language = prefs?.game_language
	return (language && language != GAME_LANGUAGE_PL) ? language : null

/// Gracz wybrał angielski (obcokrajowiec i rzeczy tylko dla wersji angielskiej)
/client/proc/wants_english()
	return prefs?.game_language == GAME_LANGUAGE_EN

/// Słownik okien w języku gracza (zasób) albo null, gdy gra po polsku
/client/proc/i18n_window_asset()
	var/asset_type = GLOB.i18n_window_assets[translated_language() || ""]
	return asset_type ? get_asset_datum(asset_type) : null

/// Słownik czatu w języku gracza (zasób) albo null, gdy gra po polsku
/client/proc/i18n_chat_asset()
	var/asset_type = GLOB.i18n_chat_assets[translated_language() || ""]
	return asset_type ? get_asset_datum(asset_type) : null

/// Słowniki PL -> język dla klienta. Wczytywane z dysku przy starcie, więc nowy słownik nie wymaga kompilacji.
/datum/asset/simple/i18n_en_chat
	keep_local_name = TRUE
	assets = list(
		"i18n_en_chat.json" = file("strings/i18n/en_chat.json"),
	)

/// Mniejszy słownik dla okien tgui i menu Esc (bez tekstów tylko z czatu): każde okno to osobna
/// przeglądarka, która parsuje go od nowa (tools/i18n/build_chat_dict.py, <język>_windows.json)
/datum/asset/simple/i18n_en_windows
	keep_local_name = TRUE
	assets = list(
		"i18n_en_windows.json" = file("strings/i18n/en_windows.json"),
	)

/datum/asset/simple/i18n_ru_chat
	keep_local_name = TRUE
	assets = list(
		"i18n_ru_chat.json" = file("strings/i18n/ru_chat.json"),
	)

/datum/asset/simple/i18n_ru_windows
	keep_local_name = TRUE
	assets = list(
		"i18n_ru_windows.json" = file("strings/i18n/ru_windows.json"),
	)

// Bez preloadu (ASSET_SIMPLE_PRELOAD wysyła wszystkie zasoby każdemu): słowniki dostają tylko gracze z danym językiem
/datum/asset_transport/Initialize(list/assets)
	..()
	for(var/language in GLOB.game_languages)
		preload -= "i18n_[language]_chat.json"
		preload -= "i18n_[language]_windows.json"

/// Grand9K z cyrylicą. Font w zasobach (.rsc) klient BYOND ładuje sam, a font_family wpisuje plik do zasobów.
/datum/font/grand9k_pixel_ru
	name = "Grand9K Pixel RU"
	font_family = 'aquila/interface/fonts/Grand9K_Pixel_RU.ttf'

/// Font napisów na mapie (runechat, liczniki HUD-u: klasa .maptext ze skin.dmf) w języku gracza
#define I18N_MAPTEXT_FONT_DEFAULT "font-family: 'Small Fonts'; font-size: 7px;"
/// Small Fonts rysuje cyrylicę mikroskopijnym zamiennikiem: rosyjski gracz dostaje Grand9K z cyrylicą
#define I18N_MAPTEXT_FONT_CYRILLIC "font-family: 'Grand9K Pixel RU'; font-size: 6pt;"

/// Ustawia font klasy .maptext na mapie gracza (winset stylu mapy, bez zmian w skin.dmf)
/client/proc/i18n_update_map_font()
	set waitfor = FALSE
	var/want = game_language() == GAME_LANGUAGE_RU ? I18N_MAPTEXT_FONT_CYRILLIC : I18N_MAPTEXT_FONT_DEFAULT
	var/other = want == I18N_MAPTEXT_FONT_DEFAULT ? I18N_MAPTEXT_FONT_CYRILLIC : I18N_MAPTEXT_FONT_DEFAULT
	var/style = winget(src, "mapwindow.map", "style")
	if(QDELETED(src) || !istext(style) || !findtext(style, other))
		return
	winset(src, "mapwindow.map", list("style" = replacetext(style, other, want)))

#undef I18N_MAPTEXT_FONT_DEFAULT
#undef I18N_MAPTEXT_FONT_CYRILLIC

/// Wysyła panelowi język gracza (i słownik, gdy nie gra po polsku)
/datum/tgui_panel/proc/send_game_language()
	if(!client || !is_ready())
		return
	client.i18n_update_map_font()
	var/datum/asset/dictionary = client.i18n_chat_asset()
	if(dictionary && window.send_asset(dictionary))
		// Klient i tak czeka na plik i ponawia pobieranie (tgui/i18n.ts), ale im wcześniej dojdzie, tym lepiej
		client.browse_queue_flush()
		if(!client)
			return
	window.send_message("i18n/setLanguage", list("language" = client.game_language()))

/// Menu pod Esc (aquila/code/modules/escape_menu, woła je New): język gracza i słownik, gdy nie gra po polsku
/datum/escape_menu/New(client/client)
	. = ..()
	send_game_language()

/datum/escape_menu/proc/send_game_language()
	if(!client || !window)
		return
	var/datum/asset/dictionary = client.i18n_window_asset()
	if(dictionary)
		window.send_asset(dictionary)
	window.send_message("i18n/setLanguage", list("language" = client.game_language()))
	send_update(list("gameLanguage" = client.game_language(), "gameLanguages" = GLOB.game_language_names)) // wybór w menu

/// Okno mówienia (tgui-say): etykiety kanałów w języku gracza (tgui/packages/tgui-say/constants)
/datum/tgui_say/load()
	. = ..()
	if(. && window)
		window.send_message("i18n/setLanguage", list("language" = client?.game_language() || GAME_LANGUAGE_PL))

/datum/tgui_panel/on_message(type, payload)
	. = ..()
	if(type == "ready")
		send_game_language()

// Okna tgui: język w config każdej aktualizacji (zmiana preferencji działa od następnego odświeżenia okna)
/datum/tgui/get_payload(custom_data, with_data, with_static_data)
	. = ..()
	var/list/payload = .
	if(islist(payload) && islist(payload["config"]))
		payload["config"]["language"] = user?.client?.game_language() || GAME_LANGUAGE_PL

/datum/tgui/send_assets()
	..()
	// send_assets śpi, więc klient mógł zniknąć
	var/datum/asset/dictionary = user?.client?.i18n_window_asset()
	if(!dictionary || !window)
		return
	if(window.send_asset(dictionary))
		user.client.browse_queue_flush()
