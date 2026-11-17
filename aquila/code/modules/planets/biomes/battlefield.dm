// AQUILA - pole bitwy: tabela biomów battlefield_generator.dm z Shiptesta (AGPLv3). Biomy Shiptesta dziedziczą listy po
// biomach dżungli (jungle, mudlands, jungle/water) i pustyni (dry_seafloor, cave/desert): tu są wypisane wprost, z tym, co
// z nich zostaje (tarantule w błocie, żyły pustyni na dnie morza i w jaskiniach). Turfy i martwe pnącza
// w shiptest_flora/battlefield.dm, żyły w drill/veins_waste.dm.
// Zmiany względem Shiptesta: kratery to rozrzucone leje (dziury w gruncie z naszego greebla nie ma w Shiptest, tam to
// komentarz „crater greeble” bez kodu), więc są tu proste plamy pustkowia z wrakami; skały plażowe i asteroidowe z jaskiń
// -> nasze skały.

/datum/planet_generator/battlefield
	perlin_zoom = 65
	mountain_height = 0.85

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/battlefield/seafloor,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/battlefield/seafloor,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/battlefield/seafloor,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/battlefield/nomansland,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/battlefield/nomansland,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/battlefield/seafloor,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/battlefield/nomansland,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/battlefield/nomansland,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/battlefield/mud,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/battlefield/mud,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/battlefield/nomansland,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/battlefield,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/battlefield/mud,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/battlefield/mud,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/battlefield,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/battlefield/dense,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/battlefield/mud,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/battlefield/water,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/battlefield/water,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/battlefield/mud,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/battlefield,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/battlefield,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/battlefield/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/battlefield/dense,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/battlefield/dense,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/battlefield/dense,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/battlefield/dense,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/battlefield/mud,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/battlefield/water,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/battlefield/water,
		),
	)

	// W Shiptest cała tabela jaskiń to jeden biom
	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/battlefield,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/battlefield,
		),
	)

/// Zryta ziemia z martwymi drzewami i pnączami (Shiptest: jungle/battlefield)
/datum/planet_biome/battlefield
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/battlefield = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/tall = 3,
		/obj/structure/flora/rock = 1,
		/obj/structure/spacevine/dead = 7,
	)
	flora_spawn_chance = 70
	feature_spawn_list = list(
		/obj/effect/spawner/lootdrop/waste/mechwreck = 3,
		/obj/effect/spawner/lootdrop/waste/mechwreck/rare = 1,
		/obj/effect/spawner/lootdrop/waste/mine = 2,
	)
	feature_spawn_chance = 0.2
	mob_spawn_chance = 0

/datum/planet_biome/battlefield/dense
	flora_spawn_chance = 80
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/tall = 10,
		/obj/structure/flora/rock = 1,
		/obj/structure/spacevine/dead = 25,
	)

/// Ziemia niczyja
/datum/planet_biome/battlefield/nomansland
	flora_spawn_chance = 30
	feature_spawn_chance = 0.6

/// Błota z rzadkimi tarantulami (Shiptest: mudlands/battlefield)
/datum/planet_biome/battlefield/mud
	flora_spawn_list = list(
		/obj/structure/flora/rock = 1,
		/obj/structure/spacevine/dead = 5,
	)
	flora_spawn_chance = 10
	mob_spawn_chance = 0.05
	mob_spawn_list = list(/mob/living/simple_animal/hostile/spider/giant/tarantula = 1)

/// Wyschnięte dno morza z żyłami (Shiptest: dry_seafloor/battlefield, żyły pustyni)
/datum/planet_biome/battlefield/seafloor
	open_turf_types = list(/turf/open/floor/plating/asteroid/battlefield_wasteland = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 5,
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/ash/cacti = 1,
	)
	flora_spawn_chance = 1
	feature_spawn_list = list(
		/obj/structure/vein/battlefield = 4,
		/obj/structure/vein/battlefield/classtwo = 6,
		/obj/structure/vein/battlefield/classthree = 2,
		/obj/effect/spawner/lootdrop/waste/mechwreck = 2,
	)
	feature_spawn_chance = 0.5

/// Skażona woda
/datum/planet_biome/battlefield/water
	open_turf_types = list(/turf/open/water/planet/battlefield = 1)
	flora_spawn_list = list(/obj/structure/flora/rock = 1)
	flora_spawn_chance = 1
	feature_spawn_chance = 0

/// Jaskinie: ziemia w ścianach dżungli z żyłami pustyni
/datum/planet_biome/cave/battlefield
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/battlefield = 1)
	closed_turf_types = list(/turf/closed/mineral/random/jungle/battlefield = 1)
	flora_spawn_list = list(/obj/structure/flora/rock/pile = 1, /obj/structure/flora/rock = 6)
	flora_spawn_chance = 4
	feature_spawn_list = list(
		/obj/structure/vein/battlefield = 6,
		/obj/structure/vein/battlefield/classtwo = 4,
		/obj/structure/vein/battlefield/classthree = 2,
	)
	feature_spawn_chance = 0.2
	mob_spawn_chance = 0
