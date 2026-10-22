// AQUILA - próbki dla DNA infusera z naszych simple_animal i przedmiotów
// (w tg cechę TRAIT_VALID_DNA_INFUSION dają elementy/komponenty tych przedmiotów)

/obj/item/food/deadmouse/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/obj/item/food/meat/slab/gondola/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/obj/item/food/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/obj/item/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/// Nasze karaluchy znikają po śmierci (del_on_death). Jak w tg: rozdeptany karaluch przepada,
/// ale zabity pestycydem zostawia ciało, które można włożyć do infusera.
/datum/reagent/toxin/pestkiller/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	var/mob/living/simple_animal/cockroach/roach = M
	if(!istype(roach) || roach.stat == DEAD)
		return ..()
	roach.del_on_death = FALSE
	. = ..()
	if(!QDELETED(roach) && roach.stat != DEAD)
		roach.del_on_death = initial(roach.del_on_death)
