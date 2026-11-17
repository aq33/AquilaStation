// AQUILA - planeta wodna: tabela biomów waterGenerator.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3). Cała powierzchnia
// to wzburzone, głębokie morze (/turf/open/water/planet/stormy, pływanie z water/), a wyspy to wyloty jaskiń
// (mountain_height 0,40). Turfy skały w shiptest_flora/beach.dm, żyły w drill/veins_water.dm.
// Różnice względem Shiptesta: pająki to nasze pająki-olbrzymy (tarantula, łowca, żmija), karpie nasze basic,
// ruda lodu w skale zamieniona (shiptest_flora/beach.dm).

#define PLANET_WATER_CAVE_FAUNA list(\
	/mob/living/basic/bear/cave = 5,\
	/mob/living/basic/mining/lobstrosity/beach = 1,\
)

/datum/planet_generator/water
	mountain_height = 0.40
	perlin_zoom = 55
	initial_closed_chance = 45
	smoothing_iterations = 20
	birth_limit = 4
	death_limit = 3

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ocean/stormy,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ocean/stormy,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/water/fault,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/water/fault,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/water/carpden,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/water/flooded,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/water/flooded/partially,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/water/fault,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/water/flooded,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/water/flooded,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/water,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/water/spider,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/water/flooded,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/water/flooded,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/water/flooded/partially,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/water,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/water,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/water/flooded,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/water/carpden,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/water/flooded/partially,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/water/spider,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/water,
		),
	)

/// Wzburzone morze (Shiptest: ocean/deep/waterplanet)
/datum/planet_biome/ocean/stormy
	open_turf_types = list(/turf/open/water/planet/stormy = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 1.4
	mob_spawn_list = list(/mob/living/basic/carp = 1)

/// Mokre jaskinie z rudami (Shiptest: cave/waterplanet)
/datum/planet_biome/cave/water
	open_turf_types = list(/turf/open/floor/plating/asteroid/waterplanet = 1)
	closed_turf_types = list(/turf/closed/mineral/random/waterplanet = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock/beach = 1,
		/obj/structure/flora/rock/asteroid = 6,
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
		/obj/structure/vein/waterplanet = 6,
		/obj/structure/vein/waterplanet/classtwo = 4,
		/obj/structure/vein/waterplanet/classthree = 2,
	)
	mob_spawn_chance = 1
	mob_spawn_list = PLANET_WATER_CAVE_FAUNA

/// Zalane korytarze
/datum/planet_biome/cave/water/flooded
	open_turf_types = list(/turf/open/water/planet/stormy/underground = 1)

/datum/planet_biome/cave/water/flooded/partially
	open_turf_types = list(
		/turf/open/water/planet/stormy/underground = 1,
		/turf/open/floor/plating/asteroid/waterplanet = 5,
	)

/// Legowisko karpi
/datum/planet_biome/cave/water/carpden
	open_turf_types = list(
		/turf/closed/mineral/random/waterplanet = 1,
		/turf/open/floor/plating/asteroid/waterplanet = 4,
	)
	mob_spawn_list = list(/mob/living/basic/carp = 1)

/// Pajęcze gniazda
/datum/planet_biome/cave/water/spider
	open_turf_types = list(
		/turf/closed/mineral/random/waterplanet = 1,
		/turf/open/floor/plating/asteroid/waterplanet = 5,
	)
	flora_spawn_list = list(
		/obj/structure/flora/rock/beach = 1,
		/obj/structure/spider/stickyweb = 6,
	)
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 20,
		/mob/living/simple_animal/hostile/spider/giant/hunter = 8,
		/mob/living/simple_animal/hostile/spider/giant/viper = 1,
	)

/// Uskok: woda w szczelinach, bez zwierząt
/datum/planet_biome/cave/water/fault
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/waterplanet = 5,
		/turf/open/water/planet/stormy/underground = 1,
	)
	mob_spawn_chance = 0

/// Planeta karłowata: samo wzburzone morze (Shiptest: single_turf/waterball) z rzadkimi wysepkami z bogatymi żyłami
/datum/planet_generator/water/dwarf
	mountain_height = 0.75

/datum/planet_generator/water/dwarf/New(turf/bottom_left, new_size, area/new_surface_area, area/new_cave_area)
	. = ..()
	for(var/heat_level in cave_biome_table)
		var/list/row = cave_biome_table[heat_level]
		for(var/humidity_level in row)
			row[humidity_level] = /datum/planet_biome/cave/water/rich

/// Wysepka planety karłowatej: bogatsze żyły (cel wypraw górniczych)
/datum/planet_biome/cave/water/rich
	feature_spawn_chance = 2
	feature_spawn_list = list(
		/obj/structure/vein/waterplanet = 2,
		/obj/structure/vein/waterplanet/classtwo = 4,
		/obj/structure/vein/waterplanet/classthree = 3,
	)

#undef PLANET_WATER_CAVE_FAUNA
