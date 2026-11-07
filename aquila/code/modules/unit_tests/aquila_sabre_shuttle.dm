// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Sabre jako shuttle: wnętrze staje na porcie, startuje na overmapę, wraca do doku i znajduje miejsce przy kadłubie
/datum/unit_test/sabre_shuttle

/datum/unit_test/sabre_shuttle/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system, "No main ship in a star system to launch from")
	var/datum/turf_reservation/hangar = SSmapping.RequestBlockReservation(60, 60)
	hangar.overmap_fallback = host
	var/list/bl = hangar.bottom_left_coords
	// Port po Initialize sam stawia na sobie wnętrze (load_roundstart), tak jak port na mapie
	// Wczytanie mapy usypia, więc new() wraca przed zadokowaniem
	var/obj/docking_port/stationary/sabre/mining/port = new(locate(bl[1] + 40, bl[2] + 40, bl[3]))
	var/timeout = world.time + 30 SECONDS
	while(!port.docked && world.time < timeout)
		sleep(1)

	var/obj/docking_port/mobile/sabre/shuttle_port = port.docked
	TEST_ASSERT(istype(shuttle_port), "The Sabre template didn't dock at its port")
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
	TEST_ASSERT(istype(sabre, /obj/structure/overmap/small_craft/transport/sabre/shuttle/mining), "The mining template didn't create a mining Sabre")
	TEST_ASSERT_EQUAL(sabre.sabre_docked_at, port, "The new Sabre isn't docked")
	TEST_ASSERT_EQUAL(sabre.sabre_home_port, port, "The Sabre doesn't remember its home port")
	TEST_ASSERT(istype(get_turf(sabre), /turf/closed/indestructible/dropship/sabre_hatch), "The docked Sabre doesn't wait at its hatch")
	TEST_ASSERT_EQUAL(sabre.invisibility, INVISIBILITY_ABSTRACT, "The docked Sabre is visible in the hangar")
	TEST_ASSERT_EQUAL(length(sabre.sabre_exit_turfs()), 2, "The hatch should open onto two tiles")
	TEST_ASSERT(length(sabre.interior_entry_points), "The Sabre has no entry points inside")
	for(var/turf/T as anything in sabre.sabre_exit_turfs())
		TEST_ASSERT(!istype(T.loc, /area/shuttle/sabre), "An exit tile [COORD(T)] is inside the Sabre")
	var/obj/machinery/computer/ship/helm/console/dropship/sabre/helm = locate() in shuttle_port.return_turfs()
	if(!helm)
		for(var/turf/T as anything in shuttle_port.return_turfs())
			helm = locate() in T
			if(helm)
				break
	TEST_ASSERT(helm, "The Sabre interior has no helm")
	TEST_ASSERT_EQUAL(helm.has_overmap(), sabre, "The docked helm doesn't control its own Sabre")

	sabre.set_fuel(500)
	TEST_ASSERT(sabre.sabre_launch(), "The Sabre didn't launch")
	TEST_ASSERT(!sabre.sabre_docked_at, "The launched Sabre still counts as docked")
	TEST_ASSERT(SSmapping.level_trait(sabre.z, ZTRAIT_OVERMAP), "The launched Sabre isn't on the overmap")
	TEST_ASSERT_EQUAL(shuttle_port.docked, sabre.sabre_parking, "The interior didn't move to its parking port")
	TEST_ASSERT(!port.docked, "The hangar port is still taken after launch")
	var/turf/hull = get_turf(helm)
	TEST_ASSERT_EQUAL(hull.get_overmap(), sabre, "The interior in flight doesn't belong to the Sabre")
	TEST_ASSERT_EQUAL(length(sabre.exit_offsets), 2, "The landing search doesn't know where the hatch opens")
	TEST_ASSERT(length(sabre.hull_offsets) > 60, "The landing search doesn't know the hull shape")

	TEST_ASSERT_EQUAL(sabre.sabre_find_landing(host), port, "The Sabre doesn't pick its free home port")
	TEST_ASSERT(sabre.sabre_land(host, port), "The Sabre didn't land at its home port")
	TEST_ASSERT_EQUAL(shuttle_port.docked, port, "The interior isn't back at the hangar port")
	TEST_ASSERT_EQUAL(sabre.sabre_docked_at, port, "The landed Sabre doesn't count as docked")
	TEST_ASSERT(istype(get_turf(sabre), /turf/closed/indestructible/dropship/sabre_hatch), "The landed Sabre isn't hidden at its hatch")

	// Lądowanie przy obcym kadłubie: właz ma wyjść prosto na podłogę
	var/turf/platform_center = locate(bl[1] + 10, bl[2] + 20, bl[3])
	for(var/turf/T as anything in RANGE_TURFS(2, platform_center))
		T.ChangeTurf(/turf/open/floor/plating)
	var/turf/spot = sabre.sabre_find_spot(host, platform_center)
	TEST_ASSERT(spot, "No landing spot next to a floor platform")
	var/lands_on_floor = FALSE
	for(var/list/offset as anything in sabre.exit_offsets)
		var/turf/exit = locate(spot.x + offset[1], spot.y + offset[2], spot.z)
		if(istype(exit, /turf/open/floor))
			lands_on_floor = TRUE
	TEST_ASSERT(lands_on_floor, "The chosen spot doesn't put the hatch next to the floor")

	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	qdel(port, TRUE)
	qdel(hangar)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

