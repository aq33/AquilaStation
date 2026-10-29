// AQ - porządki w UI: guziki HUD-u zastępujące komendy z panelu statystyk.
// "Śpij" stoi w górnej połówce nad "Relaks" (obok "Rzuć"). Czujniki stroju to wąski guzik
// we wnęce tuż za guzikiem ekwipunku (po rozwinięciu ekwipunku - za slotem butów), bo zakładka
// "Przedmiot" zniknęła z panelu. Ikony są w wersji dla każdego stylu HUD-u.

#define ui_sleep "EAST-2:26,SOUTH+1:7"
#define ui_suit_sensors "WEST+1:7,SOUTH:5"
#define ui_suit_sensors_expanded "WEST+2:9,SOUTH:5"

/datum/hud
	var/atom/movable/screen/suit_sensors/suit_sensors

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/sleep_button()
	using.screen_loc = ui_sleep
	using.hud = src
	static_inventory += using

	suit_sensors = new /atom/movable/screen/suit_sensors()
	suit_sensors.screen_loc = ui_suit_sensors
	suit_sensors.hud = src
	static_inventory += suit_sensors

	update_porzadki_buttons()

/datum/hud/Destroy()
	suit_sensors = null
	return ..()

/datum/hud/update_ui_style(new_ui_style)
	. = ..()
	update_porzadki_buttons()

/// Ikony guzików "śpij" i czujników w stylu HUD-u (stany "<styl>_sleep" i "<styl>_sensors")
/datum/hud/proc/update_porzadki_buttons()
	var/style_name = "[ui_style]"
	var/start = findtext(style_name, "screen_")
	style_name = start ? copytext(style_name, start + length("screen_"), findtext(style_name, ".dmi")) : "midnight"
	if(!icon_exists('aquila/icons/hud/ui_porzadki.dmi', "[style_name]_sleep"))
		style_name = "midnight"
	for(var/atom/movable/screen/button in static_inventory)
		if(istype(button, /atom/movable/screen/sleep_button))
			button.icon_state = "[style_name]_sleep"
		else if(istype(button, /atom/movable/screen/suit_sensors))
			button.icon_state = "[style_name]_sensors"

/// Guzik czujników idzie za ostatni slot dolnego rzędu, zależnie od rozwinięcia ekwipunku
/atom/movable/screen/human/toggle/Click()
	. = ..()
	var/mob/viewer = usr
	var/datum/hud/viewer_hud = viewer?.hud_used
	viewer_hud?.suit_sensors?.screen_loc = viewer_hud.inventory_shown ? ui_suit_sensors_expanded : ui_suit_sensors

/atom/movable/screen/sleep_button
	name = "śpij"
	desc = "Uciąć sobie krótką drzemkę."
	icon = 'aquila/icons/hud/ui_porzadki.dmi'
	icon_state = "midnight_sleep"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/sleep_button/Click()
	var/mob/living/user = usr
	if(istype(user))
		user.mob_sleep()

/atom/movable/screen/suit_sensors
	name = "czujniki stroju"
	desc = "Ustaw, co czujniki kombinezonu wysyłają do konsoli monitorowania załogi."
	icon = 'aquila/icons/hud/ui_porzadki.dmi'
	icon_state = "midnight_sensors"
	layer = HUD_LAYER
	plane = HUD_PLANE

/atom/movable/screen/suit_sensors/Click()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	var/obj/item/clothing/under/uniform = user.w_uniform
	if(!istype(uniform))
		to_chat(user, "<span class='warning'>Nie masz na sobie kombinezonu.</span>")
		return
	uniform.set_sensors(user)

#undef ui_sleep
#undef ui_suit_sensors
#undef ui_suit_sensors_expanded
