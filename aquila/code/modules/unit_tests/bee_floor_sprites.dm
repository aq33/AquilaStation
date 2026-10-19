// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - floors moved to the Bee floors.dmi keep sprites that exist there, also when broken or burnt;
/// a missing state showed the missing texture checkerboard
/datum/unit_test/bee_floor_sprites

/datum/unit_test/bee_floor_sprites/Run()
	var/turf/test_turf = run_loc_floor_bottom_left
	var/original_type = test_turf.type
	for(var/floor_type in typesof(/turf/open/floor/durasteel) + /turf/open/floor/grass/fakebasalt)
		var/turf/open/floor/floor = test_turf.ChangeTurf(floor_type)
		TEST_ASSERT(icon_exists(floor.icon, floor.icon_state), "[floor_type] uses missing sprite \"[floor.icon_state]\" in [floor.icon]")
		for(var/state in floor.broken_states + floor.burnt_states)
			TEST_ASSERT(icon_exists(floor.icon, state), "[floor_type] has missing damage sprite \"[state]\" in [floor.icon]")
		test_turf = floor
	test_turf.ChangeTurf(original_type)

#undef TEST_ASSERT
