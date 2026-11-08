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
	TEST_ASSERT_EQUAL(sabre.shuttle_docked_at, port, "The new Sabre isn't docked")
	TEST_ASSERT_EQUAL(sabre.shuttle_home_port, port, "The Sabre doesn't remember its home port")
	TEST_ASSERT(istype(get_turf(sabre), /turf/closed/indestructible/dropship/sabre_hatch), "The docked Sabre doesn't wait at its hatch")
	TEST_ASSERT_EQUAL(sabre.invisibility, INVISIBILITY_ABSTRACT, "The docked Sabre is visible in the hangar")
	TEST_ASSERT_EQUAL(length(sabre.shuttle_exit_turfs()), 2, "The hatch should open onto two tiles")
	TEST_ASSERT(length(sabre.interior_entry_points), "The Sabre has no entry points inside")
	for(var/turf/T as anything in sabre.shuttle_exit_turfs())
		TEST_ASSERT(!istype(T.loc, /area/shuttle/sabre), "An exit tile [COORD(T)] is inside the Sabre")
	var/obj/machinery/computer/ship/helm/console/dropship/sabre/helm
	for(var/turf/T as anything in shuttle_port.return_turfs())
		helm = locate() in T
		if(helm)
			break
	TEST_ASSERT(helm, "The Sabre interior has no helm")
	TEST_ASSERT_EQUAL(helm.has_overmap(), sabre, "The docked helm doesn't control its own Sabre")

	sabre.set_fuel(500)
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't launch")
	TEST_ASSERT(!sabre.shuttle_docked_at, "The launched Sabre still counts as docked")
	TEST_ASSERT(SSmapping.level_trait(sabre.z, ZTRAIT_OVERMAP), "The launched Sabre isn't on the overmap")
	TEST_ASSERT_EQUAL(shuttle_port.docked, sabre.shuttle_parking, "The interior didn't move to its parking port")
	TEST_ASSERT(!port.docked, "The hangar port is still taken after launch")
	var/turf/hull = get_turf(helm)
	TEST_ASSERT_EQUAL(hull.get_overmap(), sabre, "The interior in flight doesn't belong to the Sabre")
	TEST_ASSERT_EQUAL(length(sabre.exit_offsets), 2, "The landing search doesn't know where the hatch opens")
	TEST_ASSERT(length(sabre.hull_offsets) > 60, "The landing search doesn't know the hull shape")

	TEST_ASSERT_EQUAL(sabre.shuttle_find_landing(host), port, "The Sabre doesn't pick its free home port")
	TEST_ASSERT(sabre.shuttle_land(host, port), "The Sabre didn't land at its home port")
	TEST_ASSERT_EQUAL(shuttle_port.docked, port, "The interior isn't back at the hangar port")
	TEST_ASSERT_EQUAL(sabre.shuttle_docked_at, port, "The landed Sabre doesn't count as docked")
	TEST_ASSERT(istype(get_turf(sabre), /turf/closed/indestructible/dropship/sabre_hatch), "The landed Sabre isn't hidden at its hatch")

	// Lądowanie przy obcym kadłubie: właz ma wyjść prosto na podłogę
	var/turf/platform_center = locate(bl[1] + 10, bl[2] + 20, bl[3])
	for(var/turf/T as anything in RANGE_TURFS(2, platform_center))
		T.ChangeTurf(/turf/open/floor/plating)
	var/turf/spot = sabre.shuttle_find_spot(host, platform_center)
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

/// Port skierowany na wschód (jak w zatoce górniczej Atlasa): szablon wczytany na NORTH obraca się przy dokowaniu
/obj/docking_port/stationary/sabre/mining/unit_test_east
	dir = EAST

/// AQUILA - Sabre na porcie skierowanym inaczej niż szablon: kadłub obraca się razem z grafiką, właz wychodzi na lewą burtę
/datum/unit_test/sabre_shuttle_rotated

/datum/unit_test/sabre_shuttle_rotated/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system, "No main ship in a star system to launch from")
	var/datum/turf_reservation/hangar = SSmapping.RequestBlockReservation(30, 30)
	hangar.overmap_fallback = host
	var/list/bl = hangar.bottom_left_coords
	// Przy dir EAST port stoi w lewym górnym rogu, a kadłub idzie na wschód i w dół
	var/obj/docking_port/stationary/sabre/mining/unit_test_east/port = new(locate(bl[1] + 10, bl[2] + 20, bl[3]))
	var/timeout = world.time + 30 SECONDS
	while(!port.docked && world.time < timeout)
		sleep(1)
	var/obj/docking_port/mobile/sabre/shuttle_port = port.docked
	TEST_ASSERT(istype(shuttle_port), "The Sabre template didn't dock at the east-facing port")
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
	TEST_ASSERT(istype(sabre), "The rotated Sabre has no overmap craft")
	TEST_ASSERT_EQUAL(shuttle_port.dir, EAST, "The interior didn't turn to the port's direction")

	// Ster w szablonie stoi w kokpicie (4,7); po obrocie na wschód kokpit jest po wschodniej stronie kadłuba
	var/obj/machinery/computer/ship/helm/console/dropship/sabre/helm
	for(var/turf/T as anything in shuttle_port.return_turfs())
		helm = locate() in T
		if(helm)
			break
	TEST_ASSERT(helm, "The rotated Sabre has no helm")
	TEST_ASSERT_EQUAL(helm.x, port.x + 6, "The cockpit isn't at the nose after turning east")
	TEST_ASSERT_EQUAL(helm.y, port.y - 3, "The cockpit isn't at the nose after turning east")

	// Grafika kadłuba obraca się razem z kafelkami (90 stopni zgodnie z ruchem wskazówek zegara)
	var/turf/closed/indestructible/dropship/hull = get_step(helm, EAST)
	TEST_ASSERT(istype(hull), "No hull turf in front of the rotated cockpit")
	var/matrix/turned = hull.transform
	TEST_ASSERT(abs(turned.a) < 0.01 && abs(turned.b - 1) < 0.01, "The hull art didn't turn with the hull (transform [turned.a],[turned.b],[turned.d],[turned.e])")
	var/turf/open/indestructible/dropship/floor = get_turf(helm)
	TEST_ASSERT(istype(floor), "The helm doesn't stand on the dropship floor")
	TEST_ASSERT(floor.transform ~= hull.transform, "The floor art turned differently than the hull")

	// Właz w lewej gondoli: przy dziobie na wschód otwiera się na północ, tuż nad kadłubem
	var/list/exits = sabre.shuttle_exit_turfs()
	TEST_ASSERT_EQUAL(length(exits), 2, "The rotated hatch should open onto two tiles")
	for(var/turf/T as anything in exits)
		TEST_ASSERT_EQUAL(T.y, port.y + 1, "The rotated hatch doesn't open to the north of the hull")

	// Start i powrót do tego samego portu nie obracają kadłuba drugi raz
	sabre.set_fuel(500)
	TEST_ASSERT(sabre.shuttle_launch(), "The rotated Sabre didn't launch")
	TEST_ASSERT(sabre.shuttle_land(host, port), "The rotated Sabre didn't land back at its port")
	TEST_ASSERT_EQUAL(helm.x, port.x + 6, "The cockpit moved after flying out and back")
	TEST_ASSERT_EQUAL(helm.y, port.y - 3, "The cockpit moved after flying out and back")
	hull = get_step(helm, EAST)
	turned = hull.transform
	TEST_ASSERT(abs(turned.a) < 0.01 && abs(turned.b - 1) < 0.01, "The hull art turned again after flying out and back")

	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	qdel(port, TRUE)
	qdel(hangar)

/// Duży obiekt z polem kolizji na kilka kafelków, jak działo Gaussa (96x64 z przesunięciem o kafelek w lewo i w dół)
/obj/structure/unit_test_wide_neighbour
	anchored = TRUE
	density = TRUE
	bound_x = -32
	bound_y = -32
	bound_width = 96
	bound_height = 64

/// AQUILA - lądujący Sabre nie usuwa sąsiada, który stoi obok portu, a tylko polem kolizji zahacza o skrzydło
/// (Padalec: działo Gaussa na 200,123 przy padzie 191-199 x 116-124)
/datum/unit_test/sabre_shuttle_wide_neighbour

/datum/unit_test/sabre_shuttle_wide_neighbour/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system, "No main ship in a star system to launch from")
	var/datum/turf_reservation/hangar = SSmapping.RequestBlockReservation(30, 30)
	hangar.overmap_fallback = host
	var/list/bl = hangar.bottom_left_coords
	var/obj/docking_port/stationary/sabre/mining/port = new(locate(bl[1] + 5, bl[2] + 5, bl[3]))
	var/timeout = world.time + 30 SECONDS
	while(!port.docked && world.time < timeout)
		sleep(1)
	var/obj/docking_port/mobile/sabre/shuttle_port = port.docked
	TEST_ASSERT(istype(shuttle_port), "The Sabre template didn't dock")
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
	sabre.set_fuel(500)
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't launch")
	var/obj/structure/unit_test_wide_neighbour/neighbour = new(locate(port.x + 9, port.y + 7, port.z))
	TEST_ASSERT(sabre.shuttle_land(host, port), "The Sabre didn't land back")
	TEST_ASSERT(!QDELETED(neighbour), "Landing deleted the wide object next to the port")
	TEST_ASSERT_EQUAL(neighbour.loc, locate(port.x + 9, port.y + 7, port.z), "Landing moved the wide object next to the port")

	qdel(neighbour)
	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	qdel(port, TRUE)
	qdel(hangar)

/// AQUILA - właz przy zewnętrznych drzwiach śluzy statku (Padalec): wysiadający otwiera śluzę i staje w drzwiach
/datum/unit_test/sabre_exit_through_airlock

/datum/unit_test/sabre_exit_through_airlock/Run()
	var/datum/turf_reservation/hangar = SSmapping.RequestBlockReservation(30, 30)
	var/list/bl = hangar.bottom_left_coords
	var/obj/docking_port/stationary/sabre/mining/port = new(locate(bl[1] + 5, bl[2] + 5, bl[3]))
	var/timeout = world.time + 30 SECONDS
	while(!port.docked && world.time < timeout)
		sleep(1)
	var/obj/docking_port/mobile/sabre/shuttle_port = port.docked
	TEST_ASSERT(istype(shuttle_port), "The Sabre template didn't dock")
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
	var/list/exits = sabre.shuttle_exit_turfs()
	TEST_ASSERT_EQUAL(length(exits), 2, "The hatch should open onto two tiles")
	var/turf/wall_exit = exits[1]
	var/turf/door_exit = exits[2]
	wall_exit.ChangeTurf(/turf/closed/wall)
	door_exit = door_exit.ChangeTurf(/turf/open/floor/plating)
	var/obj/machinery/door/airlock/external/door = new(door_exit)
	door.machine_stat &= ~NOPOWER
	TEST_ASSERT(door.density, "The test airlock should start closed")

	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human)
	var/obj/machinery/computer/ship/helm/console/dropship/sabre/helm
	for(var/turf/T as anything in shuttle_port.return_turfs())
		helm = locate() in T
		if(helm)
			break
	pilot.forceMove(get_turf(helm))
	TEST_ASSERT(sabre.shuttle_leave(pilot), "Leaving through a closed airlock next to the hatch failed")
	TEST_ASSERT_EQUAL(pilot.loc, door_exit, "The pilot didn't step into the airlock")
	timeout = world.time + 5 SECONDS
	while(door.density && world.time < timeout)
		sleep(1)
	TEST_ASSERT(!door.density, "The airlock next to the hatch didn't open")

	// Ryglowana śluza zostaje zamknięta: wtedy nie ma którędy wyjść
	pilot.forceMove(get_turf(helm))
	timeout = world.time + 5 SECONDS
	while(door.operating && world.time < timeout)
		sleep(1)
	door.close()
	while(!door.density && world.time < timeout)
		sleep(1)
	TEST_ASSERT(door.density, "The test airlock didn't close again")
	door.locked = TRUE
	TEST_ASSERT(!sabre.shuttle_leave(pilot), "The pilot left through a bolted airlock")

	qdel(door)
	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	qdel(port, TRUE)
	qdel(hangar)

/// AQUILA - porty Sabre na mapie: na starcie rundy każdy ma wnętrze z jednostką overmapy, a z włazu da się wyjść
/datum/unit_test/sabre_map_ports

/datum/unit_test/sabre_map_ports/Run()
	for(var/obj/docking_port/stationary/sabre/port in SSshuttle.stationary)
		if(!is_station_level(port.z))
			continue
		var/obj/docking_port/mobile/sabre/shuttle_port = port.docked
		TEST_ASSERT(istype(shuttle_port), "The Sabre port at [COORD(port)] has no Sabre docked")
		var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
		TEST_ASSERT(istype(sabre), "The Sabre at [COORD(port)] has no overmap craft")
		TEST_ASSERT_EQUAL(sabre.shuttle_docked_at, port, "The Sabre at [COORD(port)] doesn't count as docked")
		var/exits = 0
		for(var/turf/T as anything in sabre.shuttle_exit_turfs())
			if(!T.density && !isspaceturf(T) && !istype(T, /turf/open/openspace))
				exits++
		TEST_ASSERT(exits, "The hatch of the Sabre at [COORD(port)] doesn't open onto a floor")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL


