// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - once no map is loading, atoms are created as regular ones, so LateInitialize() runs right away
/// (a stuck map load state left every cable laid by a player without connections or power)
/datum/unit_test/atoms_init_state

/datum/unit_test/atoms_init_state/Run()
	TEST_ASSERT(!SSatoms.initialized_changed, "a map load is still running during the tests")
	TEST_ASSERT(SSatoms.initialized == INITIALIZATION_INNEW_REGULAR, "SSatoms.initialized is [SSatoms.initialized] instead of INITIALIZATION_INNEW_REGULAR outside of a map load")
	var/obj/structure/cable/left = allocate(/obj/structure/cable, run_loc_floor_bottom_left)
	var/obj/structure/cable/right = allocate(/obj/structure/cable, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(!(left in SSatoms.late_loaders), "a cable created at runtime waits in SSatoms.late_loaders")
	TEST_ASSERT(left.linked_dirs & EAST, "a cable created at runtime did not link to its neighbour")
	TEST_ASSERT(left.powernet && left.powernet == right.powernet, "cables created at runtime did not share a powernet")

#undef TEST_ASSERT
