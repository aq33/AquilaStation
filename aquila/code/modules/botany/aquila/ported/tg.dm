/*
	AQUILA - rośliny przeniesione z tgstation do naszej botaniki (cechy owocu)
	Każda roślina: cecha owocu, preset nasion, plon. Owoc na krzaku to przekolorowany kształt z features/fruit.dmi,
	plon i torebka nasion ze sprite'ów tg (aquila/icons/obj/hydroponics/ported_tg_*.dmi, CC-BY-SA 3.0).
*/

/*
	Orzeszki ziemne (tg: peanut)
*/
/datum/plant_feature/fruit/peanut
	species_name = "arachis hypogaea"
	name = "orzeszki ziemne"
	icon_state = "pod"
	colour_override = "#c49a5c"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-peanut"
	fruit_product = /obj/item/food/grown/peanut
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/peanut
	name = "nasiona: orzeszki ziemne (ziemia)"
	name_override = "orzeszki ziemne"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-peanut"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/peanut)

/obj/item/food/grown/peanut
	seed = /obj/item/plant_seeds/preset/peanut
	name = "orzeszki ziemne"
	desc = "Smaczna para orzeszków ukryta w twardej łupinie."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "peanut"
	foodtypes = VEGETABLES
	tastes = list("orzeszki ziemne" = 1)
	grind_results = list(/datum/reagent/consumable/peanut_butter = 0)

/datum/reagent/consumable/peanut_butter
	name = "Masło orzechowe"
	description = "Gęsta, kremowa pasta z mielonych orzeszków ziemnych."
	taste_description = "orzeszki ziemne"
	color = "#D9A066"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN

/obj/machinery/vending/hydroseeds/Initialize(mapload)
	products[/obj/item/plant_seeds/preset/peanut] = 3
	return ..()
