// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety skaliste, białych piasków, pustynne, mgliste i karłowate: powierzchnia każdego typu powstaje
/// z krawędzią, trzema bezpiecznymi lądowiskami i zawartością (rośliny, zwierzęta albo żyły), a potem się zwalnia
/datum/unit_test/planet_piaski_surfaces

/datum/unit_test/planet_piaski_surfaces/Run()
	var/list/planet_types = list(
		/datum/planet_type/rock,
		/datum/planet_type/sand,
		/datum/planet_type/desert,
		/datum/planet_type/shrouded,
		/datum/planet_type/dwarf/dust,
		/datum/planet_type/dwarf/dune,
	)
	for(var/planet_type in planet_test_sample(planet_types))
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		var/datum/planet_surface/surface = planet.surface
		TEST_ASSERT(surface.generate(), "[planet_type] surface didn't generate")
		var/turf/bl = surface.bottom_left()
		TEST_ASSERT(istype(bl, /turf/closed/indestructible/rock/planet_edge), "[planet_type] surface corner isn't the planet edge ([bl.type])")
		if(ispath(planet_type, /datum/planet_type/dwarf))
			TEST_ASSERT_EQUAL(surface.size, PLANET_SURFACE_SIZE_DWARF, "[planet_type] isn't a small surface")
		TEST_ASSERT_EQUAL(length(surface.landing_zones), PLANET_LANDING_ZONES, "[planet_type] has the wrong number of landing zones")
		for(var/turf/zone as anything in surface.landing_zones)
			for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
				TEST_ASSERT(!is_planet_hazard_turf(T), "[planet_type] landing zone has unsafe ground at [T.x],[T.y] ([T.type])")
		var/content = 0
		var/space = 0
		for(var/turf/T as anything in surface.inner_turfs())
			if(isspaceturf(T))
				space++
			for(var/atom/movable/AM as anything in T)
				if(istype(AM, /obj/structure/flora) || istype(AM, /obj/structure/vein) || isliving(AM))
					content++
		TEST_ASSERT_EQUAL(space, 0, "[planet_type] left space turfs on the surface")
		TEST_ASSERT(content > 0, "[planet_type] surface has no plants, animals or ore veins")
		surface.unload()
		TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "[planet_type] surface didn't unload")
		qdel(planet, TRUE)

/// AQUILA - ruiny i greeble partii piasków: każda ruina główna mieści się na powiększonej powierzchni i się wczytuje,
/// każda mapa greebla białych piasków się wczytuje
/datum/unit_test/planet_piaski_ruins

/datum/unit_test/planet_piaski_ruins/Run()
	var/list/ruin_roots = list(
		/datum/map_template/ruin/planet_rock = 7,
		/datum/map_template/ruin/planet_sand = 7,
		/datum/map_template/ruin/planet_desert = 4,
		/datum/map_template/ruin/planet_shrouded = 3,
	)
	// Każda ruina mieści się na dużej powierzchni i wczytuje się we własnej pustej rezerwacji (wczytywane jedna na drugą
	// dublowały kable, a miny i kwas z jednej ruiny niszczyły następną przed jej Initialize)
	var/obj/structure/overmap/planet/fit_planet = new(run_loc_floor_top_right, /datum/planet_type/sand)
	for(var/ruin_root in ruin_roots)
		var/list/templates = get_planet_ruin_templates(ruin_root)
		TEST_ASSERT_EQUAL(length(templates), ruin_roots[ruin_root], "Wrong number of [ruin_root] ruins registered")
		for(var/name in planet_test_sample(templates, 1))
			var/datum/map_template/ruin/ruin = templates[name]
			TEST_ASSERT(ruin.width && ruin.height, "[name] map file didn't preload ([ruin.mappath])")
			TEST_ASSERT(fit_planet.surface.main_ruin_fits(ruin, PLANET_SURFACE_SIZE_LARGE), "[name] ([ruin.width]x[ruin.height]) doesn't fit even on the large surface")
			TEST_ASSERT(planet_test_load_ruin(ruin), "[name] didn't load")
	qdel(fit_planet, TRUE)
	// Greeble: każda mapa (wkompilowana w .rsc) parsuje się i wczytuje we własnej rezerwacji
	var/list/greeble_maps = list()
	for(var/spawner_type in list(/obj/effect/greeble_spawner/whitesands_oasis, /obj/effect/greeble_spawner/whitesands_sulfurpool))
		var/obj/effect/greeble_spawner/spawner = new spawner_type(run_loc_floor_bottom_left)
		greeble_maps |= spawner.greeble_maps
		qdel(spawner)
	TEST_ASSERT_EQUAL(length(greeble_maps), 20, "Wrong number of whitesands greeble maps")
	for(var/greeble_map in planet_test_sample(greeble_maps, 3))
		var/datum/map_template/template = new(greeble_map, "test greeble", TRUE)
		TEST_ASSERT(template.width, "Greeble map [greeble_map] didn't parse")
		var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(template.width + 2, template.height + 2)
		TEST_ASSERT(reservation, "No room for greeble map [greeble_map]")
		var/turf/corner = locate(reservation.bottom_left_coords[1] + 1, reservation.bottom_left_coords[2] + 1, reservation.bottom_left_coords[3])
		TEST_ASSERT(template.load(corner), "Greeble map [greeble_map] didn't load")
		qdel(reservation)

/// AQUILA - planety mgliste zagłuszają radio na powierzchni, a kwaśne jeziorko białych piasków parzy brodzącego
/datum/unit_test/planet_piaski_hazards

/datum/unit_test/planet_piaski_hazards/Run()
	var/area/planet/surface/shrouded/shrouded_area = new
	var/turf/inside = run_loc_floor_bottom_left
	var/turf/outside = get_step(inside, EAST)
	var/area/old_area = inside.loc
	shrouded_area.contents += inside
	inside.change_area(old_area, shrouded_area)
	var/obj/item/radio/jammed_radio = allocate(/obj/item/radio, inside)
	var/obj/item/radio/clear_radio = allocate(/obj/item/radio, outside)
	TEST_ASSERT(jammed_radio.is_jammed(), "A radio on a shrouded planet isn't jammed")
	TEST_ASSERT(!clear_radio.is_jammed(), "A radio outside the shrouded planet is jammed")
	shrouded_area.contents -= inside
	old_area.contents += inside
	inside.change_area(shrouded_area, old_area)

	var/turf/acid_turf = get_step(outside, EAST)
	var/old_turf_type = acid_turf.type
	acid_turf = acid_turf.ChangeTurf(/turf/open/water/planet/acid)
	var/mob/living/carbon/human/wader = allocate(/mob/living/carbon/human, outside)
	wader.forceMove(acid_turf)
	TEST_ASSERT(wader.getFireLoss() > 0, "Wading into a sulfuric acid pool doesn't burn")
	acid_turf.ChangeTurf(old_turf_type)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
