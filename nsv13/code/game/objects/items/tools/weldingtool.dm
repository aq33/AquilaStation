// Welding tool upgrade for Cyborgs

/obj/item/weldingtool/experimental/cyborg
	name = "zintegrowana eksperymentalna spawarka"
	desc = "Eksperymentalna spawarka do systemów robotycznych. Specjalna konstrukcja podwaja szybkość spawania."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"
	toolspeed = 0.5

/obj/item/weldingtool/experimental/cyborg/cyborg_unequip(mob/user)
	if(!isOn())
		return
	switched_on(user)
