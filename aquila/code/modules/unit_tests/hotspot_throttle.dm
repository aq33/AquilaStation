// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Hotspots burn their tile and smoke only every few ticks
/datum/unit_test/hotspot_throttle

/datum/unit_test/hotspot_throttle/Run()
	var/turf/open/location = run_loc_floor_bottom_left
	// Earlier tests may have left smoke around
	QDEL_NULL(location.pollution)

	var/obj/effect/hotspot/hotspot = allocate(/obj/effect/hotspot, location)
	TEST_ASSERT(!QDELETED(hotspot), "The hotspot did not survive Initialize()")
	TEST_ASSERT(hotspot.exposure_count == 1, "Initialize() did not do the first exposure (count [hotspot.exposure_count])")
	TEST_ASSERT(location.pollution?.pollutants[/datum/pollutant/smoke] > 0, "The first exposure did not smoke")

	var/burns = 0
	for(var/i in 1 to HOTSPOT_SMOKE_INTERVAL * HOTSPOT_CONTENTS_INTERVAL)
		if(hotspot.throttled_exposure(location))
			burns++
	TEST_ASSERT(burns == HOTSPOT_SMOKE_INTERVAL, "The hotspot burned its tile [burns] times in [HOTSPOT_SMOKE_INTERVAL * HOTSPOT_CONTENTS_INTERVAL] ticks instead of [HOTSPOT_SMOKE_INTERVAL]")

	QDEL_NULL(location.pollution)

#undef TEST_ASSERT
