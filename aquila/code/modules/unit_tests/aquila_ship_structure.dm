// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { 	var/lhs = ##a; 	var/rhs = ##b; 	if (lhs != rhs) { 		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); 	} } while (FALSE)

/**
 * AQUILA - Trwała struktura statku: zmiany z rundy (okno, kabel, rura, ściany, uszkodzenia) zapisują się jako różnica
 * względem mapy i wracają na świeżej mapie. Dziura w kadłubie dostaje piankę, tabliczka ze zburzonej ściany
 * przechodzi na sąsiednią ścianę, a pole, na którym mapa się zmieniła, jest pomijane.
 * Maszyny: przeniesiona nie dubluje się, zniszczona nie wraca, zbudowana wraca z częściami (w nullspace) i id,
 * obrót, przykręcenie i ulepszenia zostają, maszyna krytyczna i kanister nie trafiają do zapisu.
 * Rury: sąsiednie nowe rury i obrócona wentylacja łączą się w jedną sieć.
 * Turfy: podłoga położona na poszyciu ma pod sobą poszycie, naprawa uszkodzenia zostaje, prom nie trafia do zapisu.
 */
/datum/unit_test/ship_structure
	var/turf/bottom_left

/datum/unit_test/ship_structure/proc/cell(dx, dy)
	return locate(bottom_left.x + dx, bottom_left.y + dy, bottom_left.z)

/datum/unit_test/ship_structure/proc/change(dx, dy, path)
	var/turf/T = cell(dx, dy)
	return T.ChangeTurf(path)

/datum/unit_test/ship_structure/proc/count_in_block(path)
	. = 0
	for(var/turf/T as anything in block(bottom_left, cell(10, 10)))
		for(var/obj/found in T)
			if(istype(found, path))
				.++

/// Stawia „mapę” od zera: czyści blok i buduje ten sam układ
/datum/unit_test/ship_structure/proc/build_map()
	for(var/turf/T as anything in block(bottom_left, cell(10, 10)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)
	for(var/dx in 1 to 5)
		for(var/dy in 1 to 9)
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
	// Grzejnik luzem (do przykręcenia gdzie indziej) i przykręcony automat (do odkręcenia)
	var/obj/machinery/space_heater/heater = new(cell(1, 6))
	heater.anchored = FALSE
	new /obj/machinery/vending/snack(cell(4, 3))
	// (5,5): poszycie, na którym załoga położy płytkę
	change(5, 5, /turf/open/floor/plating)
	// (2,9): ściana kadłuba, (2,8) pole za nią: dziura na dwa pola
	change(2, 9, /turf/closed/wall)
	// (1,8): pole otwarte na kosmos już na mapie (bez ściany od zachodu)
	// (3,8): pole, na którym na koniec rundy stoi prom
	new /obj/structure/cable(cell(3, 8))
	// (4,8): punkt startu, na którym załoga postawi ścianę
	new /obj/effect/landmark(cell(4, 8))
	// (5,8): połamane poszycie z mapy, które załoga naprawi
	change(5, 8, /turf/open/floor/plating)
	var/turf/open/floor/damaged = cell(5, 8)
	damaged.break_tile()
	// (1,9): dwa przyciski różnych drzwi na jednym polu
	var/obj/machinery/button/door/keep_button = new(cell(1, 9))
	keep_button.id = "ship_structure_keep"
	var/obj/machinery/button/door/remove_button = new(cell(1, 9))
	remove_button.id = "ship_structure_remove"
	// (4,9): ładowarka z mapy, którą załoga ulepszy na miejscu
	new /obj/machinery/recharger(cell(4, 9))

/datum/unit_test/ship_structure/proc/replace_parts(obj/machinery/M, list/part_paths)
	for(var/obj/item/old_part in M.component_parts)
		qdel(old_part)
	M.component_parts = list()
	for(var/part_path in part_paths)
		M.component_parts += new part_path(null)
	M.RefreshParts()

/datum/unit_test/ship_structure/Run()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(11, 11)
	TEST_ASSERT(reservation, "Could not reserve space")
	bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	build_map()

	var/datum/ship_structure/structure = new(list(bottom_left.z), list(bottom_left.x, bottom_left.y, bottom_left.x + 10, bottom_left.y + 10))
	structure.force_ship_area = TRUE
	structure.baseline = structure.capture()
	TEST_ASSERT(locate(/obj/effect/landmark) in cell(4, 8), "Test setup: the landmark was not created")

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
	// Rury budowane jak przez gracza: samotna rura, a obok linia dwóch rur z wentylacją obróconą na zachód
	new /obj/machinery/atmospherics/pipe/simple(cell(1, 4), TRUE, NORTH)
	new /obj/machinery/atmospherics/pipe/simple(cell(3, 7), TRUE, EAST)
	new /obj/machinery/atmospherics/pipe/simple(cell(4, 7), TRUE, EAST)
	new /obj/machinery/atmospherics/components/unary/vent_pump(cell(5, 7), TRUE, WEST)
	structure.rebuild_atmos(list(cell(1, 4), cell(3, 7), cell(4, 7), cell(5, 7)))
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
	replace_parts(built, list(/obj/item/circuitboard/machine/recharger, /obj/item/stock_parts/capacitor/quadratic))
	var/obj/machinery/space_heater/heater = locate() in cell(1, 6)
	heater.forceMove(cell(1, 7))
	heater.anchored = TRUE
	var/obj/machinery/vending/snack/snack = locate() in cell(4, 3)
	snack.anchored = FALSE
	var/turf/plating = cell(5, 5)
	plating.PlaceOnTop(/turf/open/floor/plasteel)
	change(2, 8, /turf/open/space)
	change(2, 9, /turf/open/space)
	new /obj/structure/cable(cell(1, 8), "yellow")
	var/turf/dock = cell(3, 8)
	dock.PlaceOnTop(list(/turf/baseturf_skipover/shuttle, /turf/open/floor/mineral/titanium))
	change(4, 8, /turf/closed/wall)
	var/turf/open/floor/damaged = cell(5, 8)
	damaged.broken = FALSE
	damaged.icon_state = initial(damaged.icon_state)
	for(var/obj/machinery/button/door/found in cell(1, 9))
		if(found.id == "ship_structure_remove")
			qdel(found)
	var/obj/machinery/recharger/upgraded = locate() in cell(4, 9)
	replace_parts(upgraded, list(/obj/item/circuitboard/machine/recharger, /obj/item/stock_parts/capacitor/quadratic))

	var/list/delta = structure.diff(structure.baseline, structure.capture(TRUE))
	for(var/list/coords in list(list(1, 1), list(2, 1), list(3, 1), list(4, 1), list(3, 3), list(5, 3), list(1, 4), list(1, 6), list(1, 7), list(4, 3), list(5, 5), list(5, 8), list(1, 9), list(4, 9)))
		var/key = structure.key_for(cell(coords[1], coords[2]))
		TEST_ASSERT(delta[key], "Change at [coords[1]],[coords[2]] was not recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(3, 2))], "An unchanged turf was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(4, 4))], "A grille mapped as broken was recorded as damaged")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 4))], "A rotated airlock was recorded as replaced")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 1))], "A critical machine was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(5, 2))], "A portable canister was recorded")
	TEST_ASSERT(!delta[structure.key_for(cell(3, 4))] && !delta[structure.key_for(cell(2, 4))], "Loose medical equipment (an IV drip) was recorded as a machine")
	TEST_ASSERT(!delta[structure.key_for(cell(3, 8))], "A turf under a docked shuttle was recorded")
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

	// Rury
	var/obj/machinery/atmospherics/pipe/simple/pipe = locate() in cell(1, 4)
	TEST_ASSERT(pipe, "The built pipe was not restored")
	TEST_ASSERT_EQUAL(pipe.dir, NORTH, "Pipe direction was not restored")
	var/obj/machinery/atmospherics/pipe/simple/pipe_west = locate() in cell(3, 7)
	var/obj/machinery/atmospherics/pipe/simple/pipe_east = locate() in cell(4, 7)
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = locate() in cell(5, 7)
	TEST_ASSERT(pipe_west && pipe_east && vent, "The built pipe line with a vent was not restored")
	TEST_ASSERT_EQUAL(vent.dir, WEST, "The vent direction was not restored")
	TEST_ASSERT(vent.initialize_directions & WEST, "The restored vent connects on the wrong side (initialize_directions [vent.initialize_directions])")
	TEST_ASSERT(vent.nodes[1] == pipe_east, "The restored vent is not connected to the pipe next to it")
	TEST_ASSERT(pipe_west.parent && pipe_west.parent == pipe_east.parent, "The two restored pipes are not one network")
	TEST_ASSERT(pipe_west.parent.air, "The restored pipe network has no gas mixture")
	TEST_ASSERT(vent.parents[1] == pipe_east.parent, "The restored vent is not part of the pipe network")

	// Maszyny
	TEST_ASSERT(!(locate(/obj/machinery/vending/cola) in cell(2, 5)), "The moved vending machine is back on its map spot")
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/vending/cola), 1, "The moved vending machine is not exactly one")
	TEST_ASSERT(locate(/obj/machinery/vending/cola) in cell(3, 5), "The moved vending machine is not where it was left")
	TEST_ASSERT(!(locate(/obj/machinery/recharger) in cell(4, 5)), "The destroyed recharger came back")
	TEST_ASSERT(!(locate(/obj/machinery/portable_atmospherics/canister) in cell(3, 5)), "The map canister stayed under the moved vending machine")
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/portable_atmospherics/canister), 1, "The pushed canister is not exactly one")
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
	var/obj/item/stock_parts/capacitor/quadratic/built_capacitor = locate() in built.component_parts
	TEST_ASSERT(built_capacitor, "The recharger upgrade was not restored")
	TEST_ASSERT(isnull(built_capacitor.loc), "Restored machine parts must live in nullspace, not in the machine's contents")
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/space_heater), 1, "The heater wrenched down elsewhere was duplicated")
	heater = locate() in cell(1, 7)
	TEST_ASSERT(heater?.anchored, "The wrenched heater is not where it was left, anchored")
	snack = locate() in cell(4, 3)
	TEST_ASSERT(snack, "A vending machine left unwrenched was deleted")
	TEST_ASSERT(!snack.anchored, "The unwrenched vending machine came back anchored")
	var/list/buttons_left = list()
	for(var/obj/machinery/button/door/found in cell(1, 9))
		buttons_left += found.id
	TEST_ASSERT(length(buttons_left) == 1 && buttons_left[1] == "ship_structure_keep", "The wrong one of two buttons on a tile was removed ([jointext(buttons_left, ", ")])")
	upgraded = locate() in cell(4, 9)
	TEST_ASSERT(upgraded && (locate(/obj/item/stock_parts/capacitor/quadratic) in upgraded.component_parts), "The upgrade of a map machine was not restored")

	// Turfy
	var/turf/laid = cell(5, 5)
	TEST_ASSERT(istype(laid, /turf/open/floor/plasteel), "The floor laid on plating was not restored ([laid.type])")
	laid = laid.ScrapeAway()
	TEST_ASSERT(istype(laid, /turf/open/floor/plating), "Prying the restored floor tile did not leave plating ([laid.type])")
	damaged = cell(5, 8)
	TEST_ASSERT(!damaged.broken, "The repair of mapped floor damage was lost")
	TEST_ASSERT(istype(cell(3, 8), /turf/open/floor/plasteel) && (locate(/obj/structure/cable) in cell(3, 8)), "The turf under the shuttle dock was changed")
	TEST_ASSERT(isclosedturf(cell(4, 8)), "The wall built on a start landmark was not restored")
	TEST_ASSERT(!(locate(/obj/effect/landmark) in cell(4, 8)), "A start landmark stayed inside the built wall")
	var/obj/effect/landmark/moved_landmark
	for(var/turf/T as anything in block(cell(2, 6), cell(5, 9)))
		moved_landmark = moved_landmark || (locate(/obj/effect/landmark) in T)
	TEST_ASSERT(moved_landmark, "The start landmark was not moved next to the wall")

	// Zburzona ściana W1: tabliczka z pola M przechodzi na inną ścianę przy tym polu (W2 z mapy albo nową ścianę (3,1))
	TEST_ASSERT(!isclosedturf(cell(3, 3)), "The removed wall came back")
	var/obj/structure/sign/warning/sign = locate() in cell(3, 2)
	TEST_ASSERT(sign, "The sign left its turf although a wall stands next to it")
	var/sign_dir = ship_structure_mount_dir(sign)
	TEST_ASSERT(sign_dir && sign_dir != NORTH, "The sign still hangs on the removed wall (pixel [sign.pixel_x],[sign.pixel_y])")
	TEST_ASSERT(isclosedturf(get_step(sign, sign_dir)), "The sign hangs where there is no wall (pixel [sign.pixel_x],[sign.pixel_y])")
	TEST_ASSERT(abs(sign.pixel_x) + abs(sign.pixel_y) == 32, "The sign lost its wall offset (pixel [sign.pixel_x],[sign.pixel_y])")

	// Dziury w kadłubie: podłoga z pianki, ściana z pianki tylko od strony kosmosu, pole otwarte na mapie bez pianki
	var/turf/hull = cell(5, 3)
	TEST_ASSERT(istype(hull, /turf/open/floor/plating/foam), "The hull breach was not floored with foam ([hull.type])")
	TEST_ASSERT(locate(/obj/structure/foamedmetal) in cell(5, 3), "The hull breach was not sealed with foamed metal")
	TEST_ASSERT(istype(cell(2, 8), /turf/open/floor/plating/foam) && istype(cell(2, 9), /turf/open/floor/plating/foam), "The two-tile breach was not floored with foam")
	TEST_ASSERT(!(locate(/obj/structure/foamedmetal) in cell(2, 8)), "The inner tile of a two-tile breach was walled with foamed metal")
	TEST_ASSERT(locate(/obj/structure/foamedmetal) in cell(2, 9), "The outer tile of a two-tile breach was not sealed")
	TEST_ASSERT(locate(/obj/structure/cable) in cell(1, 8), "The cable on the tile open to space on the map was not restored")
	TEST_ASSERT(!(locate(/obj/structure/foamedmetal) in cell(1, 8)), "A tile open to space on the map was sealed with foam")

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
	var/obj/machinery/firealarm/hung_alarm = locate() in range(2, cell(2, 3))
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/vending/cola), 1, "Round 3: the vending machine is not exactly one")
	TEST_ASSERT(locate(/obj/machinery/vending/cola) in cell(3, 5), "Round 3: the vending machine wandered off")
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/firealarm), 1, "Round 3: the fire alarm is not exactly one")
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/space_heater), 1, "Round 3: the heater is not exactly one")
	var/alarm_dir = ship_structure_mount_dir(hung_alarm)
	TEST_ASSERT(alarm_dir && isclosedturf(get_step(hung_alarm, alarm_dir)), "Round 3: the fire alarm does not hang on a wall")
	TEST_ASSERT(!(locate(/obj/structure/window) in cell(1, 1)) && isclosedturf(cell(3, 1)) && !isclosedturf(cell(3, 3)), "Round 3: the structure changed")
	TEST_ASSERT(locate(/obj/machinery/recharger) in cell(3, 6), "Round 3: the built recharger is gone")
	vent = locate() in cell(5, 7)
	TEST_ASSERT(vent && vent.parents[1]?.air, "Round 3: the vent lost its pipe network")

	for(var/turf/T as anything in block(bottom_left, cell(10, 10)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)

/**
 * AQUILA - Głosowanie „Statek w następnej rundzie”: przy restarcie przewaga nowego statku kasuje zapis tej mapy (razem z kopią
 * zapasową), remis i brak głosów go zostawiają. Mocno zniszczony statek potrzebuje przewagi głosów za obecnym statkiem.
 */
/datum/unit_test/ship_structure_vote

/datum/unit_test/ship_structure_vote/Run()
	var/datum/ship_structure/structure = new(list(1))
	structure.save_path = "data/ship_structure/unit_test_vote.json"
	structure.saved_this_round = TRUE
	var/list/cases = list(
		list("votes" = list("a" = TRUE, "b" = FALSE, "c" = FALSE), "kept" = FALSE, "heavy" = FALSE, "name" = "new ship majority"),
		list("votes" = list("a" = TRUE, "b" = FALSE), "kept" = TRUE, "heavy" = FALSE, "name" = "tie"),
		list("votes" = list("a" = TRUE, "b" = TRUE, "c" = FALSE), "kept" = TRUE, "heavy" = FALSE, "name" = "keep majority"),
		list("votes" = list(), "kept" = TRUE, "heavy" = FALSE, "name" = "no votes"),
		list("votes" = list("a" = TRUE, "b" = FALSE), "kept" = FALSE, "heavy" = TRUE, "name" = "tie on a heavily damaged ship"),
		list("votes" = list(), "kept" = FALSE, "heavy" = TRUE, "name" = "no votes on a heavily damaged ship"),
		list("votes" = list("a" = TRUE, "b" = TRUE, "c" = FALSE), "kept" = TRUE, "heavy" = TRUE, "name" = "keep majority on a heavily damaged ship"),
	)
	for(var/list/test_case in cases)
		rustg_file_write("{}", structure.save_path)
		rustg_file_write("{}", "[structure.save_path].bak")
		var/list/votes = test_case["votes"]
		structure.keep_votes = votes.Copy()
		structure.heavy_damage = test_case["heavy"]
		structure.apply_vote()
		TEST_ASSERT_EQUAL(fexists(structure.save_path) ? TRUE : FALSE, test_case["kept"], "Wrong save state after the vote: [test_case["name"]]")
		TEST_ASSERT_EQUAL(fexists("[structure.save_path].bak") ? TRUE : FALSE, test_case["kept"], "Wrong backup state after the vote: [test_case["name"]]")
	for(var/path in list(structure.save_path, "[structure.save_path].bak"))
		if(fexists(path))
			fdel(path)

/// Test: zapis, w którym jedno pole rzuca błędem
/datum/ship_structure/failing_record

/datum/ship_structure/failing_record/apply_record(key, list/record, list/context)
	if(record["boom"])
		CRASH("Ship structure unit test: a broken record")
	return ..()

/**
 * AQUILA - Trwała struktura statku: zabezpieczenia (zgłoszenia z przeglądu raport/persistencja_01_przeglad.md).
 * Błąd przy jednym polu nie przerywa reszty, zostawia SSatoms w zwykłym trybie i odkłada zapis jako .broken; zmienna usunięta
 * z typu nie trafia do maszyny; osłona wieżyczki się nie dubluje; klatka magnesu nie jest zapisywana; po zmianie pliku mapy
 * rury i kable zostają z mapy; pole losowego pokoju z innym wariantem jest pomijane; maszyny krytycznej nie zamurowuje ściana;
 * punkt startu zapamiętany jako pole wychodzi ze ściany; rura zsypu wraca z kierunkiem; ocena mocnego zniszczenia.
 */
/datum/unit_test/ship_structure/safety

/datum/unit_test/ship_structure/safety/proc/floor_block()
	for(var/turf/T as anything in block(bottom_left, cell(10, 10)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)
	for(var/turf/T as anything in block(cell(1, 1), cell(9, 9)))
		T.ChangeTurf(/turf/open/floor/plasteel)

/datum/unit_test/ship_structure/safety/proc/new_structure(path = /datum/ship_structure)
	var/datum/ship_structure/structure = new path(list(bottom_left.z), list(bottom_left.x, bottom_left.y, bottom_left.x + 10, bottom_left.y + 10))
	structure.force_ship_area = TRUE
	return structure

/datum/unit_test/ship_structure/safety/Run()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(11, 11)
	TEST_ASSERT(reservation, "Could not reserve space")
	bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])

	// Błąd przy jednym polu: reszta się nakłada, SSatoms wraca do zwykłego trybu, zapis idzie do kwarantanny
	floor_block()
	var/datum/ship_structure/structure = new_structure(/datum/ship_structure/failing_record)
	structure.baseline = structure.capture()
	change(2, 2, /turf/closed/wall)
	change(3, 3, /turf/closed/wall)
	var/obj/machinery/recharger/recharger = new(cell(4, 4))
	var/list/delta = structure.diff(structure.baseline, structure.capture(TRUE))
	var/list/broken_record = delta[structure.key_for(cell(2, 2))]
	broken_record["boom"] = TRUE
	// Zmienna, której typ nie ma (np. usunięta z kodu po zapisie): preloader ustawiałby ją na ślepo
	var/list/machine_record = delta[structure.key_for(cell(4, 4))]
	var/list/added_machine = machine_record["a"][1]
	added_machine["v"] = list("id" = "no_such_var_on_a_recharger")
	TEST_ASSERT(!("id" in recharger.vars), "Test setup: the recharger has an id var, pick another machine")
	structure.save_path = "data/ship_structure/unit_test_safety.json"
	rustg_file_write(json_encode(list("version" = 2, "rounds" = 1, "turfs" = delta)), structure.save_path)
	// Kopia zapasowa idzie do kwarantanny razem z zapisem, inaczej następne wczytanie wzięłoby starszy statek
	rustg_file_write("{}", "[structure.save_path].bak")
	floor_block()
	structure.baseline = structure.capture()
	structure.load()
	TEST_ASSERT(!fexists("[structure.save_path].bak") && fexists("[structure.save_path].bak.broken"), "The backup of a save with errors was not moved aside")
	fdel("[structure.save_path].bak.broken")
	TEST_ASSERT_EQUAL(structure.load_errors, 1, "A broken record was not counted as an error")
	TEST_ASSERT(isclosedturf(cell(3, 3)), "A broken record stopped the rest of the save from loading")
	TEST_ASSERT(!isclosedturf(cell(2, 2)), "The broken record was applied")
	TEST_ASSERT(locate(/obj/machinery/recharger) in cell(4, 4), "A machine with a var its type no longer has was not restored")
	TEST_ASSERT_EQUAL(SSatoms.initialized, INITIALIZATION_INNEW_REGULAR, "SSatoms stayed in map loading mode after the load")
	TEST_ASSERT(!GLOB.use_preloader, "The preloader stayed on after the load")
	TEST_ASSERT(!fexists(structure.save_path) && fexists("[structure.save_path].broken"), "A save with errors was not moved aside as .broken")
	fdel("[structure.save_path].broken")

	// Uszkodzony plik główny: wczytuje się kopia zapasowa
	floor_block()
	structure = new_structure()
	structure.save_path = "data/ship_structure/unit_test_safety.json"
	structure.baseline = structure.capture()
	change(5, 5, /turf/closed/wall)
	structure.save()
	change(5, 5, /turf/open/floor/plasteel)
	change(6, 6, /turf/closed/wall)
	structure.save()
	TEST_ASSERT(fexists("[structure.save_path].bak"), "Saving did not keep a backup of the previous save")
	rustg_file_write("{broken", structure.save_path)
	floor_block()
	structure.baseline = structure.capture()
	structure.load()
	TEST_ASSERT(isclosedturf(cell(5, 5)) && !isclosedturf(cell(6, 6)), "The backup was not loaded when the save was unreadable")
	for(var/path in list(structure.save_path, "[structure.save_path].bak", "[structure.save_path].broken"))
		if(fexists(path))
			fdel(path)

	// Osłona wieżyczki zbudowanej przez załogę: po wczytaniu jedna, z wieżyczką
	floor_block()
	structure = new_structure()
	structure.baseline = structure.capture()
	new /obj/machinery/porta_turret(cell(5, 5))
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/porta_turret_cover), 1, "Test setup: the turret has no cover")
	delta = json_decode(json_encode(structure.diff(structure.baseline, structure.capture(TRUE))))
	floor_block()
	structure.baseline = structure.capture()
	structure.apply(delta)
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/porta_turret), 1, "The built turret was not restored")
	TEST_ASSERT_EQUAL(count_in_block(/obj/machinery/porta_turret_cover), 1, "The turret cover was duplicated")
	var/obj/machinery/porta_turret_cover/cover = locate() in cell(5, 5)
	TEST_ASSERT(cover?.parent_turret, "The turret cover has no turret")

	// Klatka magnesu nie jest zapisywana
	floor_block()
	var/obj/machinery/computer/ship/mineral_magnet/magnet = new(cell(1, 1))
	magnet.target_location = cell(6, 6)
	structure = new_structure()
	structure.cache_shuttle_areas()
	TEST_ASSERT(structure.skip_turf(cell(7, 7)), "A magnet cage turf is not skipped")
	TEST_ASSERT(!structure.skip_turf(cell(2, 2)), "A turf outside the magnet cage is skipped")
	qdel(magnet)

	// Suma kontrolna mapy przez load(): ta sama = kabel wraca, inna albo brak (stary zapis) = kabel zostaje z mapy, ściana wraca zawsze
	var/current_hash = ship_structure_map_hash()
	TEST_ASSERT(current_hash, "The map hash of the test map is empty, the map change protection would never trigger")
	for(var/list/hash_case in list(list("hash" = current_hash, "cable" = TRUE), list("hash" = "unit_test_other_map", "cable" = FALSE), list("hash" = null, "cable" = FALSE)))
		floor_block()
		structure = new_structure()
		structure.save_path = "data/ship_structure/unit_test_safety.json"
		structure.baseline = structure.capture()
		change(2, 2, /turf/closed/wall)
		new /obj/structure/cable(cell(3, 3), "yellow")
		var/list/hash_save = list("version" = 2, "rounds" = 1, "turfs" = structure.diff(structure.baseline, structure.capture(TRUE)))
		if(hash_case["hash"])
			hash_save["map_hash"] = hash_case["hash"]
		rustg_file_write(json_encode(hash_save), structure.save_path)
		floor_block()
		structure.baseline = structure.capture()
		structure.load()
		TEST_ASSERT(isclosedturf(cell(2, 2)), "A wall was not restored (map hash [hash_case["hash"] || "missing"])")
		TEST_ASSERT_EQUAL((locate(/obj/structure/cable) in cell(3, 3)) ? TRUE : FALSE, hash_case["cable"], "Wrong cable state for map hash [hash_case["hash"] || "missing"]")
		fdel(structure.save_path)

	// Zmieniony plik mapy: ściana wraca, kabel i rura zostają z mapy
	floor_block()
	structure = new_structure()
	structure.baseline = structure.capture()
	change(2, 2, /turf/closed/wall)
	new /obj/structure/cable(cell(3, 3), "yellow")
	new /obj/machinery/atmospherics/pipe/simple(cell(4, 4), TRUE, NORTH)
	delta = json_decode(json_encode(structure.diff(structure.baseline, structure.capture(TRUE))))
	floor_block()
	structure.baseline = structure.capture()
	structure.keep_map_installations = TRUE
	structure.apply(delta)
	TEST_ASSERT(isclosedturf(cell(2, 2)), "A wall was dropped because the map file changed")
	TEST_ASSERT(!(locate(/obj/structure/cable) in cell(3, 3)), "A cable was restored although the map file changed")
	TEST_ASSERT(!(locate(/obj/machinery/atmospherics/pipe) in cell(4, 4)), "A pipe was restored although the map file changed")

	// Losowy pokój: zapis z innego wariantu jest pomijany, z tego samego nakładany
	floor_block()
	structure = new_structure()
	GLOB.ship_structure_room_turfs[cell(2, 2)] = "unit_test_room_a"
	GLOB.ship_structure_room_turfs[cell(3, 3)] = "unit_test_room_a"
	structure.baseline = structure.capture()
	change(2, 2, /turf/closed/wall)
	change(3, 3, /turf/closed/wall)
	delta = json_decode(json_encode(structure.diff(structure.baseline, structure.capture(TRUE))))
	floor_block()
	GLOB.ship_structure_room_turfs[cell(2, 2)] = "unit_test_room_b"
	structure.baseline = structure.capture()
	structure.check_rooms = TRUE
	structure.apply(delta)
	GLOB.ship_structure_room_turfs -= list(cell(2, 2), cell(3, 3))
	TEST_ASSERT(!isclosedturf(cell(2, 2)), "A record from another random room variant was applied")
	TEST_ASSERT(isclosedturf(cell(3, 3)), "A record from the same random room variant was skipped")

	// Maszyna krytyczna wraca z mapy, więc ściana załogi na jej polu nie powstaje
	floor_block()
	structure = new_structure()
	new /obj/machinery/computer/communications(cell(2, 2))
	structure.baseline = structure.capture()
	qdel(locate(/obj/machinery/computer/communications) in cell(2, 2))
	change(2, 2, /turf/closed/wall)
	new /obj/structure/grille(cell(3, 3))
	delta = json_decode(json_encode(structure.diff(structure.baseline, structure.capture(TRUE))))
	floor_block()
	new /obj/machinery/computer/communications(cell(2, 2))
	structure.baseline = structure.capture()
	structure.apply(delta)
	TEST_ASSERT(!isclosedturf(cell(2, 2)), "A critical machine from the map was walled in")
	TEST_ASSERT(locate(/obj/machinery/computer/communications) in cell(2, 2), "The critical machine is gone")
	TEST_ASSERT(locate(/obj/structure/grille) in cell(3, 3), "A record next to the critical machine was not applied")

	// Punkt startu zapamiętany jako pole (np. blob) nie zostaje w nowej ścianie
	floor_block()
	structure = new_structure()
	structure.baseline = structure.capture()
	change(5, 5, /turf/closed/wall)
	delta = json_decode(json_encode(structure.diff(structure.baseline, structure.capture(TRUE))))
	floor_block()
	structure.baseline = structure.capture()
	var/turf/spawn_turf = cell(5, 5)
	GLOB.blobstart += spawn_turf
	var/blobstart_count = length(GLOB.blobstart)
	structure.apply(delta)
	var/moved = !(spawn_turf in GLOB.blobstart) && length(GLOB.blobstart) == blobstart_count
	var/turf/replacement = GLOB.blobstart[length(GLOB.blobstart)]
	GLOB.blobstart -= replacement
	TEST_ASSERT(isclosedturf(cell(5, 5)), "Test setup: the wall was not restored")
	TEST_ASSERT(moved && !isclosedturf(replacement), "A turf-only spawn point stayed inside a restored wall")

	// Rura zsypu wraca z kierunkiem i połączeniami
	floor_block()
	structure = new_structure()
	structure.baseline = structure.capture()
	var/obj/structure/disposalpipe/segment/disposal = new(cell(6, 6))
	disposal.setDir(EAST)
	qdel(disposal)
	// Jak z mapy: kierunek przed Initialize (przez preloader), żeby rura policzyła połączenia od właściwej strony
	world.preloader_setup(list("dir" = EAST), /obj/structure/disposalpipe/segment)
	disposal = new(cell(6, 6))
	var/expected_dpdir = disposal.dpdir
	delta = json_decode(json_encode(structure.diff(structure.baseline, structure.capture(TRUE))))
	floor_block()
	structure.baseline = structure.capture()
	structure.apply(delta)
	disposal = locate() in cell(6, 6)
	TEST_ASSERT(disposal, "The built disposal pipe was not restored")
	TEST_ASSERT_EQUAL(disposal.dir, EAST, "The disposal pipe direction was not restored")
	TEST_ASSERT_EQUAL(disposal.dpdir, expected_dpdir, "The restored disposal pipe connects on the wrong sides")

	// Mocne zniszczenie: co najmniej 10% pól statku zamienionych w kosmos
	floor_block()
	structure = new_structure()
	structure.baseline = structure.capture()
	for(var/dx in 1 to 9)
		change(dx, 1, /turf/open/space)
	TEST_ASSERT(structure.is_heavily_damaged(structure.diff(structure.baseline, structure.capture(TRUE))), "A ship with 9 of 81 turfs in space is not heavily damaged")
	floor_block()
	change(1, 1, /turf/open/space)
	TEST_ASSERT(!structure.is_heavily_damaged(structure.diff(structure.baseline, structure.capture(TRUE))), "A ship with one hole is heavily damaged")
	// Dziury załatane pianką przy wczytaniu (zniszczenia z poprzednich rund) liczą się tak samo
	floor_block()
	for(var/dx in 1 to 9)
		var/turf/patched = cell(dx, 1)
		patched.ChangeTurf(/turf/open/floor/plating/foam)
	TEST_ASSERT(structure.is_heavily_damaged(structure.diff(structure.baseline, structure.capture(TRUE))), "Foam-patched holes from earlier rounds do not count as damage")

	// Kamera wisi na ścianie za sobą, teleporter nie ma losowego id w sygnaturze
	var/obj/machinery/camera/camera = new(cell(4, 4))
	camera.setDir(NORTH)
	TEST_ASSERT_EQUAL(ship_structure_mount_dir(camera), SOUTH, "A camera facing north does not hang on the wall to the south")
	var/obj/machinery/computer/teleporter/teleporter = new(cell(5, 4))
	TEST_ASSERT_EQUAL(ship_structure_obj_sig(teleporter), "[/obj/machinery/computer/teleporter];0", "The random teleporter id is part of the signature")

	for(var/turf/T as anything in block(bottom_left, cell(10, 10)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)

/**
 * AQUILA - Zabezpieczenie kadłuba: dziura, której łatanie zapisu nie objęło (pole spoza zapisu, zmiana po wczytaniu),
 * dostaje piankę tak samo jak dziura z zapisu. Pole otwarte na kosmos już na mapie i miejsce po promie zostają.
 */
/datum/unit_test/ship_structure/safety/hull_check

/datum/unit_test/ship_structure/safety/hull_check/Run()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(11, 11)
	TEST_ASSERT(reservation, "Could not reserve space")
	bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	floor_block()
	// (9,5): ściana kadłuba, (5,5): środek pomieszczenia, (5,9) i (6,9): podłoga przy kosmosie, (6,8): pole przy promie
	change(9, 5, /turf/closed/wall)
	for(var/dx in 4 to 7)
		change(dx, 9, /turf/closed/wall)
	change(5, 9, /turf/open/floor/plasteel)
	change(6, 9, /turf/open/floor/plasteel)
	new /obj/machinery/door/airlock/external(cell(6, 9))
	var/datum/ship_structure/structure = new_structure()
	structure.baseline = structure.capture()
	structure.baseline[structure.key_for(cell(7, 8))] = "shuttle" // SHIP_STRUCTURE_SHUTTLE (undef na końcu ship_structure.dm)
	structure.map_open = structure.capture_open_to_space()
	TEST_ASSERT(structure.map_open[structure.key_for(cell(1, 5))], "Test setup: the edge of the block is not open to space")
	TEST_ASSERT(!structure.map_open[structure.key_for(cell(8, 5))], "Test setup: the tile behind the hull wall is open to space")

	// Dziury, których nie ma w zapisie: zburzona ściana, wyrwana podłoga, wyrwana śluza, pole po odlatującym promie
	// i zburzona ściana (7,9) między miejscem po promie a kosmosem
	change(9, 5, /turf/open/space)
	change(5, 5, /turf/open/space)
	qdel(locate(/obj/machinery/door/airlock) in cell(6, 9))
	change(7, 8, /turf/open/space)
	change(7, 9, /turf/open/space)
	TEST_ASSERT_EQUAL(structure.seal_hull(), 4, "The hull check did not seal exactly the four breaches")
	TEST_ASSERT(istype(cell(9, 5), /turf/open/floor/plating/foam) && (locate(/obj/structure/foamedmetal) in cell(9, 5)), "The broken hull wall was not sealed with foam")
	TEST_ASSERT(istype(cell(5, 5), /turf/open/floor/plating/foam), "The hole in the floor was not floored with foam")
	TEST_ASSERT(!(locate(/obj/structure/foamedmetal) in cell(5, 5)), "The hole inside the room was walled with foamed metal")
	TEST_ASSERT(locate(/obj/structure/foamedmetal) in cell(6, 9), "The tile of the torn out airlock was not sealed")
	TEST_ASSERT(!istype(cell(8, 5), /turf/open/floor/plating/foam) && !(locate(/obj/structure/foamedmetal) in cell(8, 5)), "The tile behind the patched hull was changed")
	TEST_ASSERT(!(locate(/obj/structure/foamedmetal) in cell(1, 5)), "A tile open to space on the map was sealed")
	TEST_ASSERT(!(locate(/obj/structure/foamedmetal) in cell(6, 8)) && isspaceturf(cell(7, 8)), "The tile next to a departed shuttle was sealed")
	TEST_ASSERT(istype(cell(7, 9), /turf/open/floor/plating/foam) && (locate(/obj/structure/foamedmetal) in cell(7, 9)), "The broken hull wall next to a departed shuttle was not sealed")

	// Drugie przejście przy wczytaniu nie łata niczego drugi raz
	TEST_ASSERT_EQUAL(structure.seal_hull(), 0, "The hull check sealed something twice")
	// Start rundy: dziura, która powstała po wczytaniu (ściana (4,9)), zostaje załatana, a lista pól z mapy idzie do kosza
	change(4, 9, /turf/open/space)
	TEST_ASSERT_EQUAL(structure.seal_hull(TRUE), 1, "The hull check at round start did not seal the new breach")
	TEST_ASSERT(istype(cell(4, 9), /turf/open/floor/plating/foam) && (locate(/obj/structure/foamedmetal) in cell(4, 9)), "The breach made after loading was not sealed at round start")
	TEST_ASSERT(isnull(structure.map_open), "The map snapshot of open tiles was kept after the round start")

	for(var/turf/T as anything in block(bottom_left, cell(10, 10)))
		for(var/obj/O in T)
			qdel(O)
		T.ChangeTurf(/turf/open/space)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
