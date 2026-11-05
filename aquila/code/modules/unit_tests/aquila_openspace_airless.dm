// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - openspace/airless nie łączy się atmosem z kaflem pod spodem, liczone z obu stron.
/// Na pokładzie testowym nie ma pokładu niżej (openspace zamienia się tam w kosmos), więc test bierze parę kafli z mapy statku.
/datum/unit_test/aquila_openspace_airless

/datum/unit_test/aquila_openspace_airless/Run()
	var/turf/open/openspace/airless/vacuum
	var/turf/open/floor
	for(var/turf/open/openspace/airless/candidate in world)
		var/turf/open/below = candidate.below()
		if(istype(below) && !below.blocks_air && !istype(below, /turf/open/space) && !istype(below, /turf/open/openspace))
			vacuum = candidate
			floor = below
			break
	if(!vacuum)
		log_world("aquila_openspace_airless: na mapie nie ma openspace/airless nad podłogą, test pominięty")
		return

	TEST_ASSERT(!vacuum.CanAtmosPass(floor, TRUE), "openspace/airless lets air fall to the floor below")
	TEST_ASSERT(!floor.CanAtmosPass(vacuum, TRUE), "floor below lets air rise into openspace/airless")

	// Kafel pod spodem przelicza sąsiedztwo ostatni (np. po otwarciu drzwi) i nie może odnowić połączenia
	vacuum.ImmediateCalculateAdjacentTurfs()
	floor.ImmediateCalculateAdjacentTurfs()
	TEST_ASSERT(!(floor in vacuum.atmos_adjacent_turfs), "openspace/airless is atmos-adjacent to the floor below")
	TEST_ASSERT(!(vacuum in floor.atmos_adjacent_turfs), "floor below is atmos-adjacent to openspace/airless")

#undef TEST_ASSERT
