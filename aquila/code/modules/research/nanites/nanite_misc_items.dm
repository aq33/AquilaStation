/obj/item/throwing_star/nanite
	name = "kruche kunai"
	desc = "Broń do rzucania z wąskiego ostrza i krótkiej rękojeści. Wygląda na bardzo kruchą."
	icon = 'aquila/icons/obj/items_and_weapons.dmi'
	icon_state = "kunai"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 12
	throwforce = 4 //4 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = 12 damage on hit due to guaranteed embedding
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 100, "embedded_fall_chance" = 5)
	materials = list()

/obj/item/throwing_star/nanite/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/crumble), 15 SECONDS)

/obj/item/throwing_star/nanite/proc/crumble()
	visible_message("<span class='warning'>[src] się rozpada!</span>")
	qdel(src)
