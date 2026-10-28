// AQ - porządki w UI: guziki HUD-u zastępujące komendy z panelu statystyk.
// "Śpij" stoi w górnej połówce nad "Relaks" (obok "Rzuć"), a czujniki stroju
// nad slotem plecaka - zakładka "Przedmiot" zniknęła z panelu.

#define ui_sleep "EAST-2:26,SOUTH+1:7"
#define ui_suit_sensors "CENTER-2:14,SOUTH+1:5"

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/sleep_button()
	using.screen_loc = ui_sleep
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/suit_sensors()
	using.screen_loc = ui_suit_sensors
	using.hud = src
	static_inventory += using

/atom/movable/screen/sleep_button
	name = "śpij"
	desc = "Uciąć sobie krótką drzemkę."
	icon = 'aquila/icons/hud/ui_porzadki.dmi'
	icon_state = "act_sleep"
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
	icon_state = "act_sensors"
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
