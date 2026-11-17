// AQUILA - planeta dżunglowa: tabela biomów JungleGenerator.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3). Turfy,
// pnącza i ogródki w shiptest_flora/jungle.dm, woda z łowiskiem z water/, fauna: nasze basic moby i simple animale
// (małpy, goryle, pająki, pszczoły), żyły w drill/veins_jungle.dm, greeble i łaty trawy w ruins/planet_jungle_ruins.dm.
// Zmiany względem Shiptesta: zardzewiały kilof w jaskiniach to zwykły kilof, kosmicznego melona (voidmelon) i roślin
// kosmicznych nie ma, kury dżungli to nasze zwykłe kury.

/datum/planet_generator/jungle
	mountain_height = 0.85
	perlin_zoom = 65

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/jungle/wasteland,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/jungle/wasteland,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/jungle/plains,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/jungle/plains,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/jungle/mudlands,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/jungle/wasteland,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/jungle/plains,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/jungle,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/jungle/mudlands,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/jungle/mudlands,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/jungle,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/jungle,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/jungle/mudlands,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/jungle/mudlands,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/jungle,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/jungle/dense,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/jungle/mudlands,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/jungle/water,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/jungle/water,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/jungle/mudlands,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/jungle,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/jungle,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/jungle/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/jungle/dense,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/jungle/dense,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/jungle/dense,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/jungle/dense,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/jungle/mudlands,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/jungle/water,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/jungle/water,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/jungle,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/jungle,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/jungle,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/jungle/dirt,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/jungle/lush,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/jungle/lush/bright,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/jungle/lush/bright,
		),
	)

/// Dżungla
/datum/planet_biome/jungle
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/grass/jungle = 1)
	flora_spawn_chance = 75
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 1,
		/obj/structure/flora/grass/jungle/b = 1,
		/obj/structure/flora/tree/jungle = 3,
		/obj/structure/flora/rock/jungle = 1,
		/obj/structure/flora/junglebush = 1,
		/obj/structure/flora/junglebush/b = 1,
		/obj/structure/flora/junglebush/c = 1,
		/obj/structure/flora/junglebush/large = 1,
		/obj/structure/spacevine/dense = 10,
		/obj/structure/flora/ash/garden = 1,
	)
	mob_spawn_chance = 0.3
	mob_spawn_list = list(
		/mob/living/carbon/monkey = 10,
		/mob/living/basic/chicken = 10,
		/obj/effect/spawner/lootdrop/jungle_chicken_flock = 1,
	)
	feature_spawn_chance = 1.4
	feature_spawn_list = list(
		/obj/structure/vein/jungle = 4,
		/obj/structure/vein/jungle/classtwo = 8,
		/obj/structure/vein/jungle/classtwo/rare = 4,
		/obj/structure/vein/jungle/classthree = 4,
		/obj/structure/vein/jungle/classthree/rare = 2,
		/obj/effect/greeble_spawner/jungle = 10,
		/obj/effect/greeble_spawner/jungle/anomaly = 1,
		/obj/effect/greeble_spawner/grass_patch/dark_jungle = 20,
		/obj/effect/greeble_spawner/grass_patch/yellow_jungle = 50,
	)

/// Gęsta dżungla
/datum/planet_biome/jungle/dense
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/dirt/grass/jungle = 1,
		/turf/open/floor/plating/asteroid/dirt/jungle/dark = 9,
	)
	flora_spawn_chance = 85
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 1,
		/obj/structure/flora/grass/jungle/b = 1,
		/obj/structure/flora/tree/jungle = 5,
		/obj/structure/flora/rock/jungle = 1,
		/obj/structure/flora/junglebush = 1,
		/obj/structure/flora/junglebush/b = 1,
		/obj/structure/flora/junglebush/c = 1,
		/obj/structure/flora/junglebush/large = 1,
		/obj/structure/spacevine/dense = 20,
		/obj/structure/flora/ash/garden = 1,
	)
	mob_spawn_chance = 0.6
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/gorilla = 1,
		/mob/living/carbon/monkey = 6,
		/mob/living/basic/chicken = 4,
		/obj/effect/spawner/lootdrop/jungle_chicken_flock = 1,
	)
	feature_spawn_chance = 2

/// Polany
/datum/planet_biome/jungle/plains
	flora_spawn_chance = 50
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/carbon/monkey = 1,
		/mob/living/basic/chicken = 1,
	)

/// Błota
/datum/planet_biome/jungle/mudlands
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/jungle/dark = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 1,
		/obj/structure/flora/grass/jungle/b = 1,
		/obj/structure/flora/rock/jungle = 1,
		/obj/structure/spacevine = 5,
	)
	mob_spawn_chance = 0.05
	mob_spawn_list = list(/mob/living/simple_animal/hostile/spider/giant/tarantula = 1)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(/obj/effect/greeble_spawner/jungle = 1)

/// Spękane pustkowia
/datum/planet_biome/jungle/wasteland
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/jungle/wasteland = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 0
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/structure/vein/jungle = 4,
		/obj/structure/vein/jungle/classtwo = 6,
		/obj/structure/vein/jungle/classthree = 2,
	)

/// Jeziora i rzeki
/datum/planet_biome/jungle/water
	open_turf_types = list(/turf/open/water/planet/jungle = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(/obj/structure/flora/rock = 1)
	mob_spawn_chance = 1
	mob_spawn_list = list(/mob/living/basic/carp = 1)
	feature_spawn_chance = 0

/// Jaskinie w boksycie
/datum/planet_biome/cave/jungle
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/dirt/jungle = 10,
		/turf/open/floor/plating/asteroid/dirt/jungle/dark = 10,
	)
	closed_turf_types = list(/turf/closed/mineral/random/planet_jungle = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/jungle = 1,
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 1,
		/obj/structure/flora/ash/puce = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/mining/wolf/random = 1,
		/mob/living/basic/bear/cave = 1,
		/mob/living/basic/bat = 1,
		/mob/living/basic/snake = 1,
	)
	feature_spawn_chance = 0.7
	feature_spawn_list = list(
		/obj/item/pickaxe = 1,
		/obj/structure/spawner/burrow/jungle_planet = 4,
		/obj/effect/spawner/lootdrop/planetary_anomaly/jungle/cave = 2,
		/obj/structure/vein/jungle = 8,
		/obj/structure/vein/jungle/classtwo = 4,
		/obj/effect/greeble_spawner/jungle/cave = 4,
	)

/// Wyschnięte jaskinie z krzakami
/datum/planet_biome/cave/jungle/dirt
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/jungle/wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/junglebush = 1,
		/obj/structure/flora/junglebush/b = 1,
		/obj/structure/flora/junglebush/c = 1,
		/obj/structure/flora/junglebush/large = 1,
		/obj/structure/flora/rock/pile/largejungle = 1,
		/obj/structure/flora/grass/jungle = 1,
		/obj/structure/flora/grass/jungle/b = 1,
		/obj/structure/flora/ash/garden = 1,
	)

/// Bujne jaskinie
/datum/planet_biome/cave/jungle/lush
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/grass/jungle = 1)
	flora_spawn_chance = 50
	flora_spawn_list = list(
		/obj/structure/flora/tree/jungle/small = 1,
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 2,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 2,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/spacevine/dense = 40,
		/obj/structure/flora/rock/jungle = 1,
		/obj/structure/flora/ash/garden = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/poison/bees = 1,
		/mob/living/basic/mushroom = 1,
		/mob/living/basic/capybara = 1,
	)

/datum/planet_biome/cave/jungle/lush/bright
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/dirt/grass/jungle = 12,
		/turf/open/water/planet/jungle = 1,
	)
	flora_spawn_chance = 40
	mob_spawn_list = list(/mob/living/basic/lightgeist = 1)
	feature_spawn_chance = 0.1
