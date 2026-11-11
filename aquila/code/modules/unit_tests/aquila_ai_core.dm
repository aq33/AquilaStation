// AQUILA - AI core synced with BeeStation/BeeStation-Hornet: the existing AI users still work on the new controller
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// A monkey that hates someone next to it plans a target, then an attack, and a stun pauses its AI (COMSIG_MOB_INCAPACITATE_CHANGED hook)
/datum/unit_test/aquila_monkey_ai_after_sync

/datum/unit_test/aquila_monkey_ai_after_sync/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	TEST_ASSERT(istype(controller), "Monkey has no monkey AI")
	TEST_ASSERT(controller.able_to_run, "Healthy monkey cannot run its AI")
	// No clients in unit tests, so the z-level check keeps the AI off; plan by hand
	controller.retaliate(victim)
	TEST_ASSERT(controller.blackboard[BB_MONKEY_ENEMIES][victim] > 0, "Retaliation did not mark the attacker as an enemy")

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/set_target = GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_set_combat_target)
	TEST_ASSERT(controller.current_behaviors[set_target], "Monkey with an enemy did not plan to pick a combat target")
	controller.ProcessBehavior(1, set_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET], victim, "Monkey did not target its enemy")
	TEST_ASSERT(!controller.current_behaviors[set_target], "Instant targeting behaviour did not finish")

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/attack = GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_attack_mob)
	TEST_ASSERT(controller.current_behaviors[attack], "Monkey with a target did not plan an attack")
	TEST_ASSERT_EQUAL(controller.current_movement_target, victim, "Attack did not move the monkey towards the target")

	// Deleting the target clears the tracked blackboard key (no hard reference left behind)
	qdel(victim)
	TEST_ASSERT(isnull(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]), "Deleted target stayed in the blackboard")
	TEST_ASSERT(!(victim in controller.blackboard[BB_MONKEY_ENEMIES]), "Deleted target stayed on the enemy list")

	monkey.Paralyze(10 SECONDS)
	TEST_ASSERT(!controller.able_to_run, "Paralyzed monkey can still run its AI")
	monkey.SetParalyzed(0)
	TEST_ASSERT(controller.able_to_run, "Monkey did not get its AI back after the stun")

/// A haunted item plans to throw itself at its victim and the throw counts against the victim's haunt points
/datum/unit_test/aquila_haunted_item_attacks

/datum/unit_test/aquila_haunted_item_attacks/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, left)
	wrench.AddComponent(/datum/component/haunted_item)
	var/datum/ai_controller/haunted/controller = wrench.ai_controller
	TEST_ASSERT(istype(controller), "Item was not haunted")
	TEST_ASSERT(istype(controller.idle_behavior, /datum/idle_behavior/idle_ghost_item), "Haunted item has no idle teleport behaviour")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(left.x + 3, left.y, left.z))
	controller.add_hauntee(victim, 5)

	var/datum/ai_behavior/item_move_close_and_attack/haunted/throw_behavior = GET_AI_BEHAVIOR(/datum/ai_behavior/item_move_close_and_attack/haunted)
	// The subtree attacks with a 10% chance per second
	for(var/i in 1 to 200)
		controller.SelectBehaviors(1)
		if(controller.current_behaviors[throw_behavior])
			break
	TEST_ASSERT(controller.current_behaviors[throw_behavior], "Haunted item never planned to attack its victim")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HAUNT_TARGET], victim, "Haunted item targets someone else")
	TEST_ASSERT_EQUAL(controller.current_movement_target, victim, "Haunted item does not move towards its victim")

	controller.ProcessBehavior(1, throw_behavior)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HAUNTED_THROW_ATTEMPT_COUNT], 1, "Throw was not counted")
	controller.fail_behavior(throw_behavior)
	var/list/hauntee_list = controller.blackboard[BB_TO_HAUNT_LIST]
	TEST_ASSERT_EQUAL(hauntee_list[victim], 4, "Finished attack did not use up a haunt point")
	TEST_ASSERT(isnull(controller.blackboard[BB_HAUNT_TARGET]), "Finished attack kept its target")
	qdel(wrench.GetComponent(/datum/component/haunted_item))

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
