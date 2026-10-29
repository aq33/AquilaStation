/obj/item/gun/energy/vortex
	name = "karabin wirowy"
	desc = "Potężny karabin obcego pochodzenia, który strzela potężnymi strzałkami energii."
	icon_state = "vortex"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/vortex)

/obj/item/gun/energy/vortex/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += "<span class='abductor'>Ma zamontowany podprzestrzenny rdzeń zasilania.</span>"
