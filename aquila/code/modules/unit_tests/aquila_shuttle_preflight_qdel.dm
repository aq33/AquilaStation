// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - runda 6589: prom ewakuacyjny rozpadł się na części, bo atom usunięty w beforeShuttleMove skracał listę zawartości kafelka,
/// preflight_check() kończył się runtime'em, a docking i tak przenosił tylko kafelki sprawdzone przed błędem
/datum/unit_test/aquila_shuttle_preflight_qdel

/// Przy starcie promu usuwa drugi przedmiot z tego samego kafelka
/obj/item/aq_test_shuttle_eater
	var/obj/item/victim

/obj/item/aq_test_shuttle_eater/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	QDEL_NULL(victim)

/datum/unit_test/aquila_shuttle_preflight_qdel/Run()
	var/turf/old_turf = run_loc_floor_bottom_left
	var/turf/new_turf = locate(old_turf.x + 2, old_turf.y, old_turf.z)
	var/obj/item/aq_test_shuttle_eater/eater = allocate(/obj/item/aq_test_shuttle_eater, old_turf)
	var/obj/item/victim = new /obj/item/pen(old_turf)
	eater.victim = victim
	var/obj/docking_port/mobile/port = allocate(/obj/docking_port/mobile, new_turf)
	var/list/old_turfs = list(old_turf)
	var/list/new_turfs = list(new_turf)
	var/result = port.preflight_check(old_turfs, new_turfs, list(), 0)
	TEST_ASSERT(QDELETED(victim), "The test atom did not delete its neighbour, so the case was not exercised")
	TEST_ASSERT(isnull(result), "preflight_check() returned [result] instead of null")
	// Bez kopii listy procka kończy się runtime'em przed zapisem trybu ruchu kafelka (zostaje null, nie NONE)
	TEST_ASSERT(!isnull(old_turfs[old_turf]), "The turf did not get its move mode, preflight_check() stopped on the deleted atom")

#undef TEST_ASSERT
