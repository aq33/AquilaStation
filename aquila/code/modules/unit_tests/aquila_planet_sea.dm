// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety morskie: powierzchnia plaży, planety wodnej i wodnej planety karłowatej powstaje z krawędzią,
/// bezpiecznymi lądowiskami, wodą z łowiskiem i zawartością biomów, a potem znika bez runtime'ów
/datum/unit_test/planet_sea_surfaces

/datum/unit_test/planet_sea_surfaces/Run()
	for(var/planet_type in planet_test_sample(list(/datum/planet_type/beach, /datum/planet_type/water, /datum/planet_type/dwarf/water)))
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		var/datum/planet_surface/surface = planet.surface
		TEST_ASSERT(surface.generate(), "[planet_type] surface didn't generate")
		// Rozmiar typu albo duży, gdy wypadła ruina główna za duża na zwykły kwadrat (np. Kurort Korporacyjny)
		TEST_ASSERT(surface.size == planet.planet_type.surface_size || surface.size == PLANET_SURFACE_SIZE_LARGE, "[planet_type] surface has the wrong size ([surface.size])")
		var/turf/bl = surface.bottom_left()
		TEST_ASSERT(istype(bl, /turf/closed/indestructible/rock/planet_edge), "[planet_type] surface corner isn't the planet edge ([bl.type])")
		var/water = 0
		var/fishing = 0
		var/ground = 0
		var/content = 0
		for(var/turf/T as anything in surface.inner_turfs())
			if(isspaceturf(T))
				TEST_ASSERT(FALSE, "[planet_type] has space at [T.x],[T.y]")
			if(istype(T, /turf/open/water/planet))
				water++
				var/turf/open/water/planet/sea = T
				if(sea.fishing_preset && GLOB.preset_fish_sources[sea.fishing_preset])
					fishing++
			else if(!is_planet_hazard_turf(T))
				ground++
			for(var/atom/movable/AM as anything in T)
				if(isliving(AM) || istype(AM, /obj/structure/flora) || istype(AM, /obj/structure/vein) || istype(AM, /obj/item/toy/seashell))
					content++
		TEST_ASSERT(water > 0, "[planet_type] has no water")
		TEST_ASSERT_EQUAL(fishing, water, "[planet_type] has water without a fishing spot")
		TEST_ASSERT(ground > 0, "[planet_type] has no walkable ground")
		TEST_ASSERT(content > 0, "[planet_type] has no flora, fauna or veins")
		TEST_ASSERT_EQUAL(length(surface.landing_zones), PLANET_LANDING_ZONES, "[planet_type] has the wrong number of landing zones")
		for(var/turf/zone as anything in surface.landing_zones)
			for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
				TEST_ASSERT(!is_planet_hazard_turf(T), "[planet_type] landing zone [surface.landing_zones[zone]] has unsafe ground at [T.x],[T.y] ([T.type])")
		var/datum/planet_type/prototype = planet.planet_type
		for(var/vein_class in prototype.mission_veins)
			TEST_ASSERT(ispath(prototype.get_mission_vein(vein_class), prototype.vein_root), "[planet_type] class [vein_class] vein isn't under its vein_root")
		surface.unload()
		TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "[planet_type] surface didn't unload")
		qdel(planet, TRUE)

/// AQUILA - planety morskie: każda ruina plaży i jej kopia na planecie wodnej mieści się jako ruina główna (najwyżej na
/// powiększonej powierzchni) i się wczytuje w całości na powierzchni planety
/datum/unit_test/planet_sea_ruins

/datum/unit_test/planet_sea_ruins/Run()
	var/list/sets = list(
		/datum/planet_type/beach = get_planet_sea_ruin_templates(/datum/map_template/ruin/planet_beach),
		/datum/planet_type/water = get_planet_sea_ruin_templates(/datum/map_template/ruin/planet_water),
	)
	TEST_ASSERT_EQUAL(length(sets[/datum/planet_type/beach]), 5, "Wrong number of beach ruins registered")
	TEST_ASSERT_EQUAL(length(sets[/datum/planet_type/water]), 3, "Wrong number of water planet ruins registered")
	// Każda ruina mieści się jako ruina główna na dużej powierzchni i wczytuje się we własnej pustej rezerwacji
	// (ruiny wczytywane jedna na drugą dublowały kable i rury)
	var/obj/structure/overmap/planet/fit_planet = new(run_loc_floor_top_right, /datum/planet_type/beach)
	for(var/planet_type in sets)
		var/list/templates = sets[planet_type]
		for(var/name in planet_test_sample(templates, 1))
			var/datum/map_template/ruin/ruin = templates[name]
			TEST_ASSERT(ruin.width && ruin.height, "[name] map file didn't preload ([ruin.mappath])")
			TEST_ASSERT(fit_planet.surface.main_ruin_fits(ruin, PLANET_SURFACE_SIZE_LARGE), "[name] ([ruin.width]x[ruin.height]) doesn't fit as a main ruin even on a large surface")
			TEST_ASSERT(planet_test_load_ruin(ruin), "[name] didn't load")
	qdel(fit_planet, TRUE)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
