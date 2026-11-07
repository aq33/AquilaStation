// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { 	var/lhs = ##a; 	var/rhs = ##b; 	if (lhs != rhs) { 		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); 	} } while (FALSE)

/**
 * AQUILA - Trwała struktura statku: zmiany z rundy (okno, kabel, rura, ściany, uszkodzenia) zapisują się jako różnica
 * względem mapy i wracają na świeżej mapie. Dziura w kadłubie dostaje piankę, tabliczka ze zburzonej ściany
 * przechodzi na sąsiednią ścianę, a pole, na którym mapa się zmieniła, jest pomijane.
 */
/datum/unit_test/ship_structure
	var/turf/bottom_left

/datum/unit_test/ship_structure/proc/cell(dx, dy)
	return locate(bottom_left.x + dx, bottom_left.y + dy, bottom_left.z)

/datum/unit_test/ship_structure/proc/change(dx, dy, path)
	var/turf/T = cell(dx, dy)
	return T.ChangeTurf(path)

/// Stawia „mapę” od zera: czyści blok i buduje ten sam układ
/datum/unit_test/ship_structure/proc/build_map()
	for(var/turf/T as anything in block(bottom_left, cell(6, 6)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)
	for(var/dx in 1 to 5)
		for(var/dy in 1 to 4)
			change(dx, dy, /turf/open/floor/plasteel)
	// A (1,1): okno na kracie
	change(1, 1, /turf/open/floor/plating)
	new /obj/structure/grille(cell(1, 1))
	new /obj/structure/window/reinforced/fulltile(cell(1, 1))
	// Ściany wokół pola z tabliczką M (3,2): północ W1 (3,3) i zachód W2 (2,2)
	change(3, 3, /turf/closed/wall)
	change(2, 2, /turf/closed/wall)
	var/obj/structure/sign/warning/sign = new(cell(3, 2))
	sign.pixel_x = 0
	sign.pixel_y = 32
	// H (5,3): ściana kadłuba, za nią kosmos (6,3)
	change(5, 3, /turf/closed/wall)
	// Połamana krata z mapy ma obniżoną wytrzymałość od startu, a śluza obraca się w trakcie rundy: to nie są zmiany
	new /obj/structure/grille/broken(cell(4, 4))
	new /obj/machinery/door/airlock(cell(5, 4))

/datum/unit_test/ship_structure/Run()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(7, 7)
	TEST_ASSERT(reservation, "Could not reserve space")
	bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	build_map()

	var/datum/ship_structure/structure = new(list(bottom_left.z), list(bottom_left.x, bottom_left.y, bottom_left.x + 6, bottom_left.y + 6))
	structure.force_ship_area = TRUE
	structure.baseline = structure.capture()

	// Runda: gracze zmieniają statek
	qdel(locate(/obj/structure/window) in cell(1, 1))
	var/obj/structure/grille/grille = locate() in cell(1, 1)
	grille.obj_integrity = grille.max_integrity - 5
	new /obj/structure/cable(cell(2, 1), "yellow")
	var/turf/open/floor/broken_floor = cell(2, 1)
	broken_floor.break_tile()
	change(3, 1, /turf/closed/wall)
	change(4, 1, /turf/closed/wall)
	change(3, 3, /turf/open/floor/plating)
	change(5, 3, /turf/open/space)
	var/obj/machinery/atmospherics/pipe/simple/pipe = new(cell(1, 4))
	pipe.setDir(NORTH)
	pipe.set_init_directions()
	pipe.on_construction(null, PIPING_LAYER_DEFAULT)
	var/obj/machinery/door/airlock/airlock = locate() in cell(5, 4)
	airlock.setDir(turn(airlock.dir, 90))

	var/list/delta = structure.diff(structure.baseline, structure.capture(TRUE))
	for(var/list/coords in list(list(1, 1), list(2, 1), list(3, 1), list(4, 1), list(3, 3), list(5, 3), list(1, 4)))
		var/key = structure.key_for(cell(coords[1], coords[2]))
		TEST_ASSERT(delta[key], "Change at [coords[1]],[coords[2]] was not recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(3, 2))], "An unchanged turf was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(4, 4))], "A grille mapped as broken was recorded as damaged")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 4))], "A rotated airlock was recorded as replaced")
	// Zapis przechodzi przez JSON tak jak na serwerze
	delta = json_decode(json_encode(delta))

	// Następna runda: świeża mapa, w której pole (4,1) zmienił mapper
	build_map()
	change(4, 1, /turf/open/floor/plating)
	structure.baseline = structure.capture()
	var/list/result = structure.apply(delta)

	TEST_ASSERT_EQUAL(result[2], 1, "Only the turf changed on the map should be skipped")
	TEST_ASSERT(!isclosedturf(cell(4, 1)), "A record was applied over a turf the map changed")
	TEST_ASSERT(!(locate(/obj/structure/window) in cell(1, 1)), "The broken window came back")
	grille = locate() in cell(1, 1)
	TEST_ASSERT(grille, "The grille from the map is gone")
	TEST_ASSERT_EQUAL(grille.obj_integrity, grille.max_integrity - 5, "Grille damage was not restored")
	var/obj/structure/cable/cable = locate() in cell(2, 1)
	TEST_ASSERT(cable, "The built cable was not restored")
	TEST_ASSERT_EQUAL(cable.cable_color, "yellow", "Cable colour was not restored")
	broken_floor = cell(2, 1)
	TEST_ASSERT(broken_floor.broken, "Floor damage was not restored")
	TEST_ASSERT(isclosedturf(cell(3, 1)), "The built wall was not restored")
	pipe = locate() in cell(1, 4)
	TEST_ASSERT(pipe, "The built pipe was not restored")
	TEST_ASSERT_EQUAL(pipe.dir, NORTH, "Pipe direction was not restored")

	// Zburzona ściana W1: tabliczka z pola M przechodzi na inną ścianę przy tym polu (W2 z mapy albo nową ścianę (3,1))
	TEST_ASSERT(!isclosedturf(cell(3, 3)), "The removed wall came back")
	var/obj/structure/sign/warning/sign = locate() in cell(3, 2)
	TEST_ASSERT(sign, "The sign left its turf although a wall stands next to it")
	var/sign_dir = ship_structure_mount_dir(sign)
	TEST_ASSERT(sign_dir && sign_dir != NORTH, "The sign still hangs on the removed wall (pixel [sign.pixel_x],[sign.pixel_y])")
	TEST_ASSERT(isclosedturf(get_step(sign, sign_dir)), "The sign hangs where there is no wall (pixel [sign.pixel_x],[sign.pixel_y])")
	TEST_ASSERT(abs(sign.pixel_x) + abs(sign.pixel_y) == 32, "The sign lost its wall offset (pixel [sign.pixel_x],[sign.pixel_y])")

	// Dziura w kadłubie: podłoga z pianki i ściana z pianki od strony kosmosu
	var/turf/hull = cell(5, 3)
	TEST_ASSERT(istype(hull, /turf/open/floor/plating/foam), "The hull breach was not floored with foam ([hull.type])")
	TEST_ASSERT(locate(/obj/structure/foamedmetal) in cell(5, 3), "The hull breach was not sealed with foamed metal")

	// Pianka zapisuje się w następnej rundzie jak każda inna struktura
	var/list/next_delta = structure.diff(structure.baseline, structure.capture(TRUE))
	var/list/hull_record = next_delta[structure.key_for(cell(5, 3))]
	TEST_ASSERT(hull_record && hull_record["t"] == "[/turf/open/floor/plating/foam]", "The foam patch would not be saved")

	for(var/turf/T as anything in block(bottom_left, cell(6, 6)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
