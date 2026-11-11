// AQUILA - próbki dla DNA infusera z naszych simple_animal i przedmiotów
// (w tg cechę TRAIT_VALID_DNA_INFUSION dają elementy/komponenty tych przedmiotów)

/obj/item/food/deadmouse/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/obj/item/food/meat/slab/gondola/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/obj/item/food/grown/Initialize(mapload, skip_genes)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/obj/item/grown/Initialize(mapload, obj/item/plant_seeds/_new_seed)
	. = ..()
	ADD_TRAIT(src, TRAIT_VALID_DNA_INFUSION, INNATE_TRAIT)

/// Nasze karaluchy znikają po śmierci (DEL_ON_DEATH). Jak w tg: rozdeptany karaluch przepada,
/// ale zabity pestycydem zostawia ciało, które można włożyć do infusera.
/datum/reagent/toxin/pestkiller/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	var/mob/living/basic/cockroach/roach = M
	if(!istype(roach) || roach.stat == DEAD)
		return ..()
	roach.basic_mob_flags &= ~DEL_ON_DEATH
	. = ..()
	if(!QDELETED(roach) && roach.stat != DEAD)
		roach.basic_mob_flags |= (initial(roach.basic_mob_flags) & DEL_ON_DEATH)
