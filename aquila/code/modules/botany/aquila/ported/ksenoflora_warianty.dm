/*
	AQUILA - kapsułowe odmiany roślin obcych i z planet (decyzja B16 z raport/bloat_08_decyzje.md).
	Zwykła wersja dalej rośnie w tacce. Odmiana kapsułowa rośnie tylko w kapsule ksenoflory, w warunkach jak na świecie
	pochodzenia rośliny, i ma dwa razy większy owoc, więc daje dwa razy więcej swoich odczynników.
	Nasiona trafiają do tych samych źródeł co reszta obcych nasion (artefakt „Seeding”, ruiny planet), bo są w /preset/alien.
	Ten sam plon co zwykła wersja: siewnik bierze części rośliny z owocu, więc nasiona z niego znów są kapsułowe.
*/

/*
	Wymagania (ilości na sekundę, temperatury w K)
*/
/datum/plant_need/xenoflora/vale
	required_gases = list(GAS_PLASMA = 0.1)
	min_temperature = T0C + 30
	max_temperature = T0C + 60

/datum/plant_need/xenoflora/jurlmah
	required_gases = list(GAS_N2 = 0.1)
	min_temperature = T0C - 30
	max_temperature = T0C - 10

/datum/plant_need/xenoflora/thaadra
	required_gases = list(GAS_CO2 = 0.1)
	min_temperature = T0C - 20
	max_temperature = T0C

/datum/plant_need/xenoflora/surik
	required_gases = list(GAS_CO2 = 0.15)
	min_temperature = T0C + 60
	max_temperature = T0C + 120

/datum/plant_need/xenoflora/dripper
	required_gases = list(GAS_PLASMA = 0.1)
	min_temperature = T0C + 15
	max_temperature = T0C + 30

/datum/plant_need/xenoflora/plasma_flower
	required_gases = list(GAS_PLASMA = 0.1)
	min_temperature = T0C - 30
	max_temperature = T0C - 5

/datum/plant_need/xenoflora/star_cactus
	required_gases = list(GAS_CO2 = 0.1)
	min_temperature = T0C + 40
	max_temperature = T0C + 80

/*
	Owoce: rodzic z potrzebą kapsuły i podwójną objętością
*/
/datum/plant_feature/fruit/vale/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/vale)
	total_volume = PLANT_FRUIT_VOLUME_SMALL * 2

/datum/plant_feature/fruit/jurlmah/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/jurlmah)
	total_volume = PLANT_FRUIT_VOLUME_SMALL * 2

/datum/plant_feature/fruit/thaadra/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/thaadra)
	total_volume = PLANT_FRUIT_VOLUME_SMALL * 2

/datum/plant_feature/fruit/surik/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/surik)
	total_volume = PLANT_FRUIT_VOLUME_SMALL * 2

/datum/plant_feature/fruit/dripper/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/dripper)
	total_volume = PLANT_FRUIT_VOLUME_SMALL * 2

/datum/plant_feature/fruit/plasma_flower/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/plasma_flower)
	total_volume = PLANT_FRUIT_VOLUME_SMALL * 2

/datum/plant_feature/fruit/star_cactus/xenoflora
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/star_cactus)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM * 2

/*
	Nasiona (korzenie ksenoflory: w zwykłej tacce nie wschodzą)
*/
/obj/item/plant_seeds/preset/alien/xenoflora/capsule
	abstract_type = /obj/item/plant_seeds/preset/alien/xenoflora/capsule

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/vale
	name = "nasiona: vale (kapsuła ksenoflory)"
	name_override = "vale"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-vale"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree, /datum/plant_feature/fruit/vale/xenoflora)

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/jurlmah
	name = "nasiona: jurl'mah (kapsuła ksenoflory)"
	name_override = "jurl'mah"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-jurlmah"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/jurlmah/xenoflora)

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/thaadra
	name = "nasiona: thaa'dra (kapsuła ksenoflory)"
	name_override = "thaa'dra"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-thaadra"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/thaadra/xenoflora)

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/surik
	name = "nasiona: surik (kapsuła ksenoflory)"
	name_override = "surik"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-surik"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/surik/xenoflora)

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/dripper
	name = "nasiona: ciekacz (kapsuła ksenoflory)"
	name_override = "ciekacz"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/alien_artifact/dripper, /datum/plant_feature/fruit/dripper/xenoflora)

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/plasma_flower
	name = "nasiona: kwiat plazmowy (kapsuła ksenoflory)"
	name_override = "kwiat plazmowy"
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "seed-plasma_flower"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/plasma_flower/xenoflora)

/obj/item/plant_seeds/preset/alien/xenoflora/capsule/star_cactus
	name = "nasiona: gwiaździsty kaktus (kapsuła ksenoflory)"
	name_override = "gwiaździsty kaktus"
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "seed-starcactus"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/star_cactus/xenoflora)
