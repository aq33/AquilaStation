// AQ - napisy na guzikach HUD-u (OPÓR, RZUĆ, WALKA, ŚPIJ...) w języku gracza (EN, RU).
// Napisy są narysowane w plikach .dmi, więc gracz z innym językiem dostaje kopie tych plików
// z napisami w swoim języku (aquila/icons/hud/<język>/, robi je tools/i18n/hud_en_icons.py).
// Stany w kopiach mają te same nazwy, więc podmieniamy tylko plik ikony obiektów HUD-u.

/// Pary: polski plik ikon, angielska kopia. Panel konsoli statku (ship_console_hud.dm) bierze
/// oryginały z nsv13/icons/overmap/gui/, które mają angielskie napisy; zakładki zwijania są nasze.
#define I18N_HUD_ICON_PAIRS list(\
	'icons/mob/screen_midnight.dmi', 'aquila/icons/hud/en/screen_midnight.dmi',\
	'icons/mob/screen_retro.dmi', 'aquila/icons/hud/en/screen_retro.dmi',\
	'icons/mob/screen_plasmafire.dmi', 'aquila/icons/hud/en/screen_plasmafire.dmi',\
	'icons/mob/screen_slimecore.dmi', 'aquila/icons/hud/en/screen_slimecore.dmi',\
	'icons/mob/screen_operative.dmi', 'aquila/icons/hud/en/screen_operative.dmi',\
	'icons/mob/screen_clockwork.dmi', 'aquila/icons/hud/en/screen_clockwork.dmi',\
	'icons/mob/screen_gen.dmi', 'aquila/icons/hud/en/screen_gen.dmi',\
	'aquila/icons/hud/ui_porzadki.dmi', 'aquila/icons/hud/en/ui_porzadki.dmi',\
	'aquila/icons/overmap/gui/fighter_console/brake_off.png', 'nsv13/icons/overmap/gui/fighter_console/brake_off.png',\
	'aquila/icons/overmap/gui/fighter_console/brake_on.png', 'nsv13/icons/overmap/gui/fighter_console/brake_on.png',\
	'aquila/icons/overmap/gui/fighter_console/flighttoggle.png', 'nsv13/icons/overmap/gui/fighter_console/flighttoggle.png',\
	'aquila/icons/overmap/gui/fighter_console/flighttoggle_pressed.png', 'nsv13/icons/overmap/gui/fighter_console/flighttoggle_pressed.png',\
	'aquila/icons/overmap/gui/fighter_console/hull0.png', 'nsv13/icons/overmap/gui/fighter_console/hull0.png',\
	'aquila/icons/overmap/gui/fighter_console/hull100.png', 'nsv13/icons/overmap/gui/fighter_console/hull100.png',\
	'aquila/icons/overmap/gui/fighter_console/hull25.png', 'nsv13/icons/overmap/gui/fighter_console/hull25.png',\
	'aquila/icons/overmap/gui/fighter_console/hull50.png', 'nsv13/icons/overmap/gui/fighter_console/hull50.png',\
	'aquila/icons/overmap/gui/fighter_console/hull75.png', 'nsv13/icons/overmap/gui/fighter_console/hull75.png',\
	'aquila/icons/overmap/gui/fighter_console/monitor.png', 'nsv13/icons/overmap/gui/fighter_console/monitor.png',\
	'aquila/icons/overmap/gui/fighter_console/pdc_on.png', 'nsv13/icons/overmap/gui/fighter_console/pdc_on.png',\
	'aquila/icons/overmap/gui/fighter_console/rotation_keyboard.png', 'nsv13/icons/overmap/gui/fighter_console/rotation_keyboard.png',\
	'aquila/icons/overmap/gui/fighter_console/rotation_mouse.png', 'nsv13/icons/overmap/gui/fighter_console/rotation_mouse.png',\
	'aquila/icons/overmap/gui/fighter_console/rotationtoggle.png', 'nsv13/icons/overmap/gui/fighter_console/rotationtoggle.png',\
	'aquila/icons/overmap/gui/fighter_console/rotationtoggle_pressed.png', 'nsv13/icons/overmap/gui/fighter_console/rotationtoggle_pressed.png',\
	'aquila/icons/overmap/gui/fighter_console/switch_right.png', 'nsv13/icons/overmap/gui/fighter_console/switch_right.png',\
	'aquila/icons/overmap/gui/fighter_console/torpedo_on.png', 'nsv13/icons/overmap/gui/fighter_console/torpedo_on.png',\
	'aquila/icons/overmap/gui/fighter_console/weptoggle.png', 'nsv13/icons/overmap/gui/fighter_console/weptoggle.png',\
	'aquila/icons/overmap/gui/fighter_console/weptoggle_pressed.png', 'nsv13/icons/overmap/gui/fighter_console/weptoggle_pressed.png',\
	'aquila/icons/overmap/gui/flight_console/brake_off.png', 'nsv13/icons/overmap/gui/flight_console/brake_off.png',\
	'aquila/icons/overmap/gui/flight_console/brake_on.png', 'nsv13/icons/overmap/gui/flight_console/brake_on.png',\
	'aquila/icons/overmap/gui/flight_console/flighttoggle.png', 'nsv13/icons/overmap/gui/flight_console/flighttoggle.png',\
	'aquila/icons/overmap/gui/flight_console/flighttoggle_pressed.png', 'nsv13/icons/overmap/gui/flight_console/flighttoggle_pressed.png',\
	'aquila/icons/overmap/gui/flight_console/hull0.png', 'nsv13/icons/overmap/gui/flight_console/hull0.png',\
	'aquila/icons/overmap/gui/flight_console/hull100.png', 'nsv13/icons/overmap/gui/flight_console/hull100.png',\
	'aquila/icons/overmap/gui/flight_console/hull25.png', 'nsv13/icons/overmap/gui/flight_console/hull25.png',\
	'aquila/icons/overmap/gui/flight_console/hull50.png', 'nsv13/icons/overmap/gui/flight_console/hull50.png',\
	'aquila/icons/overmap/gui/flight_console/hull75.png', 'nsv13/icons/overmap/gui/flight_console/hull75.png',\
	'aquila/icons/overmap/gui/flight_console/monitor.png', 'nsv13/icons/overmap/gui/flight_console/monitor.png',\
	'aquila/icons/overmap/gui/flight_console/rotation_keyboard.png', 'nsv13/icons/overmap/gui/flight_console/rotation_keyboard.png',\
	'aquila/icons/overmap/gui/flight_console/rotation_mouse.png', 'nsv13/icons/overmap/gui/flight_console/rotation_mouse.png',\
	'aquila/icons/overmap/gui/flight_console/rotationtoggle.png', 'nsv13/icons/overmap/gui/flight_console/rotationtoggle.png',\
	'aquila/icons/overmap/gui/flight_console/rotationtoggle_pressed.png', 'nsv13/icons/overmap/gui/flight_console/rotationtoggle_pressed.png',\
	'aquila/icons/overmap/gui/weapons_console/hull0.png', 'nsv13/icons/overmap/gui/weapons_console/hull0.png',\
	'aquila/icons/overmap/gui/weapons_console/hull100.png', 'nsv13/icons/overmap/gui/weapons_console/hull100.png',\
	'aquila/icons/overmap/gui/weapons_console/hull25.png', 'nsv13/icons/overmap/gui/weapons_console/hull25.png',\
	'aquila/icons/overmap/gui/weapons_console/hull50.png', 'nsv13/icons/overmap/gui/weapons_console/hull50.png',\
	'aquila/icons/overmap/gui/weapons_console/hull75.png', 'nsv13/icons/overmap/gui/weapons_console/hull75.png',\
	'aquila/icons/overmap/gui/weapons_console/monitor.png', 'nsv13/icons/overmap/gui/weapons_console/monitor.png',\
	'aquila/icons/overmap/gui/weapons_console/pdc_on.png', 'nsv13/icons/overmap/gui/weapons_console/pdc_on.png',\
	'aquila/icons/overmap/gui/weapons_console/railgun_on.png', 'nsv13/icons/overmap/gui/weapons_console/railgun_on.png',\
	'aquila/icons/overmap/gui/weapons_console/torpedo_on.png', 'nsv13/icons/overmap/gui/weapons_console/torpedo_on.png',\
	'aquila/icons/overmap/gui/weapons_console/weptoggle.png', 'nsv13/icons/overmap/gui/weapons_console/weptoggle.png',\
	'aquila/icons/overmap/gui/weapons_console/weptoggle_pressed.png', 'nsv13/icons/overmap/gui/weapons_console/weptoggle_pressed.png',\
	'aquila/icons/overmap/gui/console_tab_closed.png', 'aquila/icons/hud/en/console_tab_closed.png',\
	'aquila/icons/overmap/gui/console_tab_open.png', 'aquila/icons/hud/en/console_tab_open.png',\
)

/// Pary: polski plik ikon, rosyjska kopia (robi je tools/i18n/hud_ru_icons.py). Panele konsoli statku
/// (obrazki PNG NSV13) zostają angielskie: rosyjski gracz dostaje oryginały z par angielskich.
#define I18N_HUD_ICON_PAIRS_RU list(	'icons/mob/screen_midnight.dmi', 'aquila/icons/hud/ru/screen_midnight.dmi',	'icons/mob/screen_retro.dmi', 'aquila/icons/hud/ru/screen_retro.dmi',	'icons/mob/screen_plasmafire.dmi', 'aquila/icons/hud/ru/screen_plasmafire.dmi',	'icons/mob/screen_slimecore.dmi', 'aquila/icons/hud/ru/screen_slimecore.dmi',	'icons/mob/screen_operative.dmi', 'aquila/icons/hud/ru/screen_operative.dmi',	'icons/mob/screen_clockwork.dmi', 'aquila/icons/hud/ru/screen_clockwork.dmi',	'icons/mob/screen_gen.dmi', 'aquila/icons/hud/ru/screen_gen.dmi',	'aquila/icons/hud/ui_porzadki.dmi', 'aquila/icons/hud/ru/ui_porzadki.dmi',	'aquila/icons/overmap/gui/console_tab_closed.png', 'aquila/icons/hud/ru/console_tab_closed.png',	'aquila/icons/overmap/gui/console_tab_open.png', 'aquila/icons/hud/ru/console_tab_open.png',)

/// "polski plik" -> angielska kopia
GLOBAL_LIST_INIT(i18n_hud_icons_en, i18n_hud_icon_map(I18N_HUD_ICON_PAIRS, FALSE))
/// "polski plik" -> rosyjska kopia (bez własnej kopii: angielska)
GLOBAL_LIST_INIT(i18n_hud_icons_ru, i18n_hud_icon_map(I18N_HUD_ICON_PAIRS_RU, FALSE, i18n_hud_icon_map(I18N_HUD_ICON_PAIRS, FALSE)))
/// "kopia w dowolnym języku" -> polski plik
GLOBAL_LIST_INIT(i18n_hud_icons_pl, i18n_hud_icon_map(I18N_HUD_ICON_PAIRS_RU, TRUE, i18n_hud_icon_map(I18N_HUD_ICON_PAIRS, TRUE)))

/// Mapa plików z par (polski, kopia); base: mapa, do której dopisujemy (jej wpisy ustępują nowym)
/proc/i18n_hud_icon_map(list/pairs, reverse, list/base)
	. = base ? base.Copy() : list()
	for(var/i in 1 to length(pairs) step 2)
		var/polish = pairs[i]
		var/copy = pairs[i + 1]
		if(reverse)
			.["[copy]"] = polish
		else
			.["[polish]"] = copy

/// Kopie ikon HUD-u dla języka gracza (null: polski)
/proc/i18n_hud_icon_table(language)
	switch(language)
		if(GAME_LANGUAGE_EN)
			return GLOB.i18n_hud_icons_en
		if(GAME_LANGUAGE_RU)
			return GLOB.i18n_hud_icons_ru
	return null

/// Plik ikon HUD-u w wybranym języku (null: polski); plik bez kopii zostaje bez zmian
/proc/i18n_hud_icon(icon_file, language)
	if(!icon_file)
		return icon_file
	var/list/table = i18n_hud_icon_table(language)
	if(table)
		// najpierw z powrotem na polski, bo przy zmianie EN -> RU guzik ma jeszcze angielską kopię
		icon_file = GLOB.i18n_hud_icons_pl["[icon_file]"] || icon_file
		return table["[icon_file]"] || icon_file
	return GLOB.i18n_hud_icons_pl["[icon_file]"] || icon_file

// Styl HUD-u ustawia się przy wejściu w moba (mob/Login) i po zmianie stylu lub języka
/datum/hud/update_ui_style(new_ui_style)
	var/language = mymob?.client?.translated_language()
	. = ..(i18n_hud_icon(new_ui_style, language))
	// guziki z plików spoza stylu: pasek zdrowia (screen_gen), guzik snu (ui_porzadki)
	for(var/atom/movable/screen/item in static_inventory + toggleable_inventory + hotkeybuttons + infodisplay + screenoverlays + inv_slots)
		var/swapped = i18n_hud_icon(item.icon, language)
		if(swapped != item.icon)
			item.icon = swapped

#undef I18N_HUD_ICON_PAIRS
#undef I18N_HUD_ICON_PAIRS_RU

// Panel konsoli statku (aquila/code/modules/overmap/ship_console_hud.dm): gracz z EN albo RU dostaje oryginały
// NSV13 z angielskimi napisami. Stan panelu zawiera język, więc zmiana języka przerysowuje panel.
/atom/movable/screen/movable/aquila_ship_console
	/// Stan panelu (last_state) narysowany angielskimi obrazkami
	var/i18n_drawn_state

/atom/movable/screen/movable/aquila_ship_console/build_state()
	. = ..()
	var/language = user?.client?.translated_language()
	if(language)
		. = "[language];[.]"

/atom/movable/screen/movable/aquila_ship_console/refresh()
	. = ..()
	if(QDELETED(src) || !user?.client)
		return
	var/language = user.client.translated_language()
	var/list/layers = GLOB.aquila_ship_console_layers[kind]
	var/monitor = i18n_hud_icon(layers["monitor"], language)
	if(icon != monitor)
		icon = monitor
	if(tab)
		var/tab_icon = i18n_hud_icon(tab.icon, language)
		if(tab.icon != tab_icon)
			tab.icon = tab_icon
	if(!language)
		i18n_drawn_state = null
		return
	if(last_state == i18n_drawn_state)
		return
	i18n_drawn_state = last_state
	cut_overlays()
	for(var/layer_name in splittext(last_state, ";"))
		if(layers[layer_name])
			add_overlay(image(i18n_hud_icon(layers[layer_name], language)))
