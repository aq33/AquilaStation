// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every first aid kit fits its own contents (the radiation kit spawned up to 8 items into 7 slots)
/datum/unit_test/aquila_firstaid_fits_contents

/datum/unit_test/aquila_firstaid_fits_contents/Run()
	for(var/kit_type in typesof(/obj/item/storage/firstaid))
		// The random bonus pills differ between kits, so roll each kit a few times
		for(var/i in 1 to 10)
			var/obj/item/storage/firstaid/kit = allocate(kit_type)
			var/datum/component/storage/storage = kit.GetComponent(/datum/component/storage)
			TEST_ASSERT(storage, "[kit_type] has no storage component")
			TEST_ASSERT(length(kit.contents) <= storage.max_items, "[kit_type] spawned [length(kit.contents)] items into [storage.max_items] slots")
			qdel(kit)

/// AQUILA - a standing mob looking at the target is facing it; the helper had the lying check inverted, so mesmerize never worked on a standing victim
/datum/unit_test/aquila_source_facing_target

/datum/unit_test/aquila_source_facing_target/Run()
	var/mob/living/carbon/human/looker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	looker.setDir(EAST)
	TEST_ASSERT(is_source_facing_target(looker, target), "a standing mob looking east does not face the mob east of it")
	looker.setDir(WEST)
	TEST_ASSERT(!is_source_facing_target(looker, target), "a mob looking away still faces the target")
	looker.setDir(EAST)
	looker.Paralyze(10 SECONDS)
	looker.update_mobility()
	TEST_ASSERT(!is_source_facing_target(looker, target), "a lying mob still faces the target")

/// AQUILA - dragging a victim onto the vassal rack buckles it through the vampire path (the generic drag buckle skipped it, and buckle_mob() refused the victim on the next tile)
/datum/unit_test/aquila_vassalrack_attach

/datum/unit_test/aquila_vassalrack_attach/Run()
	var/obj/structure/vampire/vassalrack/rack = allocate(/obj/structure/vampire/vassalrack, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/vampire = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT(!rack.mouse_buckle_handling(victim, vampire), "the rack still takes the generic drag buckle")
	rack.convert_progress = 0
	rack.attach_victim(victim, vampire)
	TEST_ASSERT(victim.buckled == rack, "a victim on the next tile was not buckled to the rack")
	TEST_ASSERT(victim.loc == rack.loc, "the buckled victim was not moved onto the rack")
	TEST_ASSERT(rack.convert_progress == 3, "attaching a victim did not reset the torture progress")
	rack.unbuckle_mob(victim, TRUE)

/// AQUILA - a ceiling speaker is not hung on a wall that already holds a lift button
/datum/unit_test/aquila_ceiling_speaker_lift_button

/datum/unit_test/aquila_ceiling_speaker_lift_button/Run()
	var/turf/floor = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z)
	var/turf/north = get_step(floor, NORTH)
	var/turf/west = get_step(floor, WEST)
	var/turf/east = get_step(floor, EAST)
	var/north_type = north.type
	var/west_type = west.type
	var/east_type = east.type
	north.ChangeTurf(/turf/closed/wall)
	var/list/blocking = typecacheof(list(/obj/machinery/lazylift_button, /obj/machinery/turbolift_button))
	TEST_ASSERT(SSjukeboxes.ceiling_speaker_wall(floor, blocking) == NORTH, "an empty north wall was not chosen")
	var/obj/machinery/lazylift_button/button = allocate(/obj/machinery/lazylift_button, north)
	TEST_ASSERT(SSjukeboxes.ceiling_speaker_wall(floor, blocking) != NORTH, "the speaker was hung on the wall with the lift button")
	qdel(button)
	north.ChangeTurf(north_type)
	west.ChangeTurf(west_type)
	east.ChangeTurf(east_type)

#undef TEST_ASSERT
