// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - błąd generic_fire z auxmos (gaz bez paliwa mimo progu reakcji) to ostrzeżenie w logu, nie runtime:
/// w długim przebiegu testów pojawiał się losowo i psuł clean_run.lk
/datum/unit_test/aquila_auxmos_fire_warning

/datum/unit_test/aquila_auxmos_fire_warning/Run()
	var/runtimes_before = GLOB.total_runtimes
	stack_trace("Reacting\n\nCaused by:\n   0: calling rust side react in react_by_id\n   1: Gas has no fuel even though it passed fuel check!\n\nLocation:\n    src\\reaction\\citadel.rs:318:21")
	stack_trace("Reacting\n\nCaused by:\n   1: Gas has no oxidizer even though it passed oxidizer check!")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "The auxmos generic_fire error still counts as a runtime")

#undef TEST_ASSERT_EQUAL
