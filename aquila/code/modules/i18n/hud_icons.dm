// AQ - angielskie napisy na guzikach HUD-u (OPÓR, RZUĆ, WALKA, ŚPIJ...) dla graczy z językiem EN.
// Napisy są narysowane w plikach .dmi, więc gracz z angielskim dostaje kopie tych plików
// z angielskimi napisami (aquila/icons/hud/en/, robi je tools/i18n/hud_en_icons.py).
// Stany w kopiach mają te same nazwy, więc podmieniamy tylko plik ikony obiektów HUD-u.

/// Pary: polski plik ikon, angielska kopia
#define I18N_HUD_ICON_PAIRS list(\
	'icons/mob/screen_midnight.dmi', 'aquila/icons/hud/en/screen_midnight.dmi',\
	'icons/mob/screen_retro.dmi', 'aquila/icons/hud/en/screen_retro.dmi',\
	'icons/mob/screen_plasmafire.dmi', 'aquila/icons/hud/en/screen_plasmafire.dmi',\
	'icons/mob/screen_slimecore.dmi', 'aquila/icons/hud/en/screen_slimecore.dmi',\
	'icons/mob/screen_operative.dmi', 'aquila/icons/hud/en/screen_operative.dmi',\
	'icons/mob/screen_clockwork.dmi', 'aquila/icons/hud/en/screen_clockwork.dmi',\
	'icons/mob/screen_gen.dmi', 'aquila/icons/hud/en/screen_gen.dmi',\
	'aquila/icons/hud/ui_porzadki.dmi', 'aquila/icons/hud/en/ui_porzadki.dmi',\
)

/// "polski plik" -> angielska kopia
GLOBAL_LIST_INIT(i18n_hud_icons_en, i18n_hud_icon_map(FALSE))
/// "angielska kopia" -> polski plik
GLOBAL_LIST_INIT(i18n_hud_icons_pl, i18n_hud_icon_map(TRUE))

/proc/i18n_hud_icon_map(reverse)
	var/list/pairs = I18N_HUD_ICON_PAIRS
	. = list()
	for(var/i in 1 to length(pairs) step 2)
		var/polish = pairs[i]
		var/english = pairs[i + 1]
		if(reverse)
			.["[english]"] = polish
		else
			.["[polish]"] = english

/// Plik ikon HUD-u w wybranym języku; plik bez kopii zostaje bez zmian
/proc/i18n_hud_icon(icon_file, english)
	if(!icon_file)
		return icon_file
	var/list/swap = english ? GLOB.i18n_hud_icons_en : GLOB.i18n_hud_icons_pl
	return swap["[icon_file]"] || icon_file

// Styl HUD-u ustawia się przy wejściu w moba (mob/Login) i po zmianie stylu lub języka
/datum/hud/update_ui_style(new_ui_style)
	var/english = mymob?.client?.wants_english()
	. = ..(i18n_hud_icon(new_ui_style, english))
	// guziki z plików spoza stylu: pasek zdrowia (screen_gen), guzik snu (ui_porzadki)
	for(var/atom/movable/screen/item in static_inventory + toggleable_inventory + hotkeybuttons + infodisplay + screenoverlays + inv_slots)
		var/swapped = i18n_hud_icon(item.icon, english)
		if(swapped != item.icon)
			item.icon = swapped

#undef I18N_HUD_ICON_PAIRS
