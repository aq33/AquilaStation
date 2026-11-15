// AQUILA - planeta oceaniczna (plaża) z Shiptesta (shiptest-ss13/Shiptest, AGPLv3): code/modules/overmap/planets/
// planet_types.dm (/datum/planet_type/beach), generator w biomes/beach.dm, ruiny w ruins/planet_beach_ruins.dm.
// Ciepła i oddychalna atmosfera, deszcze i burze (pogoda „lush”), płycizny z rybami i głębia, w której trzeba płynąć.

/datum/planet_type/beach
	name = "planeta oceaniczna"
	desc = "Wzorcowe miejsce na urlop: ciepło, wygodnie i da się oddychać. Piaszczyste plaże, łąki i dżungla między płyciznami a głębinami oceanu."
	overmap_icon_state = "planet_ocean"
	overmap_color = "#e6dcc6"
	generator_type = /datum/planet_generator/beach
	surface_area_type = /area/planet/surface/beach
	cave_area_type = /area/planet/surface/cave/beach
	atmosphere_desc = "oddychalna, ciepła i wilgotna"
	temperature_desc = "umiarkowana, około 20°C"
	hazard_desc = "głęboka woda, burze z piorunami, homarzyska i niedźwiedzie w jaskiniach"
	weather_types = list(
		/datum/weather/planet/rain = 30,
		/datum/weather/planet/rain/heavy = 30,
		/datum/weather/planet/rain/heavy/storm = 30,
	)
	ruin_budget = 0
	ground_turf_type = /turf/open/floor/plating/asteroid/sand
	vein_root = /obj/structure/vein/beach
	mission_veins = list(
		"1" = /obj/structure/vein/beach,
		"2" = /obj/structure/vein/beach/classtwo,
	)
	system_tags = list("planet_earth" = 3, "safe" = 1)
	fixed_systems = list("Sirius", "Orion's Arm")

/datum/planet_type/beach/get_ruin_templates()
	return list()

/datum/planet_type/beach/get_main_ruin_templates()
	return get_planet_sea_ruin_templates(/datum/map_template/ruin/planet_beach)

/area/planet/surface/beach
	name = "Wybrzeże"
	lighting_overlay_colour = "#faeacb"
	lighting_overlay_opacity = 90
	sound_environment = SOUND_ENVIRONMENT_FOREST

/area/planet/surface/cave/beach
	name = "Groty Wybrzeża"
