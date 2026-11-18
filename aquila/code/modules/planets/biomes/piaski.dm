// AQUILA - biomy planet skalistych, białych piasków, pustynnych i mglistych: tabele z Shiptesta
// (code/datums/mapgen/planetary/RockGenerator.dm, SandGenerator.dm, desertGenerator.dm, shroudedGenerator.dm).
// Zmiany względem Shiptesta:
// - fauna to nasze moby z portu fauny (gruboid, młody gruboid, stwór, migo, rozdymka, goliat i bazyliszek białych
//   piasków, mrówkolwy, cragenoy), pustelnicy to nasi piraci (planet_hermit);
// - ogródki Shiptesta (ash/garden/arid) to rośliny botaniki, które już mamy (kaktusy), jak przy lawie;
// - spawner losowej konserwacji to nasz lootdrop/maintenance;
// - planeta mglista: Shiptest definiuje cragenoya w jaskiniach z szansą 0 (nigdy się nie pojawia), u nas 0,5%;
// - planety karłowate (pyłowa, wydmowa): Shiptest to jeden turf na całość; u nas (decyzja: małe mapy z bogatszymi
//   żyłami) biom dużego odpowiednika bez jaskiń, z żyłami trzy razy częstszymi i bez ruin.

/// Tabela biomów z jednym biomem na każde pole (pustynia, planeta mglista, planety karłowate)
#define PLANET_SINGLE_BIOME_TABLE(biome) list(\
	PLANET_BIOME_COLDEST = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_COLD = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_WARM = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_TEMPERATE = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_HOT = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_HOTTEST = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
)
#define PLANET_SINGLE_CAVE_TABLE(biome) list(\
	PLANET_BIOME_COLDEST_CAVE = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_COLD_CAVE = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_WARM_CAVE = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
	PLANET_BIOME_HOT_CAVE = list(PLANET_BIOME_LOWEST_HUMIDITY = biome, PLANET_BIOME_LOW_HUMIDITY = biome, PLANET_BIOME_MEDIUM_HUMIDITY = biome, PLANET_BIOME_HIGH_HUMIDITY = biome, PLANET_BIOME_HIGHEST_HUMIDITY = biome),\
)

#define PLANET_ROCK_SURFACE_FAUNA list(\
	/mob/living/basic/creature = 30,\
	/mob/living/basic/wumborian_fugu = 30,\
	/mob/living/basic/migo = 20,\
	/mob/living/basic/mining/goliath/rockplanet = 30,\
	/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 50,\
)
#define PLANET_SAND_FAUNA list(\
	/mob/living/basic/mining/goliath/whitesands/random = 50,\
	/mob/living/basic/mining/basilisk/whitesands = 40,\
	/mob/living/basic/mining/legion/random = 30,\
	/obj/effect/spawner/lootdrop/planet_hermit = 25,\
)
#define PLANET_DESERT_FAUNA list(\
	/mob/living/basic/mining/antlion = 100,\
	/mob/living/basic/lizard = 20,\
	/mob/living/basic/mining/antlion/mega = 10,\
)

// Planeta skalista

/datum/planet_generator/rock
	mountain_height = 0.45
	perlin_zoom = 65
	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/rock/icecap,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/rock/icecap,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/rock/icecap,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/rock/wetlands,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/rock/wetlands,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/rock/wetlands,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/rock/wetlands,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/rock,
		),
	)
	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/rock,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/rock/wet,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/rock/wet,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/rock/wet,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/rock,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/rock/wet,
		),
	)

/// Rdzawe równiny
/datum/planet_biome/rock
	open_turf_types = list(/turf/open/floor/plating/asteroid/rockplanet = 1)
	feature_spawn_chance = 0.25
	feature_spawn_list = list(
		/obj/structure/geyser/random = 80,
		/obj/structure/vein/rockplanet = 60,
		/obj/structure/vein/rockplanet/classtwo = 40,
		/obj/effect/spawner/lootdrop/planetary_anomaly/rock = 10,
		/obj/structure/vein/rockplanet/classthree = 10,
		/obj/structure/vein/rockplanet/classthree/rare = 5,
		/obj/effect/spawner/lootdrop/planetary_anomaly/big = 1,
	)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/rockplanet = 6,
		/obj/structure/flora/tree/cactus = 8,
		/obj/structure/flora/ash/cacti = 4,
		/obj/structure/flora/ash/cacti/prickly_pear = 2,
		/obj/structure/flora/ash/san_pedro = 1,
	)
	mob_spawn_chance = 3
	mob_spawn_list = PLANET_ROCK_SURFACE_FAUNA

/// Czapy lodowe
/datum/planet_biome/rock/icecap
	open_turf_types = list(/turf/open/floor/plating/asteroid/snow/rockplanet = 1)
	flora_spawn_chance = 1
	mob_spawn_chance = 2

/// Mokradła
/datum/planet_biome/rock/wetlands
	open_turf_types = list(/turf/open/floor/plating/asteroid/rockplanet/wet = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/rockplanet = 6,
		/obj/structure/flora/tree/cactus = 8,
		/obj/structure/flora/ash/cacti = 3,
		/obj/structure/flora/ash/cacti/prickly_pear = 1,
		/obj/structure/flora/grass/rockplanet/dead = 8,
		/obj/structure/flora/grass/rockplanet = 4,
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/basic/creature = 30,
		/mob/living/basic/wumborian_fugu = 30,
		/mob/living/basic/migo = 20,
		/mob/living/basic/mining/goliath/rockplanet = 10,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 30,
	)

/// Jaskinie w rdzawej skale
/datum/planet_biome/cave/rock
	closed_turf_types = list(/turf/closed/mineral/random/rockplanet = 1)
	open_turf_types = list(/turf/open/floor/plating/asteroid/rockplanet/cracked = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock/rockplanet = 8,
		/obj/structure/flora/rock/pile/rockplanet = 8,
		/obj/structure/flora/ash/fern = 4,
		/obj/structure/flora/ash/puce = 2,
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
		/obj/structure/vein/rockplanet = 3,
		/obj/structure/geyser/random = 2,
		/obj/structure/vein/rockplanet/classtwo = 2,
		/obj/structure/vein/rockplanet/classthree = 1,
		/obj/structure/spawner/burrow/rock_plant = 4,
		/obj/effect/spawner/lootdrop/planetary_anomaly/rock/cave = 1,
	)
	mob_spawn_chance = 6
	mob_spawn_list = list(
		/mob/living/basic/creature = 20,
		/mob/living/basic/wumborian_fugu = 20,
		/mob/living/basic/migo = 20,
		/mob/living/basic/mining/goliath/rockplanet = 30,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 50,
		/mob/living/basic/mining/goldgrub = 20,
	)

/datum/planet_biome/cave/rock/wet
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/rockplanet = 8,
		/obj/structure/flora/rock/pile/rockplanet = 8,
		/obj/structure/flora/ash/fern = 6,
		/obj/structure/flora/ash/puce = 4,
		/obj/structure/flora/ash/cacti = 2,
	)
	mob_spawn_list = list(
		/mob/living/basic/creature = 30,
		/mob/living/basic/wumborian_fugu = 30,
		/mob/living/basic/migo = 20,
		/mob/living/basic/mining/goliath/rockplanet = 10,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 30,
	)

// Białe piaski

/datum/planet_generator/sand
	mountain_height = 0.8
	perlin_zoom = 70
	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/sand/grass/dead,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/sand/icecap,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/sand/icecap,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/sand/riverbed,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/sand/wasteland,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/sand/wasteland,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/sand/icecap,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/sand/riverbed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/sand,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/sand,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/sand/grass/dead,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/sand/grass,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/sand/grass,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/sand/grass,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/sand/sulfur_plains,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/sand/sulfur_plains,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/sand/riverbed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/sand/grass,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/sand/grass,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/sand/sulfur_plains,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/sand/sulfur_plains,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/sand/sulfur_plains,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/sand/sulfur_plains,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/sand,
		),
	)
	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/sand/volcanic/acidic,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/sand/deep,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/sand/deep,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/sand,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/sand,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/sand/volcanic/acidic,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/sand/volcanic,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/sand/deep,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/sand/deep,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/sand,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/sand/volcanic/acidic,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/sand/volcanic,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/sand/deep,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/sand,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/sand,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/sand/volcanic/lava,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/sand/volcanic,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/sand/volcanic,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/sand/deep,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/sand,
		),
	)

/// Solone równiny
/datum/planet_biome/sand
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands = 5, /turf/open/floor/plating/asteroid/whitesands/rocky = 1)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 4,
		/obj/structure/flora/ash/cap_shroom = 4,
		/obj/structure/flora/ash/stem_shroom = 4,
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/geyser/random = 8,
		/obj/structure/vein/sand = 8,
		/obj/structure/vein/sand/classtwo = 4,
		/obj/structure/vein/sand/classtwo/rare = 2,
		/obj/structure/vein/sand/classthree = 2,
		/obj/structure/vein/sand/classthree/rare = 1,
		/obj/effect/spawner/lootdrop/planetary_anomaly/sand = 1,
		/obj/effect/greeble_spawner/whitesands_oasis = 1,
	)
	mob_spawn_chance = 4
	mob_spawn_list = PLANET_SAND_FAUNA

/// Pustkowia z resztkami wojny
/datum/planet_biome/sand/wasteland
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/whitesands = 50,
		/turf/open/floor/plating/asteroid/whitesands/dried = 40,
		/turf/closed/mineral/random/whitesands = 20,
		/turf/closed/wall/mineral/titanium/survival/pod = 1,
		/turf/closed/wall/rust = 1,
	)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 4,
		/obj/structure/flora/ash/cap_shroom = 4,
		/obj/structure/flora/ash/stem_shroom = 4,
		/obj/effect/decal/remains/human = 4,
		/obj/effect/spawner/lootdrop/maintenance = 40,
	)

/// Fioletowe łąki
/datum/planet_biome/sand/grass
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands/grass = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/ash/cacti = 2,
		/obj/structure/flora/ash/fern = 4,
		/obj/structure/flora/tree/whitesands = 4,
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/rock/pile = 3,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(/obj/effect/spawner/lootdrop/planet_hermit = 1)

/// Zwiędłe łąki
/datum/planet_biome/sand/grass/dead
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands/grass/dead = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/fern = 4,
		/obj/structure/flora/tree/dead/barren = 4,
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/rock/pile = 3,
	)

/// Śnieżne czapy
/datum/planet_biome/sand/icecap
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands = 1, /turf/open/floor/plating/asteroid/snow/whitesands = 5)
	flora_spawn_chance = 4
	mob_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/rock = 3,
		/obj/structure/flora/rock/pile = 3,
	)

/// Koryta wyschniętych rzek
/datum/planet_biome/sand/riverbed
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands/dried = 1)
	flora_spawn_chance = 0
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath/whitesands/random = 40,
		/mob/living/basic/mining/basilisk/whitesands = 30,
		/mob/living/basic/mining/legion/random = 20,
		/obj/effect/spawner/lootdrop/planet_hermit = 40,
	)

/// Siarkowe równiny z kałużami siarki (greeble)
/datum/planet_biome/sand/sulfur_plains
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands = 1)
	flora_spawn_chance = 0
	feature_spawn_chance = 1.4
	feature_spawn_list = list(/obj/effect/greeble_spawner/whitesands_sulfurpool = 1)
	mob_spawn_chance = 0

/datum/planet_biome/cave/sand
	closed_turf_types = list(/turf/closed/mineral/random/whitesands = 1)
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/whitesands = 5,
		/turf/open/floor/plating/asteroid/whitesands/dried = 1,
	)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock = 4,
		/obj/structure/flora/rock/pile = 4,
		/obj/structure/flora/ash/fern = 2,
		/obj/structure/flora/ash/puce = 1,
	)
	feature_spawn_list = list(
		/obj/structure/vein/sand = 8,
		/obj/structure/geyser/random = 4,
		/obj/structure/vein/sand/classtwo = 4,
		/obj/effect/spawner/lootdrop/planetary_anomaly/sand/cave = 1,
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath/whitesands/random = 50,
		/mob/living/basic/mining/basilisk/whitesands = 40,
		/mob/living/basic/mining/legion/random = 30,
		/mob/living/basic/mining/goldgrub = 10,
	)

/datum/planet_biome/cave/sand/deep
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands = 5, /turf/open/floor/plating/asteroid/whitesands/rocky = 5)
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath/whitesands/random = 50,
		/mob/living/basic/mining/basilisk/whitesands = 40,
		/mob/living/basic/mining/legion/random = 30,
		/mob/living/basic/mining/goldgrub = 20,
		/obj/structure/spawner/burrow/sand_planet = 25,
	)

/datum/planet_biome/cave/sand/volcanic
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands/dried = 1)
	mob_spawn_chance = 2

/// Lawa w jaskiniach białych piasków: ta sama mieszanka co grunt dookoła (z mieszanką Lavalandu brzeg lawy był w atmosferze
/// aktywny na stałe)
/turf/open/lava/smooth/planet_sand
	initial_gas_mix = PLANET_SAND_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/planet_sand

/datum/planet_biome/cave/sand/volcanic/lava
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands/dried = 7, /turf/open/lava/smooth/planet_sand = 1)

/datum/planet_biome/cave/sand/volcanic/acidic
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands/dried = 1, /turf/open/water/planet/acid = 8)

// Pustynia

/datum/planet_generator/desert
	mountain_height = 0.8
	perlin_zoom = 65
	biome_table = list(
		PLANET_BIOME_COLDEST = list(PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/desert),
		PLANET_BIOME_COLD = list(PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/desert),
		PLANET_BIOME_WARM = list(PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/desert),
		PLANET_BIOME_TEMPERATE = list(PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/desert),
		PLANET_BIOME_HOT = list(PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/desert/dry_seafloor, PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/desert/dry_seafloor, PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/desert, PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/desert),
		PLANET_BIOME_HOTTEST = list(PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/desert/dry_seafloor, PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/desert/dry_seafloor, PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/desert/dry_seafloor, PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/desert/dry_seafloor, PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/desert),
	)
	cave_biome_table = PLANET_SINGLE_CAVE_TABLE(/datum/planet_biome/cave/desert)

/// Wydmy
/datum/planet_biome/desert
	open_turf_types = list(/turf/open/floor/plating/asteroid/desert = 1)
	// Wydmy pokrywają prawie całą planetę, a każda dzika roślina przetwarza się w SSobj: niska szansa, kamienie obok roślin
	flora_spawn_chance = 2
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile/desert = 3,
		/obj/structure/flora/ash/agave = 1,
		/obj/structure/flora/ash/cacti = 2,
		/obj/structure/flora/ash/cacti/prickly_pear = 3,
		/obj/structure/flora/ash/san_pedro = 2,
		/obj/structure/flora/ash/peyote = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = PLANET_DESERT_FAUNA

/// Wyschnięte dno morskie z żyłami
/datum/planet_biome/desert/dry_seafloor
	open_turf_types = list(/turf/open/floor/plating/asteroid/desert/dry_seafloor = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile = 5,
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/agave = 1,
		/obj/structure/flora/ash/peyote = 1,
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(
		/obj/structure/vein/desert = 4,
		/obj/structure/vein/desert/classtwo = 6,
		/obj/structure/vein/desert/classthree = 2,
	)

/datum/planet_biome/cave/desert
	open_turf_types = list(/turf/open/floor/plating/asteroid/desert = 1)
	closed_turf_types = list(/turf/closed/mineral/random/desert = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(/obj/structure/flora/rock/desert = 1, /obj/structure/flora/rock/pile/desert = 6)
	mob_spawn_chance = 1
	mob_spawn_list = PLANET_DESERT_FAUNA
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/structure/vein/desert = 6,
		/obj/structure/vein/desert/classtwo = 4,
		/obj/structure/vein/desert/classthree = 2,
	)

// Planeta mglista: na powierzchni nic nie żyje, fauna wychodzi z żył

/datum/planet_generator/shrouded
	mountain_height = 0.8
	perlin_zoom = 65
	biome_table = PLANET_SINGLE_BIOME_TABLE(/datum/planet_biome/shrouded)
	cave_biome_table = PLANET_SINGLE_CAVE_TABLE(/datum/planet_biome/cave/shrouded)

/datum/planet_biome/shrouded
	open_turf_types = list(/turf/open/floor/plating/asteroid/shrouded = 1)
	flora_spawn_chance = 0
	mob_spawn_chance = 0
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/vein/shrouded = 4,
		/obj/structure/vein/shrouded/classtwo = 6,
		/obj/structure/vein/shrouded/classthree = 2,
	)

/datum/planet_biome/cave/shrouded
	open_turf_types = list(/turf/open/floor/plating/asteroid/shrouded = 1)
	closed_turf_types = list(/turf/closed/mineral/random/shrouded = 1)
	mob_spawn_chance = 0.5
	mob_spawn_list = list(/mob/living/basic/mining/royalcrab = 10)
	feature_spawn_chance = 0.4
	feature_spawn_list = list(
		/obj/structure/vein/shrouded = 6,
		/obj/structure/vein/shrouded/classtwo = 4,
		/obj/structure/vein/shrouded/classthree = 2,
	)

// Planety karłowate: jeden biom dużego odpowiednika bez jaskiń, żyły trzy razy częstsze

/datum/planet_generator/dwarf_dust
	mountain_height = 1
	perlin_zoom = 65
	biome_table = PLANET_SINGLE_BIOME_TABLE(/datum/planet_biome/sand/dwarf)
	cave_biome_table = PLANET_SINGLE_CAVE_TABLE(/datum/planet_biome/cave/sand)

/datum/planet_biome/sand/dwarf
	open_turf_types = list(/turf/open/floor/plating/asteroid/whitesands = 1)
	flora_spawn_chance = 1
	feature_spawn_chance = 0.4
	feature_spawn_list = list(
		/obj/structure/vein/sand = 6,
		/obj/structure/vein/sand/classtwo = 6,
		/obj/structure/vein/sand/classtwo/rare = 3,
		/obj/structure/vein/sand/classthree = 3,
		/obj/structure/vein/sand/classthree/rare = 2,
	)
	mob_spawn_chance = 0.5
	mob_spawn_list = list(
		/mob/living/basic/mining/goliath/whitesands/random = 50,
		/mob/living/basic/mining/basilisk/whitesands = 40,
	)

/datum/planet_generator/dwarf_dune
	mountain_height = 1
	perlin_zoom = 65
	biome_table = PLANET_SINGLE_BIOME_TABLE(/datum/planet_biome/desert/dwarf)
	cave_biome_table = PLANET_SINGLE_CAVE_TABLE(/datum/planet_biome/cave/desert)

/datum/planet_biome/desert/dwarf
	open_turf_types = list(/turf/open/floor/plating/asteroid/desert = 1)
	flora_spawn_chance = 0
	feature_spawn_chance = 0.4
	feature_spawn_list = list(
		/obj/structure/vein/desert = 4,
		/obj/structure/vein/desert/classtwo = 6,
		/obj/structure/vein/desert/classthree = 3,
	)
	mob_spawn_chance = 0.5

#undef PLANET_ROCK_SURFACE_FAUNA
#undef PLANET_SAND_FAUNA
#undef PLANET_DESERT_FAUNA
#undef PLANET_SINGLE_BIOME_TABLE
#undef PLANET_SINGLE_CAVE_TABLE
