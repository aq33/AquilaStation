// AQUILA - turfy, ściany, ruda i rośliny planety lodowej z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony
// CC BY-SA 3.0): code/game/turfs/open/floor/plating/icemoon.dmi, code/game/turfs/closed/minerals.dm (random/snow, ice),
// code/modules/mining/ores_coins.dm (ore/ice), code/modules/mining/lavaland/ash_flora.dm (chilly).
// Zmiany względem Shiptesta:
// - śnieg to nasz /turf/open/floor/plating/asteroid/snow (ikona tg 32x32) z atmosferą planety i spowolnieniem 1
//   (u nas zwykły śnieg spowalnia 2, w Shiptest 1,05);
// - skała lodowa ma 8 wariantów 32x32 („coarse” z Shiptesta) zamiast smoothingu bitmaskowego 70x70, ściany łupka
//   i lodu przerobione z bitmaski na nasz smoothing narożnikowy (tools/planets/wall_corners.py);
// - atmosfera stała (jak przy planecie wulkanicznej): tlen i azot przy 255 K, ok. 110 kPa (Shiptest: 250–260 K,
//   101–136 kPa, czasem ślad ozonu lub amoniaku, których u nas nie ma);
// - ruda lodu nie trafia do elektrolizera (nie mamy go): mielona daje lód, w ogniu topi się w wodę.

/// Atmosfera planety lodowej (oddychalna, zimna)
#define PLANET_ICE_ATMOS "o2=26;n2=104;TEMP=255"

// Podłogi

/turf/open/floor/plating/asteroid/snow/planet_ice
	baseturfs = /turf/open/floor/plating/asteroid/icerock
	turf_type = /turf/open/floor/plating/asteroid/snow/planet_ice
	initial_gas_mix = PLANET_ICE_ATMOS
	slowdown = 1

/// Skała lodowa (Shiptest: asteroid/icerock)
/turf/open/floor/plating/asteroid/icerock
	name = "lodowa skała"
	desc = "Szorstka skała pokrywająca powierzchnię."
	icon = 'aquila/icons/planets/turf/ice_floors.dmi'
	icon_state = "icerock"
	icon_plating = "icerock"
	floor_variance = 0
	dug = TRUE
	baseturfs = /turf/open/floor/plating/asteroid/icerock
	turf_type = /turf/open/floor/plating/asteroid/icerock
	initial_gas_mix = PLANET_ICE_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/sheet/mineral/snow
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/asteroid/icerock/Initialize(mapload)
	. = ..()
	if(icon_state == "icerock")
		icon_state = "icerock[rand(0, 7)]"

/turf/open/floor/plating/asteroid/icerock/cracked
	name = "spękana lodowa skała"
	icon_state = "icerock_cracked"

/turf/open/floor/plating/asteroid/icerock/smooth
	name = "gładka lodowa skała"
	icon_state = "icerock_smooth"

/// Kra: popękany lód, już nie śliski (Shiptest: asteroid/iceberg)
/turf/open/floor/plating/asteroid/iceberg
	name = "popękany lód"
	desc = "Tafla litego lodu. Wygląda na zbyt popękaną, żeby była śliska."
	icon = 'aquila/icons/planets/turf/ice_floors.dmi'
	icon_state = "iceberg"
	icon_plating = "iceberg"
	floor_variance = 0
	dug = TRUE
	baseturfs = /turf/open/floor/plating/asteroid/iceberg
	turf_type = /turf/open/floor/plating/asteroid/iceberg
	initial_gas_mix = PLANET_ICE_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/sheet/mineral/snow
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/asteroid/iceberg/Initialize(mapload)
	. = ..()
	icon_state = "iceberg_[rand(0, 3)]"

/// Śliska tafla lodu planety lodowej
/turf/open/floor/plating/ice/planet_ice
	initial_gas_mix = PLANET_ICE_ATMOS
	initial_temperature = 255
	baseturfs = /turf/open/floor/plating/ice/planet_ice

/turf/open/floor/plating/asteroid/basalt/planet_ice
	baseturfs = /turf/open/floor/plating/ice/planet_ice
	turf_type = /turf/open/floor/plating/asteroid/basalt/planet_ice
	initial_gas_mix = PLANET_ICE_ATMOS
	planetary_atmos = TRUE

/// Jeziora plazmy w najgorętszych jaskiniach
/turf/open/lava/plasma/planet_ice
	initial_gas_mix = PLANET_ICE_ATMOS
	baseturfs = /turf/open/lava/plasma/planet_ice
	planetary_atmos = TRUE

/// Zimna woda (Shiptest: water/iceplanet)
/turf/open/water/planet/beach/ice
	name = "zimna woda"
	desc = "Zamarznięta woda w końcu ustępuje płynącej, kiedy trochę ją ogrzać. Tu najwyraźniej tak było."
	color = "#41a3ff"
	initial_gas_mix = PLANET_ICE_ATMOS
	baseturfs = /turf/open/water/planet/beach/ice

/turf/open/water/planet/beach/deep/ice
	name = "głęboka zimna woda"
	initial_gas_mix = PLANET_ICE_ATMOS
	baseturfs = /turf/open/water/planet/beach/deep/ice

// Ściany

/// Łupek z rudami (Shiptest: mineral/random/snow)
/turf/closed/mineral/random/planet_ice
	name = "łupek"
	desc = "Spróbuj powiedzieć to pięć razy szybko."
	icon = 'aquila/icons/planets/turf/walls/schist_wall.dmi'
	icon_state = "schist"
	smooth_icon = 'aquila/icons/planets/turf/walls/schist_wall.dmi'
	environment_type = "icerock"
	turf_type = /turf/open/floor/plating/asteroid/icerock
	baseturfs = /turf/open/floor/plating/asteroid/icerock
	initial_gas_mix = PLANET_ICE_ATMOS
	defer_change = TRUE
	mineralChance = 20
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 10, /obj/item/stack/ore/diamond = 2, /obj/item/stack/ore/gold = 20, /obj/item/stack/ore/titanium = 15,
		/obj/item/stack/ore/plasma = 10, /obj/item/stack/ore/iron = 20, /obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/silver = 10, /obj/item/stack/ore/ice = 10)

/// Pod śniegiem: więcej rzadkich rud
/turf/closed/mineral/random/planet_ice/underground
	baseturfs = /turf/open/floor/plating/asteroid/snow/planet_ice
	mineralChance = 10
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 10, /obj/item/stack/ore/diamond = 4, /obj/item/stack/ore/gold = 20, /obj/item/stack/ore/titanium = 22,
		/obj/item/stack/ore/plasma = 20, /obj/item/stack/ore/iron = 20, /obj/item/stack/ore/bluespace_crystal = 2)

/turf/closed/mineral/random/planet_ice/high_chance
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 35, /obj/item/stack/ore/diamond = 30, /obj/item/stack/ore/gold = 45, /obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/plasma = 50, /obj/item/stack/ore/bluespace_crystal = 20)

/// Lodowa ściana: przepuszcza światło, wykopana daje rudę lodu (Shiptest: mineral/ice)
/turf/closed/mineral/planet_ice_wall
	name = "lodowa ściana"
	desc = "Zamarznięta woda układa się w faliste wzory, jak ocean zastygły w pantomimie."
	icon = 'aquila/icons/planets/turf/walls/ice_wall.dmi'
	icon_state = "icewall"
	smooth_icon = 'aquila/icons/planets/turf/walls/ice_wall.dmi'
	environment_type = "iceberg"
	turf_type = /turf/open/floor/plating/asteroid/iceberg
	baseturfs = /turf/open/floor/plating/asteroid/iceberg
	initial_gas_mix = PLANET_ICE_ATMOS
	defer_change = TRUE
	opacity = FALSE
	mineralType = /obj/item/stack/ore/ice

/// Gibtonit w łupku
/turf/closed/mineral/gibtonite/planet_ice
	icon = 'aquila/icons/planets/turf/walls/schist_wall.dmi'
	icon_state = "schist"
	smooth_icon = 'aquila/icons/planets/turf/walls/schist_wall.dmi'
	environment_type = "icerock"
	turf_type = /turf/open/floor/plating/asteroid/icerock
	baseturfs = /turf/open/floor/plating/asteroid/icerock
	initial_gas_mix = PLANET_ICE_ATMOS
	defer_change = TRUE

// Ruda lodu

/obj/item/stack/ore/ice
	name = "kryształki lodu"
	desc = "Czysty lód z głębi planety. Zmielony daje lód, a w ogniu topi się w wodę."
	icon = 'aquila/icons/planets/ice_ore.dmi'
	icon_state = "Ice ore"
	item_state = "Ice ore"
	singular_name = "kryształek lodu"
	points = 0
	refined_type = null
	grind_results = list(/datum/reagent/consumable/ice = 10)

/obj/item/stack/ore/ice/fire_act(exposed_temperature, exposed_volume)
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = amount SECONDS)
	visible_message(span_notice("[src] topi się w kałużę wody."))
	qdel(src)

// Rośliny

/// Sprężysta trawa z lodowymi papryczkami (Shiptest: ash/chilly)
/obj/structure/flora/ash/chilly
	name = "sprężysta owocująca trawa"
	desc = "Kępka jaskrawoniebieskich, sprężystych roślin z owocami. Mróz zupełnie im nie przeszkadza."
	icon = 'aquila/icons/planets/flora/ice_jungle_flora.dmi'
	icon_state = "chilly_pepper"
	base_icon_state = "chilly_pepper"
	seed_type = /obj/item/plant_seeds/preset/chili/ice

// Jeden sprite (bazowe Initialize losuje stan 1-4)
/obj/structure/flora/ash/chilly/Initialize(mapload)
	. = ..()
	icon_state = "chilly_pepper"

/// Nasiona lodowej papryki do roślin planety lodowej (nasz krzew chili z owocem lodowej papryki)
/obj/item/plant_seeds/preset/chili/ice
	name = "nasiona: lodowa papryka (glina)"
	name_override = "lodowa papryka"
	icon_state = "seed-icepepper"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/chili, /datum/plant_feature/fruit/chili/blue)
