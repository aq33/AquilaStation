// AQUILA - planeta oceaniczna (plaża): tabela biomów BeachGenerator.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3).
// Turfy i rośliny w shiptest_flora/beach.dm, woda w water/, fauna z naszych mobów.
// Różnice względem Shiptesta:
// - ogródki (ash/garden, garden/seaweed) zastąpione roślinami, które już mamy (krzewy, trzciny na płyciźnie);
// - gęste pnącza (spacevine/dense) w dżungli przy plaży zastąpione krzewami dżungli (statycznych pnączy u nas nie ma);
// - Shiptest nie daje plaży żył ani anomalii; tu w jaskiniach jest trochę żył klasy 1-2 i rzadkie anomalie plażowe
//   (spawner planetary_anomaly/beach, który w Shiptest jest zdefiniowany, ale nieużywany), żeby misje i skanery miały
//   tu co robić.

/datum/planet_generator/beach
	mountain_height = 0.95
	perlin_zoom = 75

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/deep,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/beach_grass,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/deep,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/beach_grass/dense,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/beach_jungle,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/deep,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/beach_grass/dense,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/beach_grass,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/deep,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/beach/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/beach_grass,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/deep,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/beach/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/beach_grass,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/ocean/deep,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/ocean,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/beach/dense,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/beach,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/beach_grass,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/beach/cove,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/beach/magical,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/beach,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/beach/magical,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/beach/cove,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/beach/magical,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/beach,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/beach,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/beach/cove,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/beach,
		),
	)

/// Łąki nad morzem (Shiptest: /datum/biome/grass)
/datum/planet_biome/beach_grass
	open_turf_types = list(/turf/open/floor/plating/asteroid/dirt/grass/beach = 1)
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/tree/jungle = 1,
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 2,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/tree/palm = 1,
	)
	feature_spawn_chance = 0.8
	feature_spawn_list = list(/obj/effect/greeble_spawner/grass_patch/dark_beach = 1)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/butterfly = 1,
		/mob/living/basic/rabbit = 1,
		/mob/living/basic/mouse = 1,
		/mob/living/basic/cow = 1,
		/mob/living/basic/deer = 1,
	)

/datum/planet_biome/beach_grass/dense
	flora_spawn_chance = 70
	feature_spawn_chance = 1.2
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/basic/butterfly = 4,
		/mob/living/basic/snake = 5,
		/mob/living/simple_animal/hostile/poison/bees = 3,
	)

/// Plaża (Shiptest: /datum/biome/beach)
/datum/planet_biome/beach
	open_turf_types = list(/turf/open/floor/plating/asteroid/sand = 1)
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 1,
		/obj/structure/flora/rock/beach = 3,
		/obj/structure/flora/driftwood = 3,
		/obj/structure/flora/driftlog = 1,
		/obj/item/toy/seashell = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/crab = 7,
		/mob/living/basic/mining/lobstrosity/beach = 5,
	)

/datum/planet_biome/beach/dense
	open_turf_types = list(/turf/open/floor/plating/asteroid/sand/dense = 1)
	flora_spawn_chance = 2
	flora_spawn_list = list(
		/obj/structure/flora/rock/asteroid = 6,
		/obj/structure/flora/rock/beach = 2,
		/obj/structure/flora/driftwood = 6,
		/obj/item/toy/seashell = 1,
		/obj/structure/flora/driftlog = 2,
	)

/// Płycizna (Shiptest: /datum/biome/ocean). Wodorosty z ogródka zastąpione trzcinami.
/datum/planet_biome/ocean
	open_turf_types = list(/turf/open/water/planet/beach = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/rock/beach = 1,
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
	)
	mob_spawn_chance = 0

/// Głębia: trzeba płynąć
/datum/planet_biome/ocean/deep
	open_turf_types = list(/turf/open/water/planet/beach/deep = 1)
	flora_spawn_chance = 0

/// Dżungla przy plaży (Shiptest: /datum/biome/beach_jungle)
/datum/planet_biome/beach_jungle
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/dirt/grass/beach = 1,
		/turf/open/floor/plating/asteroid/dirt/beach = 9,
	)
	flora_spawn_chance = 100
	flora_spawn_list = list(
		/obj/structure/flora/grass/jungle = 1,
		/obj/structure/flora/grass/jungle/b = 1,
		/obj/structure/flora/tree/jungle = 5,
		/obj/structure/flora/rock/jungle = 1,
		/obj/structure/flora/junglebush = 6,
		/obj/structure/flora/junglebush/b = 6,
		/obj/structure/flora/junglebush/c = 6,
		/obj/structure/flora/junglebush/large = 4,
	)
	mob_spawn_chance = 0.6
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/gorilla = 1,
		/mob/living/carbon/monkey = 6,
		/mob/living/basic/chicken = 4,
		/obj/effect/spawner/lootdrop/jungle_chicken_flock = 1,
	)

/// Jaskinie plaży (Shiptest: /datum/biome/cave/beach)
/datum/planet_biome/cave/beach
	open_turf_types = list(/turf/open/floor/plating/asteroid/sand/dense = 1)
	closed_turf_types = list(/turf/closed/mineral/random/beach = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(
		/obj/structure/flora/rock/beach = 1,
		/obj/structure/flora/rock/asteroid = 6,
	)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/structure/vein/beach = 6,
		/obj/structure/vein/beach/classtwo = 3,
		/obj/effect/spawner/lootdrop/planetary_anomaly/beach/cave = 1,
	)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/bear/cave = 5,
		/mob/living/basic/mining/lobstrosity/beach = 1,
	)

/// Zatoczka z martwymi sosnami
/datum/planet_biome/cave/beach/cove
	flora_spawn_chance = 6
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead_pine = 1,
		/obj/structure/flora/rock/beach = 1,
		/obj/structure/flora/driftwood = 3,
		/obj/structure/flora/driftlog = 2,
	)

/// Magiczna grota ze świecącą trawą
/datum/planet_biome/cave/beach/magical
	open_turf_types = list(/turf/open/floor/grass/fairy/planet = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/grassybush = 2,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 2,
		/obj/structure/flora/ausbushes/sunnybush = 1,
	)
	feature_spawn_chance = 0.5
	feature_spawn_list = list(/obj/effect/spawner/lootdrop/planetary_anomaly/beach = 1)
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/basic/butterfly = 1,
		/mob/living/simple_animal/slime/pet = 1,
		/mob/living/basic/lightgeist = 1,
	)
