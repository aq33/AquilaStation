// AQUILA - nasze rośliny przeniesione na nową botanikę z Bee

/*
	Kwiat-tyłek (replica butt flower, port z HippieStation13 - aquila/code/modules/butt/buttflower.dm)
*/
/datum/plant_feature/fruit/flower/butt
	species_name = "podex replicatus"
	name = "replica butt flower"
	icon = 'aquila/icons/obj/buttflower.dmi'
	icon_state = "buttflower"
	seed_icon = 'aquila/icons/obj/buttflower.dmi'
	seed_icon_state = "seed-butt"
	colour_override = "#fff"
	fruit_product = /obj/item/food/grown/buttflower
	plant_traits = list()
	fast_reagents = list(/datum/reagent/drug/fartium = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list()

/obj/item/plant_seeds/preset/butt
	name = "replica butt seeds"
	name_override = "replica butt flower"
	icon = 'aquila/icons/obj/buttflower.dmi'
	icon_state = "seed-butt"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/flower, /datum/plant_feature/fruit/flower/butt)

/*
	Kwiat trupi - mutacja ostu, po dojrzeniu wydziela miazmę (aquila/code/modules/miasma)
*/
/datum/plant_feature/fruit/starthistle/corpse
	species_name = "amorphophallus putidus"
	name = "corpse flower"
	icon_state = "star"
	colour_override = "#6b1f3a"
	seed_icon = 'icons/obj/hydroponics/seeds.dmi'
	seed_icon_state = "seed-corpse-flower"
	fruit_product = /obj/item/plant_seeds/preset/corpse_flower
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	mutations = list(/datum/plant_feature/fruit/starthistle)

/datum/plant_feature/fruit/starthistle/corpse/catch_planted(datum/source, atom/destination)
	. = ..()
	if(parent?.plant_item)
		SSmiasma.add_source(parent.plant_item)

/// Ile miazmy wydziela kwiat, null gdy roślina nie rośnie już w tacy
/datum/plant_feature/fruit/starthistle/corpse/proc/miasma_amount(seconds)
	var/obj/item/plant/plant = parent?.plant_item
	if(!plant || !plant.loc?.GetComponent(/datum/component/planter))
		return null
	var/datum/plant_feature/body/body = locate() in parent.plant_features
	if(!body || body.health <= 0 || body.current_stage < body.growth_stages)
		return 0
	// Przestaje cuchnąć, gdy ciśnienie mocno odbiega od normy; silniejszy kwiat znosi więcej
	var/turf/open/T = get_turf(plant)
	if(!istype(T) || abs(ONE_ATMOSPHERE - T.return_air().return_pressure()) > (trait_power * 5 + 10))
		return 0
	return (body.max_harvest + 6) * 3.5 * MIASMA_CORPSE_MOLES * seconds

/obj/item/plant/miasma_emission(seconds)
	var/datum/component/plant/plant_component = GetComponent(/datum/component/plant)
	var/datum/plant_feature/fruit/starthistle/corpse/flower = locate() in plant_component?.plant_features
	return flower?.miasma_amount(seconds)

/obj/item/plant_seeds/preset/corpse_flower
	name = "corpse flower seeds"
	name_override = "kwiat trupi"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed-corpse-flower"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/bush_vine/nettle/thistle, /datum/plant_feature/fruit/starthistle/corpse)

/*
	Pomidor-zabójca jako gotowe nasiona (u Bee tylko mutacja), m.in. dla handlarza z eksploracji dronami
*/
/obj/item/plant_seeds/preset/killer_tomato
	name = "killer tomato seeds"
	name_override = "killer tomato plant"
	icon_state = "seed-killertomato"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tomato, /datum/plant_feature/fruit/tomato/killer)
