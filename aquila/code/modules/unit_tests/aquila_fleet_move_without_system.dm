// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - timer ruchu floty, która nie jest w żadnym układzie, nie wywołuje runtime'u (ai-skynet.dm: null.adjacency_list).
/// W CI pojawiało się to losowo w trakcie testu burzy portali
/datum/unit_test/aquila_fleet_move_without_system

/datum/unit_test/aquila_fleet_move_without_system/Run()
	var/datum/fleet/fleet = new
	fleet.can_reinforce = FALSE
	fleet.current_system = null
	fleet.goal_system = null
	var/runtimes_before = GLOB.total_runtimes
	fleet.move()
	var/runtimes_after = GLOB.total_runtimes
	qdel(fleet)
	TEST_ASSERT(runtimes_after == runtimes_before, "A fleet outside any star system runtimed when its move timer fired")

#undef TEST_ASSERT
