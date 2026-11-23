// AQUILA - planeta-śmietnisko (Shiptest: waste disposal planetoid, /datum/planet_type/waste z code/modules/overmap/
// planets/planet_types.dm). Generator i biomy w biomes/waste.dm, teren i śmieci w shiptest_flora/waste.dm, automaty
// w shiptest_fauna/automatons.dm, żyły w drill/veins_waste.dm, ruiny w ruins/planet_waste_ruins.dm.

/datum/planet_type/waste
	sky_state = "waste"
	sky_clouds = "clouds_wisps"
	sky_cloud_color = "#a89a70"
	sky_atmosphere_color = "#b0a0d0"
	name = "planeta-śmietnisko"
	desc = "Skażony świat zasypany śmieciami całej cywilizacji: wrakami, beczkami z odpadami i złomem, po którym krążą hivebota i porzucone automaty bojowe."
	overmap_icon_state = "planet_rocky"
	overmap_color = "#9a8fb8"
	generator_type = /datum/planet_generator/waste
	surface_area_type = /area/planet/surface/waste
	cave_area_type = /area/planet/surface/cave/waste
	ground_turf_type = /turf/open/floor/plating/asteroid/wasteplanet
	atmosphere_desc = "gęsta, z nadmiarem tlenu i domieszką dwutlenku węgla; da się nią oddychać"
	temperature_desc = "umiarkowana"
	hazard_desc = "promieniowanie, toksyczne deszcze i opad radioaktywny, miny, hivebota i automaty bojowe"
	weather_types = list(
		/datum/weather/planet/rain/toxic = 20,
		/datum/weather/planet/rain/toxic/heavy = 10,
		/datum/weather/planet/fallout = 40,
		/datum/weather/planet/fallout/dust = 10,
	)
	ruin_budget = 0
	vein_root = /obj/structure/vein/waste
	mission_veins = list(
		"1" = /obj/structure/vein/waste,
		"2" = /obj/structure/vein/waste/classtwo,
		"3" = /obj/structure/vein/waste/classthree,
	)
	system_tags = list("radioactive" = 4, "supernova" = 2, "graveyard" = 2)
	fixed_systems = list("UY Scuti", "Barnard's Star")

/datum/planet_type/waste/get_ruin_templates()
	return list()

/datum/planet_type/waste/get_main_ruin_templates()
	return get_planet_waste_ruin_templates()

/area/planet/surface/waste
	name = "Wysypisko"
	lighting_overlay_colour = "#6957aa"
	lighting_overlay_opacity = 51
	ambience_index = AMBIENCE_RUINS
	sound_environment = SOUND_ENVIRONMENT_QUARRY

/area/planet/surface/cave/waste
	name = "Jaskinie Wysypiska"
