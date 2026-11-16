// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety: powierzchnia planety-śmietniska i pola bitwy powstaje z krawędzią, bezpiecznymi lądowiskami,
/// śmieciami albo roślinami, fauną albo żyłami i znika bez runtime'ów
/datum/unit_test/planet_waste_surfaces

/datum/unit_test/planet_waste_surfaces/Run()
#ifndef AQUILA_FULL_MAP_TESTS
	// Ciężki test planet (generowanie powierzchni typów, wczytywanie ruin i greebli): w zwykłym CI pomijany, bo cała
	// część testów z planetami nie mieściła się w limicie czasu. Pełny przebieg: -DAQUILA_FULL_MAP_TESTS.
	return
#endif
	for(var/planet_type in planet_test_sample(list(/datum/planet_type/waste, /datum/planet_type/battlefield)))
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		var/datum/planet_surface/surface = planet.surface
		TEST_ASSERT(surface.generate(), "[planet_type]: the surface didn't generate")
		var/turf/bl = surface.bottom_left()
		TEST_ASSERT(istype(bl, /turf/closed/indestructible/rock/planet_edge), "[planet_type]: the surface corner isn't the planet edge ([bl.type])")
		TEST_ASSERT_EQUAL(length(surface.landing_zones), PLANET_LANDING_ZONES, "[planet_type]: wrong number of landing zones")
		for(var/turf/zone as anything in surface.landing_zones)
			for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
				TEST_ASSERT(!is_planet_hazard_turf(T), "[planet_type]: landing zone [surface.landing_zones[zone]] has unsafe ground at [T.x],[T.y] ([T.type])")
		var/walls = 0
		var/things = 0
		var/living = 0
		var/space = 0
		for(var/turf/T as anything in surface.inner_turfs())
			if(isspaceturf(T))
				space++
			else if(isclosedturf(T))
				walls++
			for(var/atom/movable/AM as anything in T)
				if(isobj(AM))
					things++
				else if(isliving(AM))
					living++
		TEST_ASSERT_EQUAL(space, 0, "[planet_type]: space turfs left on the surface")
		TEST_ASSERT(walls > 0, "[planet_type]: no rock or caves on the surface")
		TEST_ASSERT(things > 50, "[planet_type]: almost nothing on the surface ([things] objects)")
		if(planet_type == /datum/planet_type/waste)
			TEST_ASSERT(living > 0, "[planet_type]: no hivebots or automatons on the surface")
		surface.unload()
		TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "[planet_type]: the surface didn't unload")
		qdel(planet, TRUE)

/// AQUILA - planety: każda ruina śmietniska i pola bitwy mieści się jako ruina główna i się wczytuje
/datum/unit_test/planet_waste_ruins

/datum/unit_test/planet_waste_ruins/Run()
#ifndef AQUILA_FULL_MAP_TESTS
	// Ciężki test planet (generowanie powierzchni typów, wczytywanie ruin i greebli): w zwykłym CI pomijany, bo cała
	// część testów z planetami nie mieściła się w limicie czasu. Pełny przebieg: -DAQUILA_FULL_MAP_TESTS.
	return
#endif
	var/list/waste = get_planet_waste_ruin_templates()
	var/list/battlefield = get_planet_battlefield_ruin_templates()
	TEST_ASSERT_EQUAL(length(waste), 6, "Wrong number of waste planet ruins")
	TEST_ASSERT_EQUAL(length(battlefield), 3, "Wrong number of battlefield ruins")
	// Każda ruina wczytuje się we własnej pustej rezerwacji (jedna na drugiej dublowały kable i rury)
	var/obj/structure/overmap/planet/fit_planet = new(run_loc_floor_top_right, /datum/planet_type/waste)
	for(var/name in planet_test_sample(waste + battlefield, 2))
		var/datum/map_template/ruin/ruin = waste[name] || battlefield[name]
		TEST_ASSERT(ruin.width && ruin.height, "[name] map file didn't preload ([ruin.mappath])")
		TEST_ASSERT(fit_planet.surface.main_ruin_fits(ruin, PLANET_SURFACE_SIZE_LARGE), "[name] ([ruin.width]x[ruin.height]) doesn't fit even the large surface")
		TEST_ASSERT(planet_test_load_ruin(ruin), "[name] didn't load")
	qdel(fit_planet, TRUE)

/// AQUILA - planety: zawartość biomów śmietniska i pola bitwy (turfy, śmieci, beczki, automaty) powstaje bez runtime'ów
/datum/unit_test/planet_waste_content

/datum/unit_test/planet_waste_content/Run()
	var/list/atom_types = list()
	var/list/turf_types = list()
	for(var/biome_type in typesof(/datum/planet_biome/waste) + typesof(/datum/planet_biome/cave/waste) + typesof(/datum/planet_biome/battlefield) + typesof(/datum/planet_biome/cave/battlefield))
		var/datum/planet_biome/biome = get_planet_biome(biome_type)
		turf_types |= biome.open_turf_types
		if(istype(biome, /datum/planet_biome/cave))
			var/datum/planet_biome/cave/cave = biome
			turf_types |= cave.closed_turf_types
		for(var/list/spawn_list in list(biome.flora_spawn_list, biome.feature_spawn_list, biome.mob_spawn_list))
			atom_types |= spawn_list
	var/turf/T = run_loc_floor_bottom_left
	for(var/obj/effect/decal/cleanable/stain in T)
		qdel(stain)
	var/turf_type_before = T.type
	for(var/turf_type in turf_types)
		T = T.ChangeTurf(turf_type)
		TEST_ASSERT(istype(T, turf_type), "Couldn't place [turf_type]")
	T = T.ChangeTurf(turf_type_before)
	for(var/atom_type in atom_types)
		var/atom/movable/thing = new atom_type(run_loc_floor_top_right)
		if(ispath(atom_type, /obj/effect/spawner))
			continue
		TEST_ASSERT(!QDELETED(thing), "[atom_type] deleted itself right after spawning")
		qdel(thing)
	// Sprzątanie po spawnerach (anomalie, miny ze śmieci: uzbrojona mina zostałaby na polu do końca części CI)
	for(var/obj/effect/anomaly/anomaly in run_loc_floor_top_right)
		qdel(anomaly)
	for(var/obj/effect/mine/mine in run_loc_floor_top_right)
		qdel(mine)

/// AQUILA - planety: automaty wysypiska mają AI, strzelające mają atak dystansowy, mina krocząca uzbraja się przy celu,
/// rdzeń roju i beczki z odpadami powstają bez runtime'ów
/datum/unit_test/planet_waste_automatons

/datum/unit_test/planet_waste_automatons/Run()
	for(var/automaton_type in subtypesof(/mob/living/basic/automaton) + /mob/living/basic/hivebot/strong/core)
		var/mob/living/basic/automaton = allocate(automaton_type, run_loc_floor_top_right)
		TEST_ASSERT(automaton.ai_controller, "[automaton_type] has no AI controller")
		if(istype(automaton, /mob/living/basic/automaton))
			var/mob/living/basic/automaton/bot = automaton
			if(bot.projectile_type || bot.casing_type)
				TEST_ASSERT(bot.GetComponent(/datum/component/ranged_attacks), "[automaton_type] shoots but has no ranged attack")
		qdel(automaton)

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/basic/automaton/walkmine/mine = allocate(/mob/living/basic/automaton/walkmine, get_step(run_loc_floor_bottom_left, EAST))
	mine.melee_attack(victim)
	TEST_ASSERT(mine.armed, "The walkmine didn't arm next to its target")
	TEST_ASSERT(HAS_TRAIT(mine, TRAIT_IMMOBILIZED), "An armed walkmine can still walk")
	qdel(mine) // Zanim wybuchnie: wybuch w pokoju testowym psułby następne testy

	for(var/barrel_type in typesof(/obj/structure/radioactive_barrel))
		var/obj/structure/radioactive_barrel/barrel = allocate(barrel_type, run_loc_floor_top_right)
		barrel.pulse()
		qdel(barrel)

/// AQUILA - planety: smoła spowalnia, a skażona woda pola bitwy truje każdego, kto w niej stoi
/datum/unit_test/planet_waste_water

/datum/unit_test/planet_waste_water/Run()
	var/turf/T = run_loc_floor_bottom_left
	for(var/obj/effect/decal/cleanable/stain in T)
		qdel(stain)
	var/turf_type_before = T.type
	var/turf/open/tar = T.ChangeTurf(/turf/open/water/planet/tar)
	TEST_ASSERT(tar.slowdown >= 2, "Tar doesn't slow people down")
	T = tar
	T = T.ChangeTurf(/turf/open/water/planet/battlefield)
	var/mob/living/carbon/human/swimmer = allocate(/mob/living/carbon/human, get_step(T, EAST))
	swimmer.forceMove(T)
	TEST_ASSERT(swimmer.reagents.has_reagent(/datum/reagent/toxin), "The battlefield water doesn't poison people standing in it")
	swimmer.forceMove(get_step(T, EAST))
	T.ChangeTurf(turf_type_before)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
