// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - prom z Wyznacznika Stref Promu: sterownik tworzy jednostkę overmapy, prom startuje i wraca na plac budowy
/datum/unit_test/custom_shuttle_overmap

/datum/unit_test/custom_shuttle_overmap/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system, "No main ship in a star system to launch from")
	var/datum/turf_reservation/site = SSmapping.RequestBlockReservation(20, 20)
	site.overmap_fallback = host
	var/list/bl = site.bottom_left_coords
	var/x0 = bl[1] + 5
	var/y0 = bl[2] + 5
	var/z = bl[3]

	// Prom 5x5 tak jak po Wyznaczniku: obszar, port na placu budowy, mobilny port z polami promu
	var/list/turfs = block(locate(x0, y0, z), locate(x0 + 4, y0 + 4, z))
	for(var/turf/T as anything in turfs)
		T.ChangeTurf(/turf/open/floor/plasteel)
	var/area/shuttle/custom/powered/shuttle_area = new
	shuttle_area.setup("prom testowy")
	var/obj/docking_port/stationary/site_port = new(locate(x0, y0, z))
	site_port.width = 5
	site_port.height = 5
	site_port.delete_after = TRUE
	var/obj/docking_port/mobile/port = new(locate(x0, y0, z))
	port.width = 5
	port.height = 5
	port.id = "custom_test"
	port.name = "prom testowy"
	port.area_type = shuttle_area.type
	port.shuttle_areas = list()
	port.shuttle_areas[shuttle_area] = TRUE
	for(var/turf/T as anything in turfs)
		port.add_turf(T, shuttle_area)
	shuttle_area.link_to_shuttle(port)
	port.register()
	TEST_ASSERT_EQUAL(port.docked, site_port, "The test shuttle isn't docked at its construction site")

	new /obj/machinery/door/airlock(locate(x0 + 4, y0 + 2, z))
	new /obj/machinery/shuttle/engine/void(locate(x0 + 2, y0, z))
	var/obj/machinery/computer/shuttle_flight/custom_shuttle/console = new(locate(x0 + 2, y0 + 3, z))
	console.linkShuttle(port.id)

	var/obj/structure/overmap/small_craft/transport/custom_shuttle/craft = console.get_overmap_craft()
	TEST_ASSERT(istype(craft), "The flight console didn't create an overmap craft")
	TEST_ASSERT_EQUAL(craft.shuttle_port, port, "The craft isn't linked to its shuttle")
	TEST_ASSERT_EQUAL(craft.shuttle_home_port, site_port, "The construction site isn't the craft's home port")
	TEST_ASSERT(!site_port.delete_after, "The construction site would be deleted after the first departure")
	TEST_ASSERT_EQUAL(get_turf(craft), get_turf(console), "The docked craft doesn't wait at the flight console")
	TEST_ASSERT_EQUAL(console.get_overmap(), craft, "The flight console doesn't control its craft")
	var/list/exits = craft.shuttle_exit_turfs()
	var/turf/airlock_outside = locate(x0 + 5, y0 + 2, z)
	TEST_ASSERT(airlock_outside in exits, "The airlock doesn't lead out of the shuttle")

	TEST_ASSERT(craft.shuttle_launch(), "The custom shuttle didn't launch with a void thruster")
	TEST_ASSERT(SSmapping.level_trait(craft.z, ZTRAIT_OVERMAP), "The launched custom shuttle isn't on the overmap")
	TEST_ASSERT_EQUAL(port.docked, craft.shuttle_parking, "The custom shuttle didn't move to its parking port")
	TEST_ASSERT(!QDELETED(site_port), "The construction site was deleted after launch")
	TEST_ASSERT(craft.engines_active(), "The void thruster doesn't count as a working engine")

	TEST_ASSERT_EQUAL(craft.shuttle_find_landing(host), site_port, "The custom shuttle doesn't return to its construction site")
	TEST_ASSERT(craft.shuttle_land(host, site_port), "The custom shuttle didn't land at its construction site")
	TEST_ASSERT_EQUAL(port.docked, site_port, "The interior isn't back at the construction site")
	TEST_ASSERT_EQUAL(get_turf(craft), get_turf(console), "The landed craft isn't hidden at the flight console")

	port.jumpToNullSpace()
	if(!QDELETED(craft))
		qdel(craft)
	qdel(site_port, TRUE)
	qdel(site)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

