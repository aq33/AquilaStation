// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { 	var/lhs = ##a; 	var/rhs = ##b; 	if (lhs != rhs) { 		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); 	} } while (FALSE)

/**
 * AQUILA - Trwała struktura statku: zmiany z rundy (okno, kabel, rura, ściany, uszkodzenia) zapisują się jako różnica
 * względem mapy i wracają na świeżej mapie. Dziura w kadłubie dostaje piankę, tabliczka ze zburzonej ściany
 * przechodzi na sąsiednią ścianę, a pole, na którym mapa się zmieniła, jest pomijane.
 * Maszyny: przeniesiona nie dubluje się, zniszczona nie wraca, zbudowana wraca z częściami i id, obrót zostaje,
 * a maszyna krytyczna i kanister nie trafiają do zapisu.
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
	for(var/turf/T as anything in block(bottom_left, cell(8, 8)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)
	for(var/dx in 1 to 5)
		for(var/dy in 1 to 7)
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
	// Maszyny z mapy: automat do przeniesienia, ładowarka do zniszczenia, konsola do obrócenia, konsola krytyczna
	new /obj/machinery/vending/cola(cell(2, 5))
	new /obj/machinery/recharger(cell(4, 5))
	var/obj/machinery/computer/crew/console = new(cell(4, 6))
	console.setDir(SOUTH)
	new /obj/machinery/computer/communications(cell(5, 1))
	new /obj/machinery/iv_drip(cell(3, 4))
	// Rzeczy z mapy na polach, które zajmie zapis: kanister i klucz pod przeniesionym automatem, łom pod nowym oknem
	new /obj/machinery/portable_atmospherics/canister/air(cell(3, 5))
	new /obj/item/wrench(cell(3, 5))
	new /obj/item/crowbar(cell(2, 7))
	// Alarm pożarowy na polu (2,3) wisi na ścianie W1 od wschodu
	var/obj/machinery/firealarm/alarm = new(cell(2, 3))
	alarm.pixel_x = 26
	alarm.pixel_y = 0

/datum/unit_test/ship_structure/Run()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(9, 9)
	TEST_ASSERT(reservation, "Could not reserve space")
	bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	build_map()

	var/datum/ship_structure/structure = new(list(bottom_left.z), list(bottom_left.x, bottom_left.y, bottom_left.x + 8, bottom_left.y + 8))
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
	var/obj/machinery/vending/cola/vending = locate() in cell(2, 5)
	vending.forceMove(cell(3, 5))
	qdel(locate(/obj/machinery/recharger) in cell(4, 5))
	var/obj/machinery/computer/crew/console = locate() in cell(4, 6)
	console.setDir(EAST)
	qdel(locate(/obj/machinery/computer/communications) in cell(5, 1))
	new /obj/machinery/portable_atmospherics/canister/air(cell(5, 2))
	var/obj/machinery/iv_drip/drip = locate() in cell(3, 4)
	drip.forceMove(cell(2, 4))
	new /obj/structure/grille(cell(2, 7))
	new /obj/structure/window/reinforced/fulltile(cell(2, 7))
	var/obj/machinery/button/door/button = new(cell(2, 6))
	button.id = "ship_structure_test"
	var/obj/machinery/recharger/built = new(cell(3, 6))
	for(var/obj/item/old_part in built.component_parts)
		qdel(old_part)
	built.component_parts = list(new /obj/item/circuitboard/machine/recharger(built), new /obj/item/stock_parts/capacitor/quadratic(built))
	built.RefreshParts()

	var/list/delta = structure.diff(structure.baseline, structure.capture(TRUE))
	for(var/list/coords in list(list(1, 1), list(2, 1), list(3, 1), list(4, 1), list(3, 3), list(5, 3), list(1, 4)))
		var/key = structure.key_for(cell(coords[1], coords[2]))
		TEST_ASSERT(delta[key], "Change at [coords[1]],[coords[2]] was not recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(3, 2))], "An unchanged turf was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(4, 4))], "A grille mapped as broken was recorded as damaged")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 4))], "A rotated airlock was recorded as replaced")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 1))], "A critical machine was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 2))], "A portable canister was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(3, 4))] && !delta[structure.key_for(cell(2, 4))], "Loose equipment (an unanchored IV drip) was recorded as a machine")
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

	// Maszyny
	TEST_ASSERT(!(locate(/obj/machinery/vending/cola) in cell(2, 5)), "The moved vending machine is back on its map spot")
	var/vending_count = 0
	for(var/turf/T as anything in block(bottom_left, cell(8, 8)))
		for(var/obj/machinery/vending/cola/found in T)
			vending_count++
	TEST_ASSERT_EQUAL(vending_count, 1, "The moved vending machine is not exactly one")
	TEST_ASSERT(locate(/obj/machinery/vending/cola) in cell(3, 5), "The moved vending machine is not where it was left")
	TEST_ASSERT(!(locate(/obj/machinery/recharger) in cell(4, 5)), "The destroyed recharger came back")
	TEST_ASSERT(!(locate(/obj/machinery/portable_atmospherics/canister) in cell(3, 5)), "The map canister stayed under the moved vending machine")
	var/canisters = 0
	for(var/turf/T as anything in block(bottom_left, cell(8, 8)))
		for(var/obj/machinery/portable_atmospherics/canister/found in T)
			canisters++
	TEST_ASSERT_EQUAL(canisters, 1, "The pushed canister is not exactly one")
	TEST_ASSERT(locate(/obj/item/wrench) in cell(3, 5), "An item was pushed out from under a machine (only dense things should move)")
	TEST_ASSERT(locate(/obj/structure/window) in cell(2, 7), "The built window was not restored")
	TEST_ASSERT(!(locate(/obj/item/crowbar) in cell(2, 7)), "The map crowbar stayed inside the built full-tile window")
	var/obj/item/crowbar/pushed_crowbar = locate() in range(2, cell(2, 7))
	TEST_ASSERT(pushed_crowbar, "The map crowbar was not pushed next to the window")
	console = locate() in cell(4, 6)
	TEST_ASSERT(console, "The map console is gone")
	TEST_ASSERT_EQUAL(console.dir, EAST, "The console rotation was not restored")
	TEST_ASSERT(locate(/obj/machinery/computer/communications) in cell(5, 1), "The critical machine did not come back from the map")
	TEST_ASSERT(!(locate(/obj/machinery/portable_atmospherics/canister) in cell(5, 2)), "A canister was carried over like a machine")
	button = locate() in cell(2, 6)
	TEST_ASSERT(button, "The built button was not restored")
	TEST_ASSERT_EQUAL(button.id, "ship_structure_test", "The built button lost its id")
	built = locate() in cell(3, 6)
	TEST_ASSERT(built, "The built recharger was not restored")
	TEST_ASSERT(locate(/obj/item/stock_parts/capacitor/quadratic) in built.component_parts, "The recharger upgrade was not restored")

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

	// Trzecia runda: zapis zrobiony po nałożonym zapisie daje ten sam statek (nic się nie dubluje ani nie wędruje)
	next_delta = json_decode(json_encode(next_delta))
	build_map()
	change(4, 1, /turf/open/floor/plating)
	structure.baseline = structure.capture()
	structure.apply(next_delta)
	var/vendings = 0
	var/alarms = 0
	var/obj/machinery/firealarm/hung_alarm
	for(var/turf/T as anything in block(bottom_left, cell(8, 8)))
		for(var/obj/machinery/vending/cola/found in T)
			vendings++
		for(var/obj/machinery/firealarm/found in T)
			alarms++
			hung_alarm = found
	TEST_ASSERT_EQUAL(vendings, 1, "Round 3: the vending machine is not exactly one")
	TEST_ASSERT(locate(/obj/machinery/vending/cola) in cell(3, 5), "Round 3: the vending machine wandered off")
	TEST_ASSERT_EQUAL(alarms, 1, "Round 3: the fire alarm is not exactly one")
	var/alarm_dir = ship_structure_mount_dir(hung_alarm)
	TEST_ASSERT(alarm_dir && isclosedturf(get_step(hung_alarm, alarm_dir)), "Round 3: the fire alarm does not hang on a wall")
	TEST_ASSERT(!(locate(/obj/structure/window) in cell(1, 1)) && isclosedturf(cell(3, 1)) && !isclosedturf(cell(3, 3)), "Round 3: the structure changed")
	TEST_ASSERT(locate(/obj/machinery/recharger) in cell(3, 6), "Round 3: the built recharger is gone")

	for(var/turf/T as anything in block(bottom_left, cell(8, 8)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)

/// AQUILA - Głosowanie „Statek w następnej rundzie”: przewaga „odbuduj” odrzuca zapis, remis i głosy dla innej mapy go zostawiają
/datum/unit_test/ship_structure_vote

/datum/unit_test/ship_structure_vote/Run()
	var/vote_file = "data/ship_structure/vote.json"
	var/datum/ship_structure/structure = new(list(1))
	structure.save_path = "data/ship_structure/unit_test_vote.json"
	var/list/cases = list(
		list("votes" = list("a" = TRUE, "b" = FALSE, "c" = FALSE), "save" = structure.save_path, "expected" = TRUE, "name" = "rebuild majority"),
		list("votes" = list("a" = TRUE, "b" = FALSE), "save" = structure.save_path, "expected" = FALSE, "name" = "tie"),
		list("votes" = list("a" = FALSE), "save" = "data/ship_structure/other_map.json", "expected" = FALSE, "name" = "vote for another map"),
	)
	for(var/list/test_case in cases)
		rustg_file_write(json_encode(list("save" = test_case["save"], "votes" = test_case["votes"])), vote_file)
		TEST_ASSERT_EQUAL(structure.consume_last_vote(), test_case["expected"], "Wrong vote result for: [test_case["name"]]")
		TEST_ASSERT(!fexists(vote_file), "The vote file was not consumed ([test_case["name"]])")
	TEST_ASSERT(!structure.consume_last_vote(), "No vote file must keep the ship")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
