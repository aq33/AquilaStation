// AQUILA - księżyc: tabela biomów moon_generator.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3). Próżnia, bez fauny
// na powierzchni (moby tylko z żył), kratery jako greeble (moon_crater1-6), żyły księżycowe w jaskiniach i na powierzchni.

/datum/planet_generator/moon
	mountain_height = 0.8
	perlin_zoom = 65

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/moon,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/moon,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/moon,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/moon,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/moon/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/moon/rocky,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/moon,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/moon/rocky,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/moon/rocky,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/moon/rocky,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/moon/rocky,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/moon,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/moon,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/moon,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/moon,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/moon,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/moon,
		),
	)

/// Powierzchnia księżyca: regolit z kraterami, greeble kraterów i żyły
/datum/planet_biome/moon
	open_turf_types = list(/turf/open/floor/plating/asteroid/moon/craters = 1)
	mob_spawn_chance = 0
	feature_spawn_chance = 1
	feature_spawn_list = list(
		/obj/effect/greeble_spawner/moon = 15,
		/obj/structure/vein/moon = 2,
		/obj/structure/vein/moon/classtwo = 4,
		/obj/structure/vein/moon/classthree = 1,
	)

/// Skaliste równiny: twardy regolit, rzadziej kratery
/datum/planet_biome/moon/rocky
	open_turf_types = list(/turf/open/floor/plating/asteroid/moon_coarse/craters = 1)
	feature_spawn_chance = 0.3
	feature_spawn_list = list(
		/obj/effect/greeble_spawner/moon = 1,
	)

/datum/planet_biome/cave/moon
	open_turf_types = list(/turf/open/floor/plating/asteroid/moon = 1)
	closed_turf_types = list(/turf/closed/mineral/random/moon = 1)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/ash/glowbell = 3,
		/obj/structure/flora/ash/glowbell/cavern_candle = 2,
		/obj/structure/flora/ash/glowbell/weeping_moon = 1,
	)
	mob_spawn_chance = 0
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/vein/moon = 6,
		/obj/structure/vein/moon/classtwo = 4,
		/obj/structure/vein/moon/classthree = 1,
	)

/// Kratery księżyca (greeble Shiptesta moon_crater1-6, przekonwertowane tools/planets/convert_maps.py)
/obj/effect/greeble_spawner/moon
	name = "spawner krateru księżycowego"
	greeble_maps = list(
		'aquila/_maps/greebles/moon/moon_crater1.dmm' = 5,
		'aquila/_maps/greebles/moon/moon_crater2.dmm' = 5,
		'aquila/_maps/greebles/moon/moon_crater3.dmm' = 5,
		'aquila/_maps/greebles/moon/moon_crater4.dmm' = 5,
		'aquila/_maps/greebles/moon/moon_crater5.dmm' = 5,
		'aquila/_maps/greebles/moon/moon_crater6.dmm' = 5,
	)
