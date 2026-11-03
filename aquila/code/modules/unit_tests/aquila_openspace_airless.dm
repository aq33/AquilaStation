// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - openspace/airless nie wysysa powietrza z kafla pod spodem, zwykły openspace dalej przepuszcza
/datum/unit_test/aquila_openspace_airless

/datum/unit_test/aquila_openspace_airless/Run()
	var/turf/test_turf = run_loc_floor_bottom_left
	var/original_type = test_turf.type
	var/turf/open/openspace/airless/vacuum = test_turf.ChangeTurf(/turf/open/openspace/airless)
	var/vacuum_from_below = vacuum.zAirIn(UP)
	var/vacuum_from_above = vacuum.zAirIn(DOWN)
	var/vacuum_out_down = vacuum.zAirOut(DOWN)
	var/turf/open/openspace/hole = vacuum.ChangeTurf(/turf/open/openspace)
	var/hole_from_below = hole.zAirIn(UP)
	hole.ChangeTurf(original_type)

	TEST_ASSERT(!vacuum_from_below, "openspace/airless accepts air rising from below")
	TEST_ASSERT(vacuum_from_above, "openspace/airless rejects air falling from above")
	TEST_ASSERT(vacuum_out_down, "openspace/airless no longer lets air fall through")
	TEST_ASSERT(hole_from_below, "plain openspace stopped accepting air from below")

#undef TEST_ASSERT
