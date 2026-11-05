// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - odświeżanie monitora z panelu czatu zamienia się na FPS klienta, a śmieciowe pomiary są odrzucane
/datum/unit_test/monitor_refresh_fps

/datum/unit_test/monitor_refresh_fps/Run()
	TEST_ASSERT(monitor_refresh_to_fps(144) == 144, "144 Hz did not give 144 FPS")
	TEST_ASSERT(monitor_refresh_to_fps("60") == 60, "Text payload 60 did not give 60 FPS")
	TEST_ASSERT(monitor_refresh_to_fps(143.6) == 144, "143.6 Hz was not rounded to 144 FPS")
	TEST_ASSERT(monitor_refresh_to_fps(360) == 240, "360 Hz was not capped at the preference maximum of 240")
	TEST_ASSERT(isnull(monitor_refresh_to_fps(5)), "A throttled 5 Hz measurement was accepted")
	TEST_ASSERT(isnull(monitor_refresh_to_fps("abc")), "A non-numeric payload was accepted")
	TEST_ASSERT(isnull(monitor_refresh_to_fps(null)), "A missing payload was accepted")

#undef TEST_ASSERT
