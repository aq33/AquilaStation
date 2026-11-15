// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety: księżyc, pole asteroid, słaby sygnał i gazowe olbrzymy generują powierzchnię z bezpiecznymi
/// lądowiskami, a po unload() nic nie zostaje
/datum/unit_test/planet_moon_surfaces

/datum/unit_test/planet_moon_surfaces/Run()
	for(var/planet_type in planet_test_sample(list(/datum/planet_type/moon, /datum/planet_type/asteroid, /datum/planet_type/asteroid/space_signal, /datum/planet_type/gas_giant, /datum/planet_type/gas_giant/plasma)))
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		var/datum/planet_surface/surface = planet.surface
		TEST_ASSERT(surface.generate(), "[planet_type] surface didn't generate")
		TEST_ASSERT_EQUAL(length(surface.landing_zones), PLANET_LANDING_ZONES, "[planet_type] has a wrong number of landing zones")
		for(var/turf/zone as anything in surface.landing_zones)
			for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2) - 1, zone))
				TEST_ASSERT(!is_planet_hazard_turf(T), "[planet_type] landing zone has hazardous ground at [T.x],[T.y] ([T.type])")
		var/list/inner = surface.inner_turfs()
		var/space = 0
		var/chasm = 0
		var/ground = 0
		for(var/turf/T as anything in inner)
			if(isspaceturf(T))
				space++
			else if(ischasm(T))
				chasm++
			else if(!is_planet_hazard_turf(T))
				ground++
		switch(planet_type)
			if(/datum/planet_type/moon)
				TEST_ASSERT_EQUAL(space, 0, "The moon has space turfs on its surface")
				TEST_ASSERT(ground > length(inner) / 3, "The moon has too little walkable ground ([ground] of [length(inner)])")
			if(/datum/planet_type/asteroid, /datum/planet_type/asteroid/space_signal)
				TEST_ASSERT(space > 0, "[planet_type] has no open space between the rocks")
				TEST_ASSERT(ground > 0, "[planet_type] has no asteroid ground")
			else
				TEST_ASSERT(chasm > 0, "[planet_type] has no gas abyss")
				TEST_ASSERT_EQUAL(space, 0, "[planet_type] has space turfs")
				var/siphons = 0
				for(var/turf/zone as anything in surface.landing_zones)
					for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
						if(locate(/obj/machinery/planet_gas_siphon) in T)
							siphons++
				TEST_ASSERT_EQUAL(siphons, PLANET_LANDING_ZONES, "[planet_type] platforms don't each have a gas siphon")
		surface.unload()
		TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "[planet_type] surface didn't unload")
		qdel(planet, TRUE)

/// AQUILA - planety: syfon gazu na platformie olbrzyma napełnia kanister obok gazem planety (plazmowy: plazmą)
/datum/unit_test/planet_gas_siphon

/datum/unit_test/planet_gas_siphon/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/gas_giant/plasma)
	var/datum/planet_surface/surface = planet.surface
	TEST_ASSERT(surface.generate(), "The plasma giant surface didn't generate")
	var/obj/machinery/planet_gas_siphon/siphon
	for(var/turf/zone as anything in surface.landing_zones)
		for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
			siphon = locate(/obj/machinery/planet_gas_siphon) in T
			if(siphon)
				break
		if(siphon)
			break
	TEST_ASSERT(siphon, "No gas siphon on the plasma giant platforms")
	var/list/canisters = siphon.pump_targets()
	TEST_ASSERT(length(canisters), "No canister next to the siphon")
	var/obj/machinery/portable_atmospherics/canister/canister = canisters[1]
	var/start_pressure = canister.air_contents.return_pressure()
	siphon.set_on(TRUE)
	for(var/i in 1 to 5)
		siphon.process(1)
	siphon.set_on(FALSE)
	TEST_ASSERT(canister.air_contents.return_pressure() > start_pressure, "The siphon didn't fill the canister")
	TEST_ASSERT(canister.air_contents.get_moles(GAS_PLASMA) > 0, "The plasma giant siphon didn't pump plasma")
	surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: każda ruina księżyca i kosmiczna z Shiptesta ma plik mapy, mieści się na dużej powierzchni i wczytuje
/// się (każda we własnej pustej rezerwacji, żeby ruiny nie nachodziły na siebie), a kratery (greeble) księżyca wczytują się
/// na powierzchni księżyca
/datum/unit_test/planet_moon_ruins

/datum/unit_test/planet_moon_ruins/Run()
	var/list/templates = planet_ruin_templates_of(/datum/map_template/ruin/planet_moon) + planet_ruin_templates_of(/datum/map_template/ruin/planet_space)
	TEST_ASSERT_EQUAL(length(templates), 8, "Wrong number of moon and space ruins registered")
	var/obj/structure/overmap/planet/fit_planet = new(run_loc_floor_top_right, /datum/planet_type/moon)
	var/datum/planet_surface/fit_check = fit_planet.surface
	for(var/name in planet_test_sample(templates, 2))
		var/datum/map_template/ruin/ruin = templates[name]
		// Bez pliku mapy szablon ma rozmiar 0 i „wczytuje się” jako pusta mapa
		TEST_ASSERT(ruin.width && ruin.height, "[name] map file didn't preload ([ruin.mappath], fexists: [fexists(ruin.mappath)])")
		TEST_ASSERT(fit_check.main_ruin_fits(ruin, PLANET_SURFACE_SIZE_LARGE), "[name] ([ruin.width]x[ruin.height]) doesn't fit as a main ruin even on a large surface")
		var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(ruin.width, ruin.height)
		TEST_ASSERT(reservation, "No room to load [name]")
		var/turf/corner = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
		// Jak przy generowaniu planety: atmosfera stoi, póki ruina się nie wczyta (wraki są celowo rozszczelnione)
		lazy_template_load_started()
		var/loaded = ruin.load(corner)
		lazy_template_load_finished()
		// Rezerwacja zwalniana przy działającej atmosferze, jak przy znikaniu powierzchni w grze (zwalnianie przy wstrzymanej
		// atmosferze wywracało auxmos w process_atmos_callbacks)
		qdel(reservation)
		TEST_ASSERT(loaded, "[name] didn't load")
	qdel(fit_planet, TRUE)

	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/moon)
	var/datum/planet_surface/surface = planet.surface
	TEST_ASSERT(surface.generate(), "The moon surface didn't generate")
	var/obj/effect/greeble_spawner/moon/crater_spawner = new(surface.center())
	var/list/crater_maps = crater_spawner.greeble_maps.Copy()
	qdel(crater_spawner)
	var/turf/bl = surface.bottom_left()
	var/turf/crater_spot = locate(bl.x + round(surface.size / 2), bl.y + PLANET_EDGE_WIDTH + 10, bl.z)
	for(var/map_path in crater_maps)
		var/datum/map_template/crater = new(map_path, "test crater", TRUE)
		TEST_ASSERT(crater.width, "Crater map [map_path] didn't preload")
		TEST_ASSERT(crater.load(crater_spot, centered = TRUE), "Crater map [map_path] didn't load")
	surface.unload()
	qdel(planet, TRUE)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
