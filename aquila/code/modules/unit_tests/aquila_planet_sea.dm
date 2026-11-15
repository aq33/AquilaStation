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
	for(var/planet_type in list(/datum/planet_type/beach, /datum/planet_type/water, /datum/planet_type/dwarf/water))
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		var/datum/planet_surface/surface = planet.surface
		TEST_ASSERT(surface.generate(), "[planet_type] surface didn't generate")
		TEST_ASSERT_EQUAL(surface.size, planet.planet_type.surface_size, "[planet_type] surface has the wrong size without a large main ruin")
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
	for(var/planet_type in sets)
		var/list/templates = sets[planet_type]
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		// Największa możliwa powierzchnia: ruiny główne muszą się na niej zmieścić
		planet.planet_type.surface_size = PLANET_SURFACE_SIZE_LARGE
		TEST_ASSERT(planet.surface.generate(), "[planet_type] surface didn't generate")
		var/datum/planet_surface/surface = planet.surface
		var/turf/bl = surface.bottom_left()
		for(var/name in templates)
			var/datum/map_template/ruin/ruin = templates[name]
			TEST_ASSERT(surface.main_ruin_fits(ruin, PLANET_SURFACE_SIZE_LARGE), "[name] ([ruin.width]x[ruin.height]) doesn't fit as a main ruin even on a large surface")
			var/turf/corner = locate(bl.x + PLANET_EDGE_WIDTH + 6, bl.y + surface.size - PLANET_EDGE_WIDTH - 6 - ruin.height, bl.z)
			TEST_ASSERT(surface.load_ruin(ruin, corner, FALSE), "[name] didn't load")
			for(var/turf/T as anything in ruin.get_affected_turfs(corner, FALSE))
				TEST_ASSERT(surface.contains(T), "[name] spills outside the planet surface")
		surface.unload()
		qdel(planet, TRUE)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
