// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - an anchored window stays anchored in a singularity's pull below stage 5, a loose one is still pulled
/datum/unit_test/window_singularity_pull

/datum/unit_test/window_singularity_pull/Run()
	var/obj/structure/window/reinforced/fulltile/window = allocate(/obj/structure/window/reinforced/fulltile)
	window.singularity_pull(run_loc_floor_top_right, STAGE_FOUR)
	TEST_ASSERT(window.anchored, "a stage 4 singularity unanchored the window")
	TEST_ASSERT(window.loc == run_loc_floor_bottom_left, "a stage 4 singularity moved an anchored window")

	window.setAnchored(FALSE)
	window.singularity_pull(run_loc_floor_top_right, STAGE_FOUR)
	TEST_ASSERT(window.loc != run_loc_floor_bottom_left, "a stage 4 singularity did not pull a loose window")

#undef TEST_ASSERT
