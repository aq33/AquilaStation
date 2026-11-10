// AQUILA - sprite'y z tg dla GPS, lampek biurkowych i worka treningowego: tylko zmienne i zmiana stanu w rękach

// GPS w ręku i na pasku jak w tg (stan electronic w plikach urządzeń i w icons/mob/belt.dmi)
/obj/item/gps
	item_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

// Włączona lampka biurkowa świeci też w ręku (stany lamp-on i lampgreen-on w icons/mob/inhands/items_*hand.dmi)
/obj/item/flashlight/lamp/update_brightness(mob/user)
	. = ..()
	if(!item_state)
		return
	item_state = "[initial(item_state)][on ? "-on" : ""]"
	if(ismob(loc))
		var/mob/holder = loc
		holder.update_inv_hands()

// Worek treningowy z tg; plik Goona (goon/icons/obj/fitness.dmi) zostaje bez zmian
/obj/structure/punching_bag
	icon = 'aquila/icons/obj/structures/gym_equipment.dmi'
