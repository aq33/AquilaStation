/*
 * Film
 */
/obj/item/camera_film
	name = "kaseta z kliszą"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "Kaseta z kliszą do aparatu. Włóż ją do aparatu, by go przeładować."
	icon_state = "film"
	item_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 10)
