// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Bracia krwi są odmianą zdrajcy: dwóch chętnych zdrajców staje się parą braci, reszta zostaje zdrajcami
/datum/unit_test/aquila_traitor_brother_pair

/datum/unit_test/aquila_traitor_brother_pair/Run()
	var/datum/game_mode/traitor/mode = new
	var/datum/mind/first = new("bro_test_1")
	var/datum/mind/second = new("bro_test_2")
	var/datum/mind/loner = new("bro_test_3")
	mode.pre_traitors = list(first, second, loner)

	TEST_ASSERT(isnull(mode.pair_traitors_as_brothers(list(first))), "A pair was made out of a single willing traitor")
	TEST_ASSERT_EQUAL(length(mode.pre_traitors), 3, "A failed pairing took traitors away")

	var/datum/team/brother_team/team = mode.pair_traitors_as_brothers(list(first, second))
	TEST_ASSERT(team, "Two willing traitors did not become brothers")
	TEST_ASSERT_EQUAL(length(team.members), 2, "Wrong brother team size")
	TEST_ASSERT((first in team.members) && (second in team.members), "The brothers are not the willing traitors")
	TEST_ASSERT_EQUAL(length(mode.pre_traitors), 1, "The brothers stayed on the traitor list")
	TEST_ASSERT(loner in mode.pre_traitors, "The unwilling traitor lost the traitor role")
	TEST_ASSERT_EQUAL(first.special_role, "brother", "Wrong special role of a brother")
	TEST_ASSERT(JOB_NAME_AI in first.restricted_roles, "A blood brother can still be picked as the AI")
	TEST_ASSERT(!(JOB_NAME_AI in mode.restricted_jobs), "Restricting the brother changed the traitor mode's own job list")
	TEST_ASSERT(team in mode.pre_traitor_brother_teams, "The team does not get its antag datums in post_setup")

	var/list/pool_config = CONFIG_GET(keyed_list/weighted_pool)
	TEST_ASSERT(!("traitorbro" in pool_config), "The blood brothers mode is still in the weighted rotation")

	QDEL_LIST(mode.pre_traitor_brother_teams)
	qdel(mode)
	qdel(first)
	qdel(second)
	qdel(loner)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
