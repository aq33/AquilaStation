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
	TEST_ASSERT(copy.aq_other_level_text(hole) == "piętro niżej", "The screentip of the copy does not say it is one deck below: [copy.aq_other_level_text(hole)]")

	// An overlay on the game plane moves to the copy's own plane, otherwise it is drawn sharp on the deck above
	var/mutable_appearance/game_overlay = mutable_appearance(thing.icon, thing.icon_state, plane = GAME_PLANE)
	thing.overlays += game_overlay
	thing.update_above()
	SSzcopy.fire(FALSE, TRUE)
	for(var/image/overlay as anything in copy.overlays)
		TEST_ASSERT(overlay.plane != GAME_PLANE, "An overlay of the copy stayed on the game plane of the deck above")

	// Off the open space (here: a level with nothing above) the copy goes at once, not onto an unrelated level
	thing.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(QDELETED(copy), "The copy stayed after its thing left the deck below the open space: [copy.loc]")

	// Every mimic plane and the shadow plane have a plane master (blur and darkening of the deck below)
	var/list/planes = list()
	for(var/atom/movable/screen/plane_master/master_type as anything in subtypesof(/atom/movable/screen/plane_master))
		planes["[initial(master_type.plane)]"] = master_type
	for(var/depth in 0 to ZMIMIC_MAX_DEPTH)
		TEST_ASSERT(planes["[ZMIMIC_MAX_PLANE - depth]"], "Mimic plane [ZMIMIC_MAX_PLANE - depth] has no plane master")
	TEST_ASSERT(planes["[ZMIMIC_SHADOW_PLANE]"], "The mimic shadow plane has no plane master")
	TEST_ASSERT(planes["[ZMIMIC_DEEP_SHADOW_PLANE]"], "The deep shadow plane has no plane master")

/// AQUILA: changing the turf under a glass floor (a Z-turf that keeps its own icon) leaves one copy of it, not two
/datum/unit_test/aquila_zmimic_glass_proxy

/datum/unit_test/aquila_zmimic_glass_proxy/Run()
	var/turf/open/floor/glass/glass
	for(var/turf/open/floor/glass/candidate in world)
		if(candidate.below && !(candidate.below.z_flags & Z_MIMIC_BELOW))
			glass = candidate
			break
	if(!glass)
		return // Mapa testów nie ma szklanej podłogi nad zwykłym kaflem
	SSzcopy.fire(FALSE, TRUE)
	var/turf/under = glass.below
	under.ChangeTurf(under.type, flags = CHANGETURF_FORCEOP)
	SSzcopy.fire(FALSE, TRUE)
	var/proxies = 0
	for(var/atom/movable/openspace/turf_proxy/proxy in glass)
		if(proxy != glass.mimic_underlay)
			proxies++
	TEST_ASSERT(proxies == 1, "The glass floor shows [proxies] copies of the turf below after it changed")

#undef TEST_ASSERT
