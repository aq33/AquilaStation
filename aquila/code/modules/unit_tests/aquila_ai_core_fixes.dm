// AQUILA - regression tests for the AI core review of aq33/AquilaStation#613 (monkeys, controllers, AI performance)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// K2: resisting out of a welded locker runs its 2 minute do_after asynchronously instead of stalling SSai_behaviors,
/// an unwelded locker opens at once, and a pet in a pet carrier waits instead of resisting
/datum/unit_test/aquila_ai_resist_async

/datum/unit_test/aquila_ai_resist_async/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/datum/ai_behavior/resist/resist = GET_AI_BEHAVIOR(/datum/ai_behavior/resist)

	var/obj/structure/closet/welded_closet = allocate(/obj/structure/closet, left)
	var/mob/living/basic/pet/cat/trapped_cat = allocate(/mob/living/basic/pet/cat, left)
	welded_closet.open() // lockers start closed
	welded_closet.close()
	welded_closet.welded = TRUE
	TEST_ASSERT_EQUAL(trapped_cat.loc, welded_closet, "The cat is not in the locker")
	var/datum/ai_controller/trapped_controller = trapped_cat.ai_controller
	var/started_at = world.time
	var/flags = resist.perform(1, trapped_controller)
	TEST_ASSERT_EQUAL(world.time, started_at, "Resisting out of a welded locker slept inside the AI behaviour")
	TEST_ASSERT(!(flags & AI_BEHAVIOR_SUCCEEDED), "The resist finished before the breakout")
	TEST_ASSERT_EQUAL(trapped_controller.blackboard[BB_RESIST_STATE], AI_RESIST_RUNNING, "The running resist is not tracked")
	flags = resist.perform(1, trapped_controller)
	TEST_ASSERT(!(flags & AI_BEHAVIOR_SUCCEEDED), "A second perform did not wait for the running resist")

	var/turf/right = get_step(left, EAST)
	var/obj/structure/closet/closet = allocate(/obj/structure/closet, right)
	var/mob/living/basic/pet/cat/cat = allocate(/mob/living/basic/pet/cat, right)
	closet.open()
	closet.close()
	TEST_ASSERT_EQUAL(cat.loc, closet, "The second cat is not in the locker")
	var/datum/ai_controller/controller = cat.ai_controller
	flags = resist.perform(1, controller)
	TEST_ASSERT(flags & AI_BEHAVIOR_SUCCEEDED, "Resisting out of a plain locker did not finish at once")
	TEST_ASSERT(closet.opened, "Resisting did not open the plain locker")
	TEST_ASSERT(isnull(controller.blackboard[BB_RESIST_STATE]), "A finished resist left its state behind")

	var/obj/item/pet_carrier/carrier = allocate(/obj/item/pet_carrier, left)
	var/mob/living/basic/pet/cat/carried_cat = allocate(/mob/living/basic/pet/cat, left)
	carrier.add_occupant(carried_cat)
	TEST_ASSERT_EQUAL(carried_cat.loc, carrier, "The cat is not in the carrier")
	var/datum/ai_controller/carried_controller = carried_cat.ai_controller
	var/datum/ai_planning_subtree/escape = GLOB.ai_subtrees[/datum/ai_planning_subtree/escape_captivity/pacifist]
	escape.SelectBehaviors(carried_controller, 1)
	TEST_ASSERT(!carried_controller.current_behaviors[resist], "A cat in a pet carrier tries to resist out of it")

/// A1: a pawn moved to another z-level with Move() (stairs, falling) follows into that z-level's controller list, and a
/// deleted pawn leaves the list it is really in
/datum/unit_test/aquila_ai_z_level_move

/datum/unit_test/aquila_ai_z_level_move/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	var/datum/ai_controller/controller = monkey.ai_controller
	TEST_ASSERT_EQUAL(controller.registered_z, left.z, "The controller is not registered on the monkey's z-level")
	TEST_ASSERT(controller in GLOB.ai_controllers_by_zlevel[left.z], "The controller is not in its z-level list")

	var/turf/destination
	for(var/z_level in 1 to world.maxz)
		if(z_level == left.z)
			continue
		var/turf/candidate = locate(left.x, left.y, z_level)
		if(candidate && !candidate.density && monkey.Move(candidate))
			destination = candidate
			break
	TEST_ASSERT(destination, "Found no turf on another z-level to Move() the monkey to")
	TEST_ASSERT_EQUAL(controller.registered_z, destination.z, "Move() to another z-level did not update the controller")
	TEST_ASSERT(controller in GLOB.ai_controllers_by_zlevel[destination.z], "The controller is not in the new z-level list")
	TEST_ASSERT(!(controller in GLOB.ai_controllers_by_zlevel[left.z]), "The controller stayed in the old z-level list")

	var/old_z = destination.z
	qdel(monkey)
	TEST_ASSERT(!(controller in GLOB.ai_controllers_by_zlevel[old_z]), "A deleted monkey's controller stayed in the z-level list")

/// A3 + E5: the AI of a stunned monkey that gets cuffed comes back when the stun ends (monkeys ignore cuffs), a cuffed
/// monkey that dies turns its AI off, and mobs without an AI do not track any of it
/datum/unit_test/aquila_ai_incapacitation_signal

/datum/unit_test/aquila_ai_incapacitation_signal/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	monkey.Paralyze(10 SECONDS)
	TEST_ASSERT(!controller.able_to_run, "Paralyzed monkey can still run its AI")
	monkey.handcuffed = new /obj/item/restraints/handcuffs(monkey)
	monkey.update_handcuffed()
	monkey.SetParalyzed(0)
	TEST_ASSERT(controller.able_to_run, "A cuffed monkey did not get its AI back after the stun")

	monkey.death()
	TEST_ASSERT(!controller.able_to_run, "A dead cuffed monkey can still run its AI")

	var/mob/living/carbon/human/no_ai = allocate(/mob/living/carbon/human, get_step(left, EAST))
	no_ai.Paralyze(1 SECONDS)
	TEST_ASSERT(isnull(no_ai.last_incapacitated_for_ai), "A mob without an AI tracks the AI incapacitation state")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
