// AQUILA - planeta-śmietnisko: tabela biomów WasteGenerator.dm z Shiptesta (AGPLv3). Turfy, śmieci i promieniowanie
// w shiptest_flora/waste.dm, automaty w shiptest_fauna/automatons.dm, żyły w drill/veins_waste.dm.
// Zmiany względem Shiptesta: śmieci, beczki, dźwigary i złom przez nasze spawnery /obj/effect/spawner/lootdrop/waste/*,
// miny naciskowe -> nasze miny, ogródki -> kolonie świecących grzybów (botanika), skromne żyły rud (Shiptest ich nie ma),
// greebli brak (Shiptest też ich tu nie ma).

/// Wspólne śmieci powierzchni (wagi z Shiptesta, podzielone przez 10)
#define PLANET_WASTE_JUNK \
	/obj/effect/spawner/lootdrop/waste/mechwreck = 10,\
	/obj/effect/spawner/lootdrop/waste/mechwreck/rare = 2,\
	/obj/effect/spawner/lootdrop/waste/trash_decal = 180,\
	/obj/effect/spawner/lootdrop/waste/radiation = 8,\
	/obj/effect/spawner/lootdrop/waste/radiation/more_rads = 1,\
	/obj/effect/spawner/lootdrop/waste/girder = 60,\
	/obj/structure/reagent_dispensers/watertank = 20,\
	/obj/item/stack/cable_coil/cut = 50,\
	/obj/structure/closet/crate/secure/loot = 3,\
	/obj/effect/spawner/lootdrop/waste/atmos_can = 5,\
	/obj/effect/spawner/lootdrop/waste/salvageable = 30,\
	/obj/effect/spawner/lootdrop/waste/grille_or_trash = 20,\
	/obj/effect/spawner/lootdrop/maintenance = 20,\
	/obj/effect/spawner/lootdrop/maintenance/two = 10,\
	/obj/effect/spawner/lootdrop/maintenance/three = 5,\
	/obj/effect/spawner/lootdrop/maintenance/four = 2,\
	/obj/effect/spawner/lootdrop/waste/mine = 4

/// Fauna powierzchni: hivebota i automaty wysypiska (wagi z Shiptesta)
#define PLANET_WASTE_FAUNA list(\
	/mob/living/basic/hivebot/strong = 20,\
	/mob/living/basic/hivebot/range = 40,\
	/mob/living/basic/hivebot/rapid = 30,\
	/mob/living/basic/automaton/agrav/cybersun/waste = 3,\
	/mob/living/basic/automaton/quadrotor/cybersun/waste = 15,\
	/mob/living/basic/automaton/quadrotor/makosso/waste = 15,\
	/mob/living/basic/automaton/walkmine/waste = 15,\
)

/// Obiekty: promieniowanie tła, gejzery, anomalie, żyły
#define PLANET_WASTE_FEATURES(anomaly) list(\
	/obj/effect/radiation/waste = 30,\
	/obj/effect/radiation/waste/intense = 10,\
	/obj/structure/geyser/random = 1,\
	anomaly = 1,\
	/obj/structure/vein/waste = 4,\
	/obj/structure/vein/waste/classtwo = 2,\
	/obj/structure/vein/waste/classthree = 1,\
)

/datum/planet_generator/waste
	mountain_height = 0.5
	perlin_zoom = 40

	biome_table = list(
		PLANET_BIOME_COLDEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/waste/crater,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/waste/crater,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/waste/clearing,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/waste/clearing/mushroom,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/waste/metal/rust,
		),
		PLANET_BIOME_COLD = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/waste/crater,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/waste/crater/rad,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/waste,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/waste/clearing/mushroom,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/waste/tar_bed,
		),
		PLANET_BIOME_WARM = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/waste/clearing,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/waste/clearing,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/waste/clearing/mushroom,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/waste,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/waste,
		),
		PLANET_BIOME_TEMPERATE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/waste,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/waste/tar_bed,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/waste/metal,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/waste,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/waste/metal/rust,
		),
		PLANET_BIOME_HOT = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/waste,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/waste/tar_bed,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/waste/tar_bed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/waste/tar_bed/total,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/waste/tar_bed/total,
		),
		PLANET_BIOME_HOTTEST = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/waste/metal,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/waste/metal,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/waste/metal,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/waste/metal/rust,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/waste/metal/rust,
		),
	)

	cave_biome_table = list(
		PLANET_BIOME_COLDEST_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/waste/tar_bed,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/waste/tar_bed/full,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/waste/tar_bed/full,
		),
		PLANET_BIOME_COLD_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/waste/rad,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/waste/conc,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/waste/conc,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/waste/conc,
		),
		PLANET_BIOME_WARM_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/waste/metal,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/waste/metal,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/waste/tar_bed,
		),
		PLANET_BIOME_HOT_CAVE = list(
			PLANET_BIOME_LOWEST_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_LOW_HUMIDITY = /datum/planet_biome/cave/waste,
			PLANET_BIOME_MEDIUM_HUMIDITY = /datum/planet_biome/cave/waste/metal,
			PLANET_BIOME_HIGH_HUMIDITY = /datum/planet_biome/cave/waste/metal,
			PLANET_BIOME_HIGHEST_HUMIDITY = /datum/planet_biome/cave/waste/metal,
		),
	)

/// Wysypisko: suchy kamień ze śmieciami, kolonie świecących grzybów
/datum/planet_biome/waste
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 80,
		/turf/open/floor/plating/wasteplanet/rust = 15,
		/turf/open/floor/plating/wasteplanet = 5,
	)
	flora_spawn_list = list(
		PLANET_WASTE_JUNK,
		/obj/structure/flora/ash/glowshroom = 27,
		/obj/structure/flora/ash/broc = 6,
		/obj/structure/flora/ash/xander = 6,
		/obj/structure/flora/ash/tato = 5,
		/obj/structure/flora/ash/mutfruit = 4,
		/obj/structure/flora/ash/yucca = 4,
		/obj/structure/flora/ash/datura = 3,
		/obj/structure/flora/ash/punga = 3,
		/obj/structure/flora/ash/agave = 2,
		/obj/structure/flora/ash/radberry = 2,
	)
	feature_spawn_list = PLANET_WASTE_FEATURES(/obj/effect/spawner/lootdrop/planetary_anomaly/waste)
	mob_spawn_list = PLANET_WASTE_FAUNA
	flora_spawn_chance = 25
	feature_spawn_chance = 0.75
	mob_spawn_chance = 1.5

/// Kratery: mało śmieci, sporo beczek i kanistrów
/datum/planet_biome/waste/crater
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 90,
		/turf/open/floor/plating/wasteplanet/rust = 10,
	)
	flora_spawn_list = list(
		/obj/effect/spawner/lootdrop/waste/trash_decal = 180,
		/obj/effect/spawner/lootdrop/waste/radiation = 16,
		/obj/effect/spawner/lootdrop/waste/radiation/more_rads = 2,
		/obj/effect/spawner/lootdrop/waste/atmos_can = 36,
		/obj/effect/spawner/lootdrop/waste/salvageable = 60,
		/obj/structure/flora/ash/yucca = 8,
		/obj/structure/flora/ash/agave = 8,
		/obj/structure/flora/ash/xander = 4,
	)
	mob_spawn_chance = 1

/// Napromieniowane kratery z grzybami
/datum/planet_biome/waste/crater/rad
	flora_spawn_list = list(
		/obj/structure/flora/ash/glowshroom = 180,
		/obj/effect/spawner/lootdrop/waste/trash_decal = 90,
		/obj/effect/spawner/lootdrop/waste/radiation = 25,
		/obj/effect/spawner/lootdrop/waste/radiation/more_rads = 7,
		/obj/effect/spawner/lootdrop/waste/atmos_can = 7,
		/obj/effect/spawner/lootdrop/waste/salvageable = 15,
		/obj/structure/flora/ash/geigerpunga = 15,
		/obj/structure/flora/ash/radberry = 15,
	)

/datum/planet_biome/waste/clearing
	flora_spawn_chance = 20
	feature_spawn_chance = 2

/datum/planet_biome/waste/clearing/mushroom
	flora_spawn_list = list(
		PLANET_WASTE_JUNK,
		/obj/structure/flora/ash/glowshroom = 210,
		/obj/structure/flora/ash/punga = 20,
		/obj/structure/flora/ash/geigerpunga = 5,
	)

/// Złoża smoły
/datum/planet_biome/waste/tar_bed
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 70,
		/turf/open/floor/plating/wasteplanet/rust = 10,
		/turf/open/water/planet/tar = 3,
	)

/datum/planet_biome/waste/tar_bed/total
	open_turf_types = list(/turf/open/water/planet/tar = 1)
	flora_spawn_chance = 0

/// Metalowe pustkowia bez roślin, więcej hivebotów i fabrykatorów
/datum/planet_biome/waste/metal
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 5,
		/turf/open/floor/plating/wasteplanet/rust = 45,
		/turf/open/floor/plating/wasteplanet = 50,
	)
	flora_spawn_list = list(
		PLANET_WASTE_JUNK,
		/obj/effect/spawner/lootdrop/waste/mechwreck = 20,
		/obj/effect/spawner/lootdrop/waste/atmos_can = 18,
	)
	mob_spawn_list = list(
		/mob/living/basic/hivebot = 40,
		/mob/living/basic/hivebot/strong = 10,
		/mob/living/basic/hivebot/range = 20,
		/mob/living/basic/hivebot/rapid = 20,
		/mob/living/basic/automaton/agrav/cybersun/waste = 3,
		/mob/living/basic/automaton/quadrotor/cybersun/waste = 15,
		/mob/living/basic/automaton/quadrotor/makosso/waste = 15,
		/mob/living/basic/automaton/walkmine/waste = 15,
		/obj/structure/spawner/hivebot = 15,
	)
	mob_spawn_chance = 2

/datum/planet_biome/waste/metal/rust
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 1,
		/turf/open/floor/plating/wasteplanet/rust = 10,
		/turf/open/floor/plating/wasteplanet = 4,
	)

// Jaskinie i ruiny pod skałą

/datum/planet_biome/cave/waste
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 80,
		/turf/open/floor/plating/wasteplanet/rust = 15,
		/turf/open/floor/plating/wasteplanet = 5,
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/wasteplanet = 60,
		/turf/closed/wall/r_wall/wasteplanet = 1,
		/turf/closed/wall/r_wall/rust/wasteplanet = 2,
		/turf/closed/wall/wasteplanet = 1,
		/turf/closed/wall/rust/wasteplanet = 2,
	)
	flora_spawn_list = list(
		PLANET_WASTE_JUNK,
		/obj/structure/flora/ash/glowshroom = 40,
	)
	feature_spawn_list = PLANET_WASTE_FEATURES(/obj/effect/spawner/lootdrop/planetary_anomaly/waste/cave)
	mob_spawn_list = list(
		/mob/living/basic/hivebot = 50,
		/mob/living/basic/hivebot/strong = 20,
		/mob/living/basic/hivebot/range = 40,
		/mob/living/basic/hivebot/rapid = 30,
		/mob/living/basic/automaton/agrav/cybersun/waste = 3,
		/mob/living/basic/automaton/quadrotor/cybersun/waste = 15,
		/mob/living/basic/automaton/quadrotor/makosso/waste = 15,
		/mob/living/basic/automaton/walkmine/waste = 15,
	)
	flora_spawn_chance = 30
	feature_spawn_chance = 4
	mob_spawn_chance = 2

/datum/planet_biome/cave/waste/tar_bed
	open_turf_types = list(
		/turf/open/floor/plating/asteroid/wasteplanet = 70,
		/turf/open/floor/plating/wasteplanet/rust = 20,
		/turf/open/water/planet/tar = 3,
	)

/datum/planet_biome/cave/waste/tar_bed/full
	open_turf_types = list(/turf/open/water/planet/tar = 1)
	flora_spawn_chance = 0

/// Napromieniowane jaskinie
/datum/planet_biome/cave/waste/rad
	flora_spawn_list = list(
		/obj/effect/spawner/lootdrop/waste/trash_decal = 90,
		/obj/effect/spawner/lootdrop/waste/radiation = 25,
		/obj/effect/spawner/lootdrop/waste/radiation/more_rads = 7,
		/obj/effect/spawner/lootdrop/waste/atmos_can = 5,
		/obj/effect/spawner/lootdrop/waste/salvageable = 15,
		/obj/effect/spawner/lootdrop/waste/girder = 20,
		/obj/item/stack/cable_coil/cut = 50,
		/obj/effect/spawner/lootdrop/waste/grille_or_trash = 20,
		/obj/effect/spawner/lootdrop/maintenance/four = 20,
		/obj/structure/flora/ash/glowshroom = 180,
		/obj/effect/spawner/lootdrop/waste/mine = 4,
	)
	feature_spawn_chance = 12

/// Głębsze, zabudowane korytarze: same wraki, więcej ścian budynków
/datum/planet_biome/cave/waste/metal
	open_turf_types = list(
		/turf/open/floor/plating/wasteplanet/rust = 10,
		/turf/open/floor/plating/wasteplanet = 4,
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/wasteplanet = 45,
		/turf/closed/wall/r_wall/wasteplanet = 1,
		/turf/closed/wall/r_wall/rust/wasteplanet = 1,
		/turf/closed/wall/wasteplanet = 5,
		/turf/closed/wall/rust/wasteplanet = 10,
	)
	flora_spawn_list = list(PLANET_WASTE_JUNK)
	mob_spawn_list = list(
		/mob/living/basic/hivebot/strong = 20,
		/mob/living/basic/hivebot/range = 50,
		/mob/living/basic/hivebot/rapid = 50,
		/mob/living/basic/automaton/agrav/cybersun/waste = 3,
		/mob/living/basic/automaton/quadrotor/cybersun/waste = 15,
		/mob/living/basic/automaton/quadrotor/makosso/waste = 15,
		/mob/living/basic/automaton/walkmine/waste = 15,
		/obj/structure/spawner/hivebot = 15,
	)

/// Betonowa dżungla: zawalone budynki
/datum/planet_biome/cave/waste/conc
	open_turf_types = list(
		/turf/open/floor/concrete/wasteplanet = 10,
		/turf/open/floor/concrete/slab_4/wasteplanet = 4,
		/turf/open/floor/concrete/pavement/wasteplanet = 4,
	)
	closed_turf_types = list(
		/turf/closed/mineral/random/wasteplanet = 50,
		/turf/closed/wall/wasteplanet = 15,
		/turf/closed/wall/r_wall/wasteplanet = 3,
	)
	flora_spawn_list = list(
		/obj/effect/spawner/lootdrop/waste/mechwreck = 20,
		/obj/effect/spawner/lootdrop/waste/trash_decal = 90,
		/obj/effect/spawner/lootdrop/waste/radiation = 16,
		/obj/structure/reagent_dispensers/watertank = 20,
		/obj/item/stack/cable_coil/cut = 50,
		/obj/structure/closet/crate/secure/loot = 3,
		/obj/effect/spawner/lootdrop/waste/atmos_can = 5,
		/obj/effect/spawner/lootdrop/waste/salvageable = 70,
		/obj/effect/spawner/lootdrop/maintenance = 2,
		/obj/effect/spawner/lootdrop/maintenance/two = 5,
		/obj/effect/spawner/lootdrop/maintenance/three = 10,
	)
	mob_spawn_list = list(
		/mob/living/basic/hivebot = 80,
		/mob/living/basic/hivebot/strong = 80,
		/mob/living/basic/hivebot/range = 50,
		/mob/living/basic/hivebot/rapid = 50,
		/mob/living/basic/automaton/agrav/cybersun/waste = 3,
		/mob/living/basic/automaton/quadrotor/cybersun/waste = 15,
		/mob/living/basic/automaton/quadrotor/makosso/waste = 15,
		/mob/living/basic/automaton/walkmine/waste = 15,
		/obj/structure/spawner/hivebot = 15,
	)
	feature_spawn_chance = 8

#undef PLANET_WASTE_JUNK
#undef PLANET_WASTE_FAUNA
#undef PLANET_WASTE_FEATURES
