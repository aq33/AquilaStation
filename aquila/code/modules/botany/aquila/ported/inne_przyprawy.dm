/*
	AQUILA - przyprawy, warzywa liściaste i len z Goona, Baya, Paradise i Nebuli (partia „inne”), odczynniki w inne.dm
*/

/*
	Cynamon (Goon: cinnamon) - laski z kory drzewa
*/
/datum/plant_feature/fruit/cinnamon
	species_name = "cinnamomum verum"
	name = "cynamon"
	icon_state = "pod"
	icon_uneven = TRUE
	colour_override = "#8b4a2b"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-cinnamon"
	fruit_product = /obj/item/food/grown/cinnamon
	fast_reagents = list(/datum/reagent/consumable/cinnamon = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/cinnamon
	name = "nasiona: cynamonowiec (gruz)"
	name_override = "cynamonowiec"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-cinnamon"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/tree, /datum/plant_feature/fruit/cinnamon)

/obj/item/food/grown/cinnamon
	seed = /obj/item/plant_seeds/preset/cinnamon
	name = "laska cynamonu"
	desc = "Przyprawa o słodkim, aromatycznym smaku, używana w kuchni i do wypieków."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "cinnamon"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/cinnamon = 0)
	tastes = list("cynamon" = 1)

/*
	Pieprz czarny (Goon, Bay: peppercorn)
*/
/datum/plant_feature/fruit/peppercorn
	species_name = "piper nigrum"
	name = "pieprz czarny"
	icon_state = "grapes"
	colour_override = "#4a3a34"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-peppercorn"
	fruit_product = /obj/item/food/grown/black_pepper
	fast_reagents = list(/datum/reagent/consumable/blackpepper = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/peppercorn
	name = "nasiona: pieprz czarny (ziemia)"
	name_override = "pieprz czarny"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-peppercorn"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/peppercorn)

/obj/item/food/grown/black_pepper
	seed = /obj/item/plant_seeds/preset/peppercorn
	name = "ziarna pieprzu"
	desc = "Grono ziaren czarnego pieprzu. Zmiel je, a dostaniesz przyprawę."
	gender = PLURAL
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "peppercorn"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/blackpepper = 0)
	tastes = list("pieprz" = 1)

/*
	Imbir (Goon: ginger)
*/
/datum/plant_feature/fruit/ginger
	species_name = "zingiber officinale"
	name = "imbir"
	icon_state = "potato-2"
	colour_override = "#d8b25a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-ginger"
	fruit_product = /obj/item/food/grown/ginger
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/ginger = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/ginger
	name = "nasiona: imbir (ziemia)"
	name_override = "imbir"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-ginger"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/ginger)

/obj/item/food/grown/ginger
	seed = /obj/item/plant_seeds/preset/ginger
	name = "korzeń imbiru"
	desc = "Aromatyczny korzeń imbiru, ostrzejszego krewniaka kurkumy."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "ginger"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/ginger = 0)
	tastes = list("imbir" = 1)

/*
	Kurkuma (Goon: turmeric)
*/
/datum/plant_feature/fruit/turmeric
	species_name = "curcuma longa"
	name = "kurkuma"
	icon_state = "parsnip"
	colour_override = "#e08a30"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-turmeric"
	fruit_product = /obj/item/food/grown/turmeric
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/curry_powder = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/turmeric
	name = "nasiona: kurkuma (glina)"
	name_override = "kurkuma"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-turmeric"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/turmeric)

/obj/item/food/grown/turmeric
	seed = /obj/item/plant_seeds/preset/turmeric
	name = "kłącze kurkumy"
	desc = "Aromatyczny korzeń kurkumy, krewniaczki imbiru. Po zmieleniu daje proszek curry."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "turmeric"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/curry_powder = 0)
	tastes = list("kurkuma" = 1)

/*
	Gorczyca (Goon: mustard)
*/
/datum/plant_feature/fruit/mustard
	species_name = "sinapis alba"
	name = "gorczyca"
	icon_state = "pod"
	icon_uneven = TRUE
	colour_override = "#e8c22a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-mustard"
	fruit_product = /obj/item/food/grown/mustard
	fast_reagents = list(/datum/reagent/consumable/mustard = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/mustard
	name = "nasiona: gorczyca (piasek)"
	name_override = "gorczyca"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-mustard"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/mustard)

/obj/item/food/grown/mustard
	seed = /obj/item/plant_seeds/preset/mustard
	name = "strąk gorczycy"
	desc = "Strąk pełen nasion gorczycy. Nie tak zaawansowany technicznie, jak sugeruje angielska nazwa."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "mustard"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/mustard = 0)
	tastes = list("musztarda" = 1)

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
