// AQUILA - planeta wulkaniczna: tabela biomów LavaGenerator.dm z Shiptesta. Turfy i rośliny z Shiptesta
// (shiptest_flora/), fauna na naszych basic mobach (shiptest_fauna/). Pominięte: żyły rud do wiertła (u nas nie ma
// misji wiertniczych, rudy są w ścianach) i spawnery anomalii.

/// Fauna powierzchni i jaskiń (wagi z Shiptesta)
#define PLANET_LAVA_SURFACE_FAUNA list(\
	/mob/living/basic/mining/goliath = 50,\
	/mob/living/basic/mining/watcher = 40,\
	/mob/living/basic/mining/legion = 30,\
	/mob/living/basic/mining/goldgrub/lavagrub = 10,\
	/mob/living/basic/mining/brimdemon = 20,\
	/mob/living/basic/mining/goliath/crystal = 1,\
	/mob/living/basic/mining/watcher/forgotten = 1,\
	/mob/living/basic/mining/legion/crystal = 1,\
	/obj/structure/spawner/burrow/lava_planet = 10,\
)
#define PLANET_LAVA_CAVE_FAUNA list(\
	/mob/living/basic/mining/goliath = 50,\
	/mob/living/basic/mining/watcher = 40,\
	/mob/living/basic/mining/legion = 30,\
	/mob/living/basic/mining/goldgrub/lavagrub = 10,\
	/obj/structure/spawner/burrow/lava_planet = 10,\
)

/datum/planet_generator/lava
	// Wartości koło 0,5 dają w szumie proste linie, stąd trochę mniej
	mountain_height = 0.45
	perlin_zoom = 65

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/forest,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/plains/dense/mixed,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/forest/rocky,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/plains/dense,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/plains,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/plains/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava/plains/dense/mixed,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/lush,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/forest,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/lava,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/plains/dense/mixed,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/forest,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/plains/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/lava,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/plains/dense/mixed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/lava,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/forest/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava/nearlava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/lava,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/lava/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/lava/rocky,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/lava/mossy,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/lava/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/lava/lava,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/lava/lava,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/lava/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/lava/mossy,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/lava/obsidian,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/lava/lava,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/lava/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/lava/mossy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/lava/obsidian,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/lava/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/lava/lava,
		),
	)

/// Bazaltowe równiny
/datum/planet_biome/lava
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/ywflowers/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 40,
		/obj/structure/flora/ash/fern = 5,
		/obj/structure/flora/ash/fireblossom = 1,
		/obj/structure/flora/ash/puce = 5,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/structure/flora/rock/hell = 34,
		/obj/structure/geyser/random = 6,
	)
	mob_spawn_chance = 1.5
	mob_spawn_list = PLANET_LAVA_SURFACE_FAUNA

/// Fioletowy las
/datum/planet_biome/lava/forest
	open_turf_types = list(/turf/open/floor/plating/asteroid/purple = 1)
	flora_spawn_chance = 80
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/tall/grey = 1,
		/obj/structure/flora/tree/dead/barren = 1,
		/obj/structure/flora/ausbushes/fullgrass/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 5,
	)

/datum/planet_biome/lava/forest/rocky
	flora_spawn_chance = 75
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile/lava = 5,
		/obj/structure/flora/rock/lava = 4,
		/obj/structure/flora/tree/dead/tall/grey = 10,
		/obj/structure/flora/ausbushes/fullgrass/hell = 40,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 20,
		/obj/structure/flora/ausbushes/hell = 4,
	)

/// Szkarłatne łąki
/datum/planet_biome/lava/plains
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/grass/lavaland = 1)
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass/hell = 50,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 35,
		/obj/structure/flora/ausbushes/ywflowers/hell = 1,
		/obj/structure/flora/ausbushes/grassybush/hell = 4,
		/obj/structure/flora/firebush = 1,
	)

/datum/planet_biome/lava/plains/dense
	flora_spawn_chance = 85
	feature_spawn_chance = 5
	feature_spawn_list = list(
		/obj/structure/flora/tree/dead/barren = 50,
		/obj/structure/flora/tree/dead/tall/grey = 45,
	)

/datum/planet_biome/lava/plains/dense/mixed
	flora_spawn_chance = 50
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/dirt/grass/lavaland = 95,
		/turf/open/floor/plating/moss = 1,
	)

/// Pustkowia
/datum/planet_biome/lava/outback
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/grass/lavaland = 1)
	flora_spawn_chance = 30
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/grassybush/hell = 10,
		/obj/structure/flora/ausbushes/genericbush/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 3,
		/obj/structure/flora/ausbushes/hell = 3,
		/obj/structure/flora/tree/dead/hell = 3,
		/obj/structure/flora/rock/lava = 2,
	)

/// Bujne zakątki
/datum/planet_biome/lava/lush
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/dirt/grass/lavaland = 20,
		/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1,
	)
	flora_spawn_chance = 30
	flora_spawn_list = list(
		/obj/structure/flora/ash/fireblossom = 3,
		/obj/structure/flora/tree/dead/hell = 1,
		/obj/structure/flora/ausbushes/grassybush/hell = 5,
		/obj/structure/flora/ausbushes/fullgrass/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 8,
		/obj/structure/flora/ausbushes/hell = 5,
		/obj/structure/flora/ausbushes/fernybush/hell = 5,
		/obj/structure/flora/ausbushes/genericbush/hell = 5,
		/obj/structure/flora/ausbushes/ywflowers/hell = 7,
		/obj/structure/flora/firebush = 3,
	)

/// Jeziora lawy
/datum/planet_biome/lava/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface = 1)
	flora_spawn_chance = 2
	flora_spawn_list = list(/obj/structure/flora/rock/lava = 1, /obj/structure/flora/rock/pile/lava = 1)
	feature_spawn_chance = 0
	mob_spawn_chance = 0

/// Brzeg lawy: obsydian
/datum/planet_biome/lava/nearlava
	open_turf_types = list(/turf/open/floor/plating/asteroid/obsidian = 1)
	flora_spawn_chance = 2
	flora_spawn_list = list(/obj/structure/flora/rock/lava = 1, /obj/structure/flora/rock/pile/lava = 1)

/// Jaskinie w skale wulkanicznej z rudami
/datum/planet_biome/cave/lava
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/fern = 2,
		/obj/structure/flora/ash/puce = 2,
	)
	mob_spawn_chance = 1.5
	mob_spawn_list = PLANET_LAVA_CAVE_FAUNA

/datum/planet_biome/cave/lava/obsidian
	open_turf_types = list(/turf/open/floor/plating/asteroid/obsidian = 1)

/datum/planet_biome/cave/lava/rocky
	open_turf_types = list(/turf/open/floor/plating/asteroid/purple = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(/obj/structure/flora/rock/pile/lava = 6, /obj/structure/flora/rock/lava = 6)

/datum/planet_biome/cave/lava/mossy
	open_turf_types = list(/turf/open/floor/plating/moss = 1)
	flora_spawn_chance = 80
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 5,
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
	)

/datum/planet_biome/cave/lava/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface = 1)
	feature_spawn_chance = 1
	feature_spawn_list = list(/obj/structure/flora/rock/pile/lava = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 0

#undef PLANET_LAVA_SURFACE_FAUNA
#undef PLANET_LAVA_CAVE_FAUNA
