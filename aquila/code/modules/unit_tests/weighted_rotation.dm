// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - weighted rotation: pool chances follow the survey tilt, and empty pools get nothing
/datum/unit_test/aquila_weighted_pool_odds

/datum/unit_test/aquila_weighted_pool_odds/Run()
	var/datum/weighted_rotation/rotation = new
	var/list/all_pools = list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_MEDIUM, WEIGHTED_POOL_HIGH)

	rotation.bias = 0
	var/list/odds = rotation.pool_odds(all_pools)
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 33, "Neutral low pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_MEDIUM], 33, "Neutral medium pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_HIGH], 33, "Neutral high pool")

	rotation.bias = 1
	odds = rotation.pool_odds(all_pools)
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 4, "Chaos-hungry low pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_HIGH], 76, "Chaos-hungry high pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_MEDIUM], 20, "Chaos-hungry medium pool")

	rotation.bias = -1
	odds = rotation.pool_odds(all_pools)
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 76, "Calm-seeking low pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_HIGH], 4, "Calm-seeking high pool")

	rotation.bias = 0
	odds = rotation.pool_odds(list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_HIGH))
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_MEDIUM], 0, "An empty pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 50, "Low pool next to an empty one")

	qdel(rotation)

/// AQUILA - weighted rotation: the antagonist limit only lowers amounts, and only when it is set
/datum/unit_test/aquila_weighted_antag_cap

/datum/unit_test/aquila_weighted_antag_cap/Run()
	var/datum/game_mode/traitor/mode = new
	TEST_ASSERT_EQUAL(mode.weighted_cap(5), 5, "No limit")
	mode.weighted_antag_cap = 2
	TEST_ASSERT_EQUAL(mode.weighted_cap(5), 2, "Limit of 2")
	TEST_ASSERT_EQUAL(mode.weighted_cap(1), 1, "Under the limit")
	mode.weighted_antag_cap = 0
	TEST_ASSERT_EQUAL(mode.weighted_cap(3), 0, "Used up limit")
	qdel(mode)

/// AQUILA - maps without xeno_spawn/blobstart get safe station turfs instead
/datum/unit_test/aquila_fallback_spawn_turfs

/datum/unit_test/aquila_fallback_spawn_turfs/Run()
	var/list/turfs = aquila_fallback_spawn_turfs(5)
	TEST_ASSERT(length(turfs), "No fallback spawn turf found on the station")
	TEST_ASSERT(length(turfs) <= 5, "More fallback turfs than asked for")
	for(var/turf/T as anything in turfs)
		TEST_ASSERT(is_station_level(T.z), "Fallback turf [AREACOORD(T)] is not on the station")
		TEST_ASSERT(is_turf_safe(T), "Fallback turf [AREACOORD(T)] is not safe")

/// AQUILA - weighted rotation: each ghost antagonist sits in the pool the players asked for, and only in one list
/datum/unit_test/aquila_weighted_midround_pools

/datum/unit_test/aquila_weighted_midround_pools/Run()
	var/datum/weighted_ghost_midround/midround = new
	var/list/common = midround.common_events()
	var/list/medium = midround.medium_events()
	var/list/heavy = midround.heavy_events()
	for(var/event_type in list(
		/datum/round_event_control/alien_infestation,
		/datum/round_event_control/blood_worm,
		/datum/round_event_control/infiltrators,
		/datum/round_event_control/pirates,
		/datum/round_event_control/sentient_disease,
		/datum/round_event_control/sinfuldemon,
		/datum/round_event_control/spider_infestation,
	))
		TEST_ASSERT(event_type in medium, "[event_type] is not in the medium pool")
	TEST_ASSERT(/datum/round_event_control/spawn_swarmer in heavy, "Swarmers are not in the heavy pool")
	for(var/event_type in common)
		TEST_ASSERT(!(event_type in medium) && !(event_type in heavy), "[event_type] is in more than one pool")
	for(var/event_type in medium)
		TEST_ASSERT(!(event_type in heavy), "[event_type] is in the medium and the heavy pool")

	// Czarodziej midround ma ten sam próg co na starcie rundy (MIN_POP WIZARD)
	var/wizard_min_pop = CONFIG_GET(keyed_list/min_pop)["wizard"]
	TEST_ASSERT(wizard_min_pop, "MIN_POP WIZARD is missing from the config, the midround wizard would fall back to the mode default")
	TEST_ASSERT(!midround.enough_players_for_wizard(wizard_min_pop - 1), "The midround wizard is offered under MIN_POP WIZARD")
	TEST_ASSERT(midround.enough_players_for_wizard(wizard_min_pop), "The midround wizard is not offered at MIN_POP WIZARD")
	qdel(midround)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
