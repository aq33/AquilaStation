// AQUILA - planeta dżunglowa (Shiptest: /datum/planet_type/jungle, jungle planetoid). Generator i biomy w
// biomes/jungle.dm, turfy, pnącza i ogródki w shiptest_flora/jungle.dm, żyły w drill/veins_jungle.dm, ruiny, greeble
// i łaty trawy w ruins/planet_jungle_ruins.dm. Pogoda jak kontroler lush z Shiptesta (deszcz, ulewa, burza po 30).

/datum/planet_type/jungle
	name = "planeta dżunglowa"
	desc = "Świat porośnięty gęstym lasem, pnączami i poszyciem, pełen zwierząt. Z maczetą da się tu nawet żyć."
	overmap_icon_state = "planet_green"
	generator_type = /datum/planet_generator/jungle
	surface_area_type = /area/planet/surface/jungle
	cave_area_type = /area/planet/surface/cave/jungle
	atmosphere_desc = "oddychalna, wilgotna, ok. 115 kPa"
	temperature_desc = "ciepła, ok. 35 °C"
	hazard_desc = "ulewy i burze, gęste pnącza, wilki, niedźwiedzie, ogromne pająki w błotach i jaskiniach"
	weather_types = list(
		/datum/weather/planet/rain = 30,
		/datum/weather/planet/rain/heavy = 30,
		/datum/weather/planet/rain/heavy/storm = 30,
	)
	ground_turf_type = /turf/open/floor/plating/asteroid/dirt/jungle
	vein_root = /obj/structure/vein/jungle
	mission_veins = list(
		"1" = /obj/structure/vein/jungle,
		"2" = list(/obj/structure/vein/jungle/classtwo = 2, /obj/structure/vein/jungle/classtwo/rare = 1),
		"3" = list(/obj/structure/vein/jungle/classthree = 2, /obj/structure/vein/jungle/classthree/rare = 1),
		"4" = /obj/structure/vein/jungle/classfour,
	)
	system_tags = list("planet_earth" = 3, "safe" = 1)
	fixed_systems = list("Alpha Centauri", "Mediolanum")

/datum/planet_type/jungle/get_main_ruin_templates()
	return get_planet_jungle_ruin_templates()

/area/planet/surface/jungle
	name = "Dżungla"
	lighting_overlay_colour = "#d3dccb"
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_FOREST

/area/planet/surface/cave/jungle
	name = "Jaskinie Dżungli"
	sound_environment = SOUND_ENVIRONMENT_CAVE
