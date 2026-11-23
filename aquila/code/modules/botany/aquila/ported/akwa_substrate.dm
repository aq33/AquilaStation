/*
	AQUILA - akwakultura: podłoże wodne, korzenie wodne i ciało „ławica” dla skorupiaków
	Wzór: Nebula (/datum/seed/mollusc, seed_datums_aquaculture.dm) i Bay (/datum/seed/shellfish).
	Sprite ławicy z Nebuli (hydroponics_growing.dmi, mollusc-1..4, CC-BY-SA 3.0), przesunięty w dół do tacy.
*/

/*
	Podłoże wodne - tylko dla korzeni wodnych, nie wchodzi w baśniowe podłoże
*/
/datum/plant_subtrate/water
	name = "podłoże wodne"
	tooltip = "Żwir i sole do akwakultury. Rosną w nim tylko organizmy wodne, np. skorupiaki."
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_substrate.dmi'
	icon_state = "water"
	substrate_flags = PLANT_SUBSTRATE_WATER

/obj/item/substrate_bag/water
	name = "worek z podłożem (woda)"
	desc = "Worek żwiru i soli morskich. Wsypany do tacy i zalany wodą tworzy sadzawkę dla skorupiaków."
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_substrate.dmi'
	icon_state = "substrate_water"
	substrate = /datum/plant_subtrate/water

/datum/design/substrate_water
	name = "Podłoże: woda"
	id = "water_substrate"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/substrate_bag/water
	category = list("initial","Organic Materials")

/obj/machinery/vending/hydronutrients/Initialize(mapload)
	products[/obj/item/substrate_bag/water] = 2
	return ..()

/*
	Korzenie wodne - tylko podłoże wodne
*/
/datum/plant_feature/roots/water
	name = "korzenie sp."
	species_name = "aquae radices"
	compatible_substrate = PLANT_SUBSTRATE_WATER

/*
	Ławica - ciało skorupiaków: kopczyki na dnie tacy, plony leżą w wodzie
*/
/datum/plant_feature/body/shoal
	species_name = "grex conchae"
	name = "ławica"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_fruit.dmi'
	icon_state = "shoal"
	growth_prefix = "shoal"
	growth_stages = 4
	overlay_positions = list(list(9, 6), list(15, 8), list(21, 6), list(26, 8), list(12, 3), list(19, 3))
	yields = PLANT_BODY_YIELD_MEDIUM
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_MEDIUM
	max_harvest = PLANT_BODY_HARVEST_MEDIUM
	upper_fruit_size = PLANT_FRUIT_SIZE_SMALL
	growth_time = PLANT_BODY_GROWTH_MEDIUM
	seeds = 2

/// Skorupiaki sadzi się jako larwy, nie nasiona
/obj/item/plant_seeds/update_plant_name()
	. = ..()
	if(!(locate(/datum/plant_feature/body/shoal) in plant_features))
		return
	var/datum/plant_feature/roots/roots = locate() in plant_features
	name = "larwy: [name_override || get_species_name(plant_features)][roots ? " ([roots.get_substrate_text()])" : ""]"
