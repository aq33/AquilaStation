// AQUILA - planety karłowate (Shiptest: snowball, dustball, duneball, waterball). W Shiptest to jeden turf na całą
// mapę i burza bez końca („na pewno nic ciekawego”); u nas decyzja „małe mapy + żyły”: mniejsza powierzchnia
// (PLANET_SURFACE_SIZE_DWARF), ten sam teren co duży odpowiednik w małej skali, bez ruin i greebli, za to bogatsze
// żyły rudy pod wiertło. Wspólny rodzic nie pojawia się sam (bez znaczników układu, poza misjami); podtypy innych
// rodzajów (pyłowa, wydmowa, wodna) dopisują partie tych planet we własnych plikach.

/datum/planet_type/dwarf
	name = null
	abstract_type = /datum/planet_type/dwarf
	surface_size = PLANET_SURFACE_SIZE_DWARF
	ruin_budget = 0
	mission_target = FALSE
	overmap_icon_state = "planet_small"

/datum/planet_type/dwarf/get_main_ruin_templates()
	return list()

/// Śnieżna planeta karłowata (Shiptest: snowball)
/datum/planet_type/dwarf/snow
	name = "śnieżna planeta karłowata"
	desc = "Mały świat w całości zasypany śniegiem przez gwałtowne burze. Pod śniegiem kryją się bogate złoża."
	overmap_color = "#eef6ff"
	generator_type = /datum/planet_generator/dwarf_snow
	surface_area_type = /area/planet/surface/ice/dwarf
	cave_area_type = /area/planet/surface/cave/ice
	atmosphere_desc = "oddychalna, tlen i azot, ok. 110 kPa"
	temperature_desc = "mroźna, ok. -18 °C"
	hazard_desc = "częste burze śnieżne i grad, wilki i niedźwiedzie polarne"
	weather_types = list(/datum/weather/snow_storm/planet = 50, /datum/weather/planet/hailstorm = 10)
	weather_delay_min = 2 MINUTES
	weather_delay_max = 5 MINUTES
	ground_turf_type = /turf/open/floor/plating/asteroid/snow/planet_ice
	mission_target = TRUE
	vein_root = /obj/structure/vein/ice
	mission_veins = list(
		"1" = /obj/structure/vein/ice/dwarf,
		"2" = /obj/structure/vein/ice/classtwo/dwarf,
		"3" = /obj/structure/vein/ice/classthree/dwarf,
	)
	system_tags = list("icefield" = 2, "ice_planet" = 1, "safe" = 1)
	fixed_systems = list("Medea", "Caph")

/area/planet/surface/ice/dwarf
	name = "Śnieżne Pustkowia"

/// Generator śnieżnej planety karłowatej: śnieg i lodowa skała, pod spodem lodowe jaskinie
/datum/planet_generator/dwarf_snow
	mountain_height = 0.6
	perlin_zoom = 40

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/dwarf/rocky,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/dwarf,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/dwarf,
		),
	)

/// Śnieg z bogatymi żyłami i nielicznymi zwierzętami
/datum/planet_biome/ice/dwarf
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock/icy = 4,
		/obj/structure/flora/rock/pile/icy = 4,
		/obj/structure/flora/grass/both = 6,
		/obj/structure/flora/ash/chilly = 2,
	)
	mob_spawn_chance = 0.5
	mob_spawn_list = list(
		/mob/living/basic/mining/wolf/random = 30,
		/obj/effect/spawner/lootdrop/polar_bear = 20,
		/mob/living/basic/mining/goldgrub = 10,
	)
	feature_spawn_chance = 1
	feature_spawn_list = list(
		/obj/structure/vein/ice/dwarf = 30,
		/obj/structure/vein/ice/classtwo/dwarf = 50,
		/obj/structure/vein/ice/classthree/dwarf = 20,
	)

/datum/planet_biome/ice/dwarf/rocky
	open_turf_types = list(/turf/open/floor/plating/asteroid/icerock = 1)

/// Lodowe jaskinie planety karłowatej: więcej rud w ścianach
/datum/planet_biome/cave/ice/dwarf
	closed_turf_types = list(/turf/closed/mineral/random/planet_ice/underground = 1)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
		/obj/structure/spawner/burrow/ice_planet = 20,
		/obj/structure/vein/ice/dwarf = 30,
		/obj/structure/vein/ice/classtwo/dwarf = 40,
		/obj/structure/vein/ice/classthree/dwarf = 20,
	)
