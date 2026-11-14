// AQUILA - planeta wulkaniczna: tabela biomów LavaGenerator.dm z Shiptesta. Turfy, rośliny i moby Shiptesta, których
// nie mamy (fioletowy grunt, obsydian, trawa lawowa, mech, piekielne krzewy, żyły rud do wiertła), zastąpione naszymi
// odpowiednikami z Lavalandu; moby to nasze basic moby górnicze.

/datum/planet_generator/lava
	// Wartości koło 0,5 dają w szumie proste linie, stąd trochę mniej
	mountain_height = 0.45
	perlin_zoom = 65

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/forest,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/plains/dense,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/forest/rocky,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/plains/dense,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/plains,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/plains/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava/plains/dense,
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
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/plains/dense,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava/forest,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/plains/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/lava/lava,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/lava/outback,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/lava,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/lava/plains/dense,
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
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/lava/lava,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/lava/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/lava/mossy,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/lava,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/lava/lava,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/lava/lava,
		),
	)

/// Bazaltowe równiny: zwierzęta, gejzery, rzadkie skały
/datum/planet_biome/lava
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	flora_spawn_chance = 2
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 3,
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/stem_shroom = 3,
		/obj/structure/flora/ash/cacti = 2,
		/obj/structure/flora/rock/pile = 4,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/geyser/random = 6,
	)
	mob_spawn_chance = 1.5
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath = 50,
		/mob/living/basic/mining/watcher = 40,
		/mob/living/basic/mining/legion = 30,
		/mob/living/basic/mining/goldgrub = 10,
		/mob/living/basic/mining/basilisk = 15,
	)

/// Martwy las
/datum/planet_biome/lava/forest
	open_turf_types = list(/turf/open/floor/plating/ashplanet/rocky = 1)
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead = 3,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
	)

/datum/planet_biome/lava/forest/rocky
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 5,
		/obj/structure/flora/rock = 4,
		/obj/structure/flora/tree/dead = 6,
	)

/// Popielne równiny
/datum/planet_biome/lava/plains
	open_turf_types = list(/turf/open/floor/plating/ashplanet/ash = 1)
	flora_spawn_chance = 8
	flora_spawn_list = list(
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/leaf_shroom = 3,
		/obj/structure/flora/ash/cacti = 1,
	)

/datum/planet_biome/lava/plains/dense
	flora_spawn_chance = 25
	feature_spawn_chance = 2
	feature_spawn_list = list(
		/obj/structure/flora/tree/dead = 50,
		/obj/structure/geyser/random = 5,
	)

/// Pustkowia między bazaltem a popiołem
/datum/planet_biome/lava/outback
	open_turf_types = list(
		/turf/open/floor/plating/ashplanet/rocky = 3,
		/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1,
	)
	flora_spawn_chance = 10
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 3,
		/obj/structure/flora/rock = 2,
		/obj/structure/flora/tree/dead = 1,
	)

/// Żyzne zakątki z grzybami
/datum/planet_biome/lava/lush
	open_turf_types = list(
		/turf/open/floor/plating/ashplanet/ash = 4,
		/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1,
	)
	flora_spawn_chance = 30
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 3,
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/stem_shroom = 3,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
	)

/// Jeziora lawy
/datum/planet_biome/lava/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface = 1)
	flora_spawn_chance = 0
	feature_spawn_chance = 0
	mob_spawn_chance = 0

/// Brzeg lawy: goły bazalt
/datum/planet_biome/lava/nearlava
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	flora_spawn_chance = 2
	flora_spawn_list = list(/obj/structure/flora/rock/pile = 1, /obj/structure/flora/rock = 1)

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
	)
	mob_spawn_chance = 1.5
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath = 50,
		/mob/living/basic/mining/watcher = 30,
		/mob/living/basic/mining/legion = 30,
		/mob/living/basic/mining/goldgrub = 15,
		/mob/living/basic/mining/hivelord = 20,
	)

/datum/planet_biome/cave/lava/rocky
	open_turf_types = list(/turf/open/floor/plating/ashplanet/rocky = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(/obj/structure/flora/rock/pile = 6, /obj/structure/flora/rock = 6)

/datum/planet_biome/cave/lava/mossy
	open_turf_types = list(/turf/open/floor/plating/ashplanet/ash = 1)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
	)

/datum/planet_biome/cave/lava/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 0
