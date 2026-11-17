// AQUILA - planeta lodowa: tabela biomów SnowGenerator.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3). Turfy i rośliny
// w shiptest_flora/ice.dm, fauna na naszych basic mobach (shiptest_fauna/), żyły w drill/veins_ice.dm, greeble i ruiny
// w ruins/planet_ice_ruins.dm, anomalie z anomalies/.
// Zmiany względem Shiptesta: ogródki to rośliny naszej botaniki, roślin kosmicznych (ash/space) nie ma, w jaskiniach
// zamiast nich grzyby.

/// Fauna powierzchni (wagi z Shiptesta)
#define PLANET_ICE_FAUNA list(\
	/mob/living/basic/mining/wolf/random = 30,\
	/obj/effect/spawner/lootdrop/polar_bear = 30,\
	/mob/living/basic/mining/legion/snow = 25,\
	/mob/living/basic/mining/goldgrub = 10,\
	/mob/living/basic/mining/ice_demon/random = 1,\
	/mob/living/basic/mining/ice_whelp = 1,\
	/mob/living/basic/mining/lobstrosity = 5,\
)

/datum/planet_generator/ice
	mountain_height = 0.45
	perlin_zoom = 55

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/arctic/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/iceberg/lake,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/iceberg,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/iceberg,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/arctic,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/arctic/rocky,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/lush,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/iceberg,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/thawed,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/forest,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/lush,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/iceberg,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/lush,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/forest/dense,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/forest/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/forest,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/lush,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/forest,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/thawed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/lush,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ice/forest/dense,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ice/forest,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/ice/thawed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/ice/forest/dense,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/ice/thawed,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/frozen,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/frozen,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/frozen,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice/thawed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/thawed,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/ice/thawed,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/ice/thawed,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/ice/plasma/less,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/ice/plasma,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/ice/plasma/total,
		),
	)

/// Śnieżne równiny
/datum/planet_biome/ice
	open_turf_types = list(/turf/open/floor/plating/asteroid/snow/planet_ice = 1)
	flora_spawn_chance = 10
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 4,
		/obj/structure/flora/rock/icy = 4,
		/obj/structure/flora/rock/pile/icy = 4,
		/obj/structure/flora/grass/both = 12,
		/obj/structure/flora/ash/chilly = 4,
		/obj/structure/flora/ash/garden/frigid = 2,
		/obj/structure/flora/ash/fonarstolbe = 2,
		/obj/structure/flora/ash/vahrezjia = 2,
		/obj/structure/flora/ash/earthenroot = 1,
		/obj/structure/flora/ash/dirtberries = 1,
		/obj/structure/flora/ash/sugartree = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/mining/wolf/random = 30,
		/obj/structure/spawner/burrow/ice_planet = 4,
		/obj/effect/spawner/lootdrop/polar_bear = 30,
		/mob/living/basic/mining/legion/snow = 25,
		/mob/living/basic/mining/goldgrub = 10,
		/mob/living/basic/mining/ice_demon/random = 5,
		/mob/living/basic/mining/ice_whelp = 5,
		/mob/living/basic/mining/lobstrosity = 10,
		/obj/effect/spawner/lootdrop/snow_monkey_pack = 5,
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
		/obj/effect/greeble_spawner/ice/anomaly = 20,
		/obj/effect/greeble_spawner/ice = 60,
		/obj/structure/spawner/burrow/ice_planet = 40,
		/obj/structure/vein/ice = 25,
		/obj/structure/vein/ice/classtwo = 50,
		/obj/structure/vein/ice/classtwo/rare = 10,
		/obj/structure/vein/ice/classthree = 10,
		/obj/structure/vein/ice/classthree/rare = 5,
	)

/datum/planet_biome/ice/lush
	flora_spawn_chance = 30
	flora_spawn_list = list(/obj/structure/flora/grass/both = 1)

/// Odwilż: lodowa skała z trawą i kwiatami
/datum/planet_biome/ice/thawed
	open_turf_types = list(/turf/open/floor/plating/asteroid/icerock = 1)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 2,
		/obj/structure/flora/ausbushes/sparsegrass = 2,
		/obj/structure/flora/ausbushes = 2,
		/obj/structure/flora/ausbushes/ppflowers = 2,
		/obj/structure/flora/ausbushes/lavendergrass = 2,
		/obj/structure/flora/ash/garden/frigid = 2,
		/obj/structure/flora/ash/podsneyzka = 2,
		/obj/structure/flora/ash/vahrezjia = 1,
		/obj/structure/flora/ash/earthenroot = 1,
		/obj/structure/flora/ash/dirtberries = 1,
		/obj/structure/flora/ash/sarezhi = 1,
		/obj/structure/flora/ash/ylpha = 1,
	)

/// Las iglasty
/datum/planet_biome/ice/forest
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/tree/dead = 6,
		/obj/structure/flora/grass/both = 8,
		/obj/structure/flora/ash/inozhakust = 2,
		/obj/structure/flora/ash/sugartree = 2,
		/obj/structure/flora/ash/fjylozyn = 1,
		/obj/structure/flora/ash/wulumunusha = 1,
	)

/datum/planet_biome/ice/forest/dense
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/grass/both = 6,
		/obj/structure/flora/tree/dead = 3,
	)

/// Arktyczna pustka: bałwany, nory i żyły
/datum/planet_biome/ice/arctic
	flora_spawn_chance = 0
	feature_spawn_chance = 1
	feature_spawn_list = list(
		/obj/effect/greeble_spawner/ice = 3,
		/obj/structure/spawner/burrow/ice_planet = 2,
		/obj/structure/statue/snow/snowman = 3,
		/obj/structure/statue/snow/snowlegion = 1,
		/obj/structure/vein/ice = 2,
		/obj/structure/vein/ice/classtwo = 3,
		/obj/structure/vein/ice/classthree = 1,
	)
	mob_spawn_list = list(
		/mob/living/basic/mining/wolf/random = 30,
		/obj/structure/spawner/burrow/ice_planet = 2,
		/obj/effect/spawner/lootdrop/polar_bear = 30,
		/mob/living/basic/mining/legion/snow = 25,
		/mob/living/basic/mining/goldgrub = 10,
		/mob/living/basic/mining/ice_demon/random = 1,
		/mob/living/basic/mining/ice_whelp = 1,
		/mob/living/basic/mining/lobstrosity = 5,
	)

/datum/planet_biome/ice/arctic/rocky
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/icy = 2,
		/obj/structure/flora/rock/pile/icy = 2,
	)

/// Kra i lodowe ściany
/datum/planet_biome/ice/iceberg
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/iceberg = 7,
		/turf/closed/mineral/planet_ice_wall = 10,
	)
	flora_spawn_chance = 0
	mob_spawn_chance = 2
	mob_spawn_list = PLANET_ICE_FAUNA
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/effect/greeble_spawner/ice/anomaly = 100,
		/obj/structure/spawner/burrow/ice_planet/hard = 600,
		/obj/structure/vein/ice = 300,
		/obj/structure/vein/ice/classtwo = 500,
		/obj/structure/vein/ice/classthree = 50,
	)

/// Zamarznięte jezioro: śliska tafla
/datum/planet_biome/ice/iceberg/lake
	open_turf_types = list(/turf/open/floor/plating/ice/planet_ice = 1)

/// Jaskinie w łupku
/datum/planet_biome/cave/ice
	open_turf_types = list(/turf/open/floor/plating/asteroid/icerock = 1)
	closed_turf_types = list(/turf/closed/mineral/random/planet_ice = 1)
	flora_spawn_chance = 6
	flora_spawn_list = list(
		/obj/structure/flora/grass/both = 10,
		/obj/structure/flora/rock/pile/icy = 2,
		/obj/structure/flora/rock/icy = 2,
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 4,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/puce = 2,
		/obj/structure/flora/ash/garden/frigid = 2,
		/obj/structure/flora/ash/fonarstolbe = 1,
		/obj/structure/flora/ash/vahrezjia = 1,
		/obj/structure/flora/ash/podsneyzka = 1,
		/obj/structure/flora/ash/inozhakust = 1,
		/obj/structure/flora/ash/seraka = 2,
		/obj/structure/flora/ash/glowgrowth = 1,
		/obj/structure/flora/ash/fjylozyn = 1,
		/obj/structure/flora/ash/wulumunusha = 1,
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/mining/wolf/random = 30,
		/obj/structure/spawner/burrow/ice_planet = 4,
		/obj/effect/spawner/lootdrop/polar_bear = 30,
		/mob/living/basic/mining/legion/snow = 25,
		/mob/living/basic/mining/goldgrub = 10,
		/mob/living/basic/mining/ice_demon/random = 1,
		/mob/living/basic/mining/ice_whelp = 1,
		/mob/living/basic/mining/lobstrosity = 10,
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/structure/spawner/burrow/ice_planet = 100,
		/obj/effect/spawner/lootdrop/planetary_anomaly/ice/cave = 10,
		/obj/structure/vein/ice = 30,
		/obj/structure/vein/ice/classtwo = 50,
		/obj/structure/vein/ice/classthree = 6,
	)

/datum/planet_biome/cave/ice/thawed
	open_turf_types = list(/turf/open/floor/plating/asteroid/icerock/cracked = 1)

/datum/planet_biome/cave/ice/frozen
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/icerock = 20,
		/turf/open/floor/plating/ice/planet_ice = 3,
	)

/// Najgorętsze jaskinie: bazalt i jeziora plazmy
/datum/planet_biome/cave/ice/plasma
	open_turf_types = list(
		/turf/open/lava/plasma/planet_ice = 10,
		/turf/open/floor/plating/asteroid/icerock/smooth = 1,
	)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 3,
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/stem_shroom = 3,
		/obj/structure/flora/ash/plasma_flower = 3,
		/obj/structure/flora/ash/glowgrowth = 2,
	)
	mob_spawn_list = PLANET_ICE_FAUNA

/datum/planet_biome/cave/ice/plasma/less
	open_turf_types = list(
		/turf/open/lava/plasma/planet_ice = 7,
		/turf/open/floor/plating/asteroid/icerock/smooth = 1,
	)

/datum/planet_biome/cave/ice/plasma/total
	open_turf_types = list(/turf/open/lava/plasma/planet_ice = 1)

#undef PLANET_ICE_FAUNA
