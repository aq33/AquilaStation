// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA: Z-Mimic copies a thing from the deck below onto the open space above it, on a mimic plane (blurred by its
/// plane master), and drops the copy when the thing leaves. The default test map (Atlas) has open space above the hangar.
/datum/unit_test/aquila_zmimic

/datum/unit_test/aquila_zmimic/Run()
	var/turf/open/openspace/hole
	var/turf/open/floor
	for(var/turf/open/openspace/airless/candidate in world)
		var/turf/open/below_turf = GET_TURF_BELOW(candidate)
		if(istype(below_turf) && !isspaceturf(below_turf) && !istype(below_turf, /turf/open/openspace))
			hole = candidate
			floor = below_turf
			break
	TEST_ASSERT(hole, "No open space above a floor on the test map, nothing to check")

	TEST_ASSERT(TURF_IS_MIMICKING(hole), "Open space does not mimic the deck below")
	TEST_ASSERT(hole.shadower, "Open space has no shadower (copy of the light below)")
	TEST_ASSERT(hole.below == floor && floor.above == hole, "Open space is not linked with the turf below: [hole.below] / [floor.above]")
	SSzcopy.fire(FALSE, TRUE)
	TEST_ASSERT(hole.plane <= ZMIMIC_MAX_PLANE && hole.plane >= ZMIMIC_MAX_PLANE - ZMIMIC_MAX_DEPTH, "Open space shows the floor below on plane [hole.plane], not on a mimic plane")

	var/obj/item/wrench/thing = allocate(/obj/item/wrench, floor)
	SSzcopy.fire(FALSE, TRUE)
	var/atom/movable/openspace/mimic/copy = thing.bound_overlay
	TEST_ASSERT(copy, "A thing on the deck below has no copy on the open space above")
	TEST_ASSERT(copy.loc == hole, "The copy is not on the open space above the thing: [copy.loc]")
	TEST_ASSERT(copy.plane <= ZMIMIC_MAX_PLANE && copy.plane >= ZMIMIC_MAX_PLANE - ZMIMIC_MAX_DEPTH, "The copy is on plane [copy.plane], not on a mimic plane")
	TEST_ASSERT(copy.icon_state == thing.icon_state, "The copy does not look like the thing")

	// The copy follows its thing; off the open space it is dropped
	thing.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(QDELETED(copy) || copy.destruction_timer, "The copy stayed after its thing left the deck below the open space")

	// Every mimic plane and the shadow plane have a plane master (blur and darkening of the deck below)
	var/list/planes = list()
	for(var/atom/movable/screen/plane_master/master_type as anything in subtypesof(/atom/movable/screen/plane_master))
		planes["[initial(master_type.plane)]"] = master_type
	for(var/depth in 0 to ZMIMIC_MAX_DEPTH)
		TEST_ASSERT(planes["[ZMIMIC_MAX_PLANE - depth]"], "Mimic plane [ZMIMIC_MAX_PLANE - depth] has no plane master")
	TEST_ASSERT(planes["[ZMIMIC_SHADOW_PLANE]"], "The mimic shadow plane has no plane master")

#undef TEST_ASSERT
