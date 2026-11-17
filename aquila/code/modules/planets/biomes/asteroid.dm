// AQUILA - pole asteroid i słaby sygnał: tabela biomów AsteroidGenerator.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3).
// Na „powierzchni” jest próżnia kosmiczna (czasem z karpiami), a „jaskinie” automatu komórkowego to bryły asteroid:
// ściany ze zwykłą skałą asteroid, w środku grunt asteroidy, lód albo legowisko karpi.
// Zmiany względem Shiptesta: bez melona próżniowego (nie mamy rośliny), fauna na naszych basic mobach, a pre_generation
// (wysokość gór z sąsiedniego zdarzenia overmapy) pominięty, bo u nas pole asteroid nie ma takich zdarzeń.

/datum/planet_generator/asteroid
	mountain_height = 0.7
	perlin_zoom = 20

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/asteroid,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/asteroid,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/asteroid,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/asteroid/carp,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/asteroid/carp,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/asteroid,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/asteroid/carp,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/asteroid/carp,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/asteroid/ice,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/asteroid/ice,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/asteroid/ice,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/asteroid/ice,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/asteroid/ice,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/asteroid/carp_den,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/asteroid/carp_den,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/asteroid,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/asteroid/carp_den,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/asteroid/carp_den,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/asteroid/carp_den,
		),
	)

/// Pusta przestrzeń między bryłami
/datum/planet_biome/asteroid
	open_turf_types = list(/turf/open/space = 1)
	flora_spawn_chance = 0
	feature_spawn_chance = 0
	mob_spawn_chance = 0

/// Przestrzeń z ławicami karpi
/datum/planet_biome/asteroid/carp
	mob_spawn_list = list(/mob/living/basic/carp = 1)
	mob_spawn_chance = 1

/// Bryła asteroidy (Shiptest: cave/asteroid/vanilla)
/datum/planet_biome/cave/asteroid
	closed_turf_types = list(/turf/closed/mineral/random = 1)
	open_turf_types = list(/turf/open/floor/plating/asteroid/airless = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
	)
	feature_spawn_list = list(
		/obj/structure/spawner/burrow/asteroid = 3,
		/obj/structure/geyser/random = 1,
		/obj/structure/vein/asteroid = 5,
		/obj/structure/vein/asteroid/classtwo = 10,
		/obj/structure/vein/asteroid/classtwo/rare = 3,
		/obj/structure/vein/asteroid/classthree = 5,
		/obj/structure/vein/asteroid/classthree/rare = 1,
	)
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath = 25,
		/mob/living/basic/mining/basilisk = 25,
		/mob/living/basic/mining/hivelord = 25,
		/mob/living/basic/mining/goldgrub = 10,
	)
	flora_spawn_chance = 2
	feature_spawn_chance = 1
	mob_spawn_chance = 6

/// Lodowe wnętrze bryły
/datum/planet_biome/cave/asteroid/ice
	open_turf_types = list(/turf/open/floor/plating/ice/airless = 1)
	mob_spawn_chance = 2

/// Legowisko karpi
/datum/planet_biome/cave/asteroid/carp_den
	closed_turf_types = list(/turf/closed/mineral/random = 5)
	flora_spawn_list = list(
		/obj/structure/flora/rock = 1,
		/obj/structure/flora/rock/pile = 1,
	)
	feature_spawn_list = list(
		/obj/structure/geyser/random = 5,
		/obj/structure/spawner/carp = 5,
		/obj/structure/vein/asteroid = 10,
		/obj/structure/vein/asteroid/classtwo = 15,
		/obj/structure/vein/asteroid/classthree = 12,
	)
	mob_spawn_list = list(
		/mob/living/basic/carp = 25,
		/mob/living/basic/carp/mega = 30,
	)
	flora_spawn_chance = 2
	feature_spawn_chance = 10
	mob_spawn_chance = 18
