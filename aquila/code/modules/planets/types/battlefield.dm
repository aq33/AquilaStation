// AQUILA - pole bitwy (Shiptest: battlefield planetoid). Generator i biomy w biomes/battlefield.dm, turfy i martwe
// pnącza w shiptest_flora/battlefield.dm, żyły w drill/veins_waste.dm, ruiny (pożyczone ze śmietniska)
// w ruins/planet_waste_ruins.dm. W Shiptest pole bitwy nie ma fauny poza żyłami i rzadkimi tarantulami w błocie.

/datum/planet_type/battlefield
	name = "pole bitwy"
	desc = "Wyniszczony świat po dawnej wojnie: zryta lejami ziemia, martwe lasy, skażona woda i wraki maszyn. Pod spękanym dnem wyschniętego morza leżą złoża rud."
	overmap_icon_state = "planet_night"
	overmap_color = "#a69a7a"
	generator_type = /datum/planet_generator/battlefield
	surface_area_type = /area/planet/surface/battlefield
	cave_area_type = /area/planet/surface/cave/battlefield
	ground_turf_type = /turf/open/floor/plating/asteroid/dirt/battlefield
	atmosphere_desc = "oddychalna"
	temperature_desc = "umiarkowana"
	hazard_desc = "toksyczne deszcze, skażona woda, niewybuchy i wraki"
	weather_types = list(
		/datum/weather/planet/rain/toxic = 60,
		/datum/weather/planet/rain/toxic/heavy = 40,
		/datum/weather/planet/rain/toxic/heavy/severe = 20,
	)
	ruin_budget = 0
	vein_root = /obj/structure/vein/battlefield
	mission_veins = list(
		"1" = /obj/structure/vein/battlefield,
		"2" = /obj/structure/vein/battlefield/classtwo,
		"3" = /obj/structure/vein/battlefield/classthree,
	)
	system_tags = list("graveyard" = 4, "radioactive" = 2, "pirate" = 1)
	fixed_systems = list("Wolf 359", "Dolos Remnants", "Rubicon")
	// Fauny prawie brak (jak w Shiptest), więc Badanie planety nie dałoby się wykonać
	mission_target = FALSE

/datum/planet_type/battlefield/get_ruin_templates()
	return list()

/datum/planet_type/battlefield/get_main_ruin_templates()
	return get_planet_battlefield_ruin_templates()

/area/planet/surface/battlefield
	name = "Pole Bitwy"
	lighting_overlay_colour = "#849abf"
	ambience_index = AMBIENCE_RUINS
	sound_environment = SOUND_ENVIRONMENT_CITY

/area/planet/surface/cave/battlefield
	name = "Jaskinie Pola Bitwy"
