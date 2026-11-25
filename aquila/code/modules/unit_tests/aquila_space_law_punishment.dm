// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - program PDA „Prawo kosmiczne” podpowiada tylko kary dostępne na okręcie: terminal GenPop, konsola gułagu
/// i netpod (cyfrowe wygnanie) liczą się, gdy stoją na poziomie okrętu (test szuka na poziomie swojego pokoju). Zasady podpowiedzi testuje Sentence.test.ts.
/datum/unit_test/aquila_space_law_punishment

/datum/unit_test/aquila_space_law_punishment/Run()
	var/datum/computer_file/program/space_law/program = new
	var/list/data = program.ui_static_data(null)
	var/list/facilities = data["facilities"]
	TEST_ASSERT(islist(facilities) && ("genpop" in facilities) && ("gulag" in facilities) && ("exile" in facilities), "The space law program doesn't send the facilities")
	TEST_ASSERT(data["max_fine"] == CONFIG_GET(number/maxfine), "The space law program doesn't send the fine limit from the config")
	allocate(/obj/machinery/genpop_interface, run_loc_floor_bottom_left)
	allocate(/obj/machinery/computer/prisoner/gulag_teleporter_computer, get_step(run_loc_floor_bottom_left, EAST))
	allocate(/obj/machinery/netpod, get_step(run_loc_floor_bottom_left, NORTH))
	facilities = get_space_law_facilities(list(run_loc_floor_bottom_left.z))
	TEST_ASSERT(facilities["genpop"], "A GenPop terminal on the ship isn't found")
	TEST_ASSERT(facilities["gulag"], "A gulag console on the ship isn't found")
	TEST_ASSERT(facilities["exile"], "A netpod on the ship isn't found")
	qdel(program)

#undef TEST_ASSERT
