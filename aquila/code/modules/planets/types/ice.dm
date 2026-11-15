// AQUILA - planeta lodowa (Shiptest: /datum/planet_type/ice, frozen planetoid). Generator i biomy w biomes/ice.dm,
// turfy w shiptest_flora/ice.dm, żyły w drill/veins_ice.dm, ruiny i greeble w ruins/planet_ice_ruins.dm.
// Pogoda jak kontroler snow_planet z Shiptesta (burza śnieżna 50, opady 20, śnieżyca 20, grad 20).

/datum/planet_type/ice
	name = "planeta lodowa"
	desc = "Zamarznięta planeta pod grubą warstwą śniegu i jeszcze grubszą lodu, pełna groźnych drapieżników."
	overmap_icon_state = "planet_rockocean"
	overmap_color = "#d8ecff"
	generator_type = /datum/planet_generator/ice
	surface_area_type = /area/planet/surface/ice
	cave_area_type = /area/planet/surface/cave/ice
	atmosphere_desc = "oddychalna, tlen i azot, ok. 110 kPa"
	temperature_desc = "mroźna, ok. -18 °C"
	hazard_desc = "burze śnieżne i grad, wilki, niedźwiedzie polarne, demony lodowe, smoki lodowe, jeziora plazmy w jaskiniach"
	weather_types = list(
		/datum/weather/snow_storm/planet = 50,
		/datum/weather/planet/snowfall = 20,
		/datum/weather/planet/snowfall/heavy = 20,
		/datum/weather/planet/hailstorm = 20,
	)
	ground_turf_type = /turf/open/floor/plating/asteroid/snow/planet_ice
	vein_root = /obj/structure/vein/ice
	mission_veins = list(
		"1" = /obj/structure/vein/ice,
		"2" = list(/obj/structure/vein/ice/classtwo = 2, /obj/structure/vein/ice/classtwo/rare = 1),
		"3" = list(/obj/structure/vein/ice/classthree = 2, /obj/structure/vein/ice/classthree/rare = 1),
		"4" = /obj/structure/vein/ice/classfour,
	)
	system_tags = list("ice_planet" = 4, "icefield" = 4)
	fixed_systems = list("Gliese 581-G", "Karip", "Argo", "Keid")

/datum/planet_type/ice/get_main_ruin_templates()
	return get_planet_ice_ruin_templates()

/area/planet/surface/ice
	name = "Lodowe Pustkowia"
	lighting_overlay_colour = "#e1d1e6"
	ambience_index = AMBIENCE_SPOOKY

/area/planet/surface/cave/ice
	name = "Lodowe Jaskinie"
	sound_environment = SOUND_ENVIRONMENT_CAVE
