/*
	AQUILA - przyprawy, warzywa liściaste i len z Goona, Baya, Paradise i Nebuli (partia „inne”), odczynniki w inne.dm
*/

/*
	Mięta (Goon, Paradise: mint)
*/
/datum/plant_feature/fruit/mint
	species_name = "mentha piperita"
	name = "mięta"
	icon_state = "tea_2"
	icon_uneven = TRUE
	colour_override = "#a8ffcc"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-mint"
	fruit_product = /obj/item/food/grown/mint
	fast_reagents = list(/datum/reagent/consumable/menthol = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST

/obj/item/plant_seeds/preset/mint
	name = "nasiona: mięta (ziemia)"
	name_override = "mięta"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-mint"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tea, /datum/plant_feature/fruit/mint)

/obj/item/food/grown/mint
	seed = /obj/item/plant_seeds/preset/mint
	name = "liście mięty"
	desc = "Aromatyczne liście o czystym, świeżym smaku. Po destylacji dają mentol."
	gender = PLURAL
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "mint"
	foodtypes = VEGETABLES
	distill_reagent = /datum/reagent/consumable/menthol
	tastes = list("mięta" = 1)

/*
	Sałata (Goon, Paradise: lettuce)
*/
/datum/plant_feature/fruit/lettuce
	species_name = "lactuca sativa"
	name = "sałata"
	icon_state = "cabbage"
	colour_override = "#c8ff9a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-lettuce"
	fruit_product = /obj/item/food/grown/lettuce
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/lettuce
	name = "nasiona: sałata (ziemia)"
	name_override = "sałata"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-lettuce"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/lettuce)

/obj/item/food/grown/lettuce
	seed = /obj/item/plant_seeds/preset/lettuce
	name = "sałata"
	desc = "Podstawowe zielone warzywo każdej porządnej kosmicznej diety, w przeciwieństwie do szpinaku."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "lettuce"
	foodtypes = VEGETABLES
	tastes = list("sałata" = 1)

/*
	Len (Nebula: flax) - włókno jak bawełna
*/
/datum/plant_feature/fruit/flax
	species_name = "linum usitatissimum"
	name = "len"
	icon_state = "flower_1"
	icon_uneven = TRUE
	colour_override = "#7ea2f0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-flax"
	fruit_product = /obj/item/grown/cotton/flax
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/flax
	name = "nasiona: len (ziemia)"
	name_override = "len"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-flax"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/flower/cotton, /datum/plant_feature/fruit/flax)

/obj/item/grown/cotton/flax
	seed = /obj/item/plant_seeds/preset/flax
	name = "len"
	desc = "Wiązka łodyg lnu. Da się z niej wyciągnąć włókno."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "flax"
	cotton_name = "włókna lnianego"

/*
	Kocimiętka (Goon, Skyrat: catnip), mutacja krzewu herbacianego w piecu
*/
/datum/plant_feature/fruit/tea/catnip
	species_name = "nepeta cataria"
	name = "kocimiętka"
	icon_state = "tea"
	colour_override = "#c8f0b0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-catnip"
	fruit_product = /obj/item/food/grown/catnip
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL, /datum/reagent/consumable/menthol = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/tea)

/obj/item/plant_seeds/preset/catnip
	name = "nasiona: kocimiętka (ziemia)"
	name_override = "kocimiętka"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-catnip"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tea, /datum/plant_feature/fruit/tea/catnip)

/obj/item/food/grown/catnip
	seed = /obj/item/plant_seeds/preset/catnip
	name = "kocimiętka"
	desc = "Inaczej kocia mięta albo kocimiętka właściwa. Narkotyk dla kotów."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "catnip"
	foodtypes = VEGETABLES
	tastes = list("mięta" = 1, "trawa" = 1)
