#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - cel buntu liczy szefa skutego w brygu albo w areszcie rewolucji (revolution_capture.dm)
/datum/unit_test/aquila_rev_capture

/datum/unit_test/aquila_rev_capture/Run()
	TEST_ASSERT(GLOB.aquila_brig_areas[/area/security/brig], "Bryg nie liczy się jako bryg")
	TEST_ASSERT(GLOB.aquila_brig_areas[/area/security/prison], "Więzienie nie liczy się jako bryg")
	TEST_ASSERT(!GLOB.aquila_brig_areas[/area/bridge], "Mostek liczy się jako bryg")

	var/mob/living/carbon/human/head = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	head.mind_initialize()
	var/mob/living/carbon/human/rebel = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	rebel.mind_initialize()
	var/datum/objective/mutiny/objective = new
	objective.target = head.mind
	var/list/guards = list(rebel.mind)

	TEST_ASSERT(!objective.target_captured(), "Nieskuty szef liczy się jako pojmany")
	head.handcuffed = new /obj/item/restraints/handcuffs(head)
	head.update_handcuffed()
	TEST_ASSERT(objective.rev_custody(head, guards), "Skuty szef pod okiem rewolucjonisty nie jest w areszcie rewolucji")
	TEST_ASSERT(!objective.rev_custody(head, list()), "Skuty szef bez strażnika liczy się jako w areszcie rewolucji")

	rebel.Unconscious(10 SECONDS)
	TEST_ASSERT(!objective.rev_custody(head, guards), "Nieprzytomny rewolucjonista pilnuje aresztu")
	rebel.SetUnconscious(0)
	head.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT(objective.rev_custody(head, guards), "Strażnik obok w tym samym pomieszczeniu nie pilnuje aresztu")
	head.uncuff()
	TEST_ASSERT(!objective.target_captured(), "Rozkuty szef liczy się jako pojmany")
	qdel(objective)

#undef TEST_ASSERT
