// AQUILA - basic mining mobs from tg (hivelord, legion, goliath, watcher, basilisk, goldgrub, gutlunch): the abilities are
// used by the AI through the controller, the ranged attacks hit, the loot drops on death.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// A turf `dx` tiles east of the corner, kept inside the test room
/proc/aquila_mining_test_turf(turf/corner, turf/top_right, dx, dy = 0)
	return locate(min(corner.x + dx, top_right.x), min(corner.y + dy, top_right.y), corner.z)

/// Waits until the proc returns something or the time runs out (spawn animations, projectiles)
/proc/aquila_mining_wait(datum/callback/check, time = 2 SECONDS)
	var/wait_until = world.time + time
	. = check.Invoke()
	while(!. && world.time < wait_until)
		sleep(1)
		. = check.Invoke()

/// Finds a mob of the type around a turf
/proc/aquila_mining_find(type, turf/center, range = 1)
	for(var/mob/living/found in range(range, center))
		if(istype(found, type) && found.stat != DEAD)
			return found

/// Gives the AI its target and plans once; returns the controller
/proc/aquila_mining_find_target(mob/living/pawn)
	var/datum/ai_controller/controller = pawn.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	return controller

/// Runs the melee behaviour of a basic mob until it attacks once (the first call only starts the attack delay)
/proc/aquila_mining_melee(mob/living/basic/pawn)
	var/datum/ai_controller/controller = pawn.ai_controller
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	pawn.next_move = 0
	pawn.next_click = 0
	controller.ProcessBehavior(1, melee)

/// The hivelord keeps its distance and spawns brood at its target through the AI, the brood bites, the hivelord drops
/// its regenerative core and three brood when it dies
/datum/unit_test/aquila_mining_hivelord

/datum/unit_test/aquila_mining_hivelord/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/mining/hivelord/hivelord = allocate(/mob/living/basic/mining/hivelord, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, aquila_mining_test_turf(corner, run_loc_floor_top_right, 3))
	var/datum/ai_controller/controller = aquila_mining_find_target(hivelord)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The hivelord did not pick the human three tiles away")

	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[use_ability], "The hivelord with a target did not plan to spawn brood")
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/step_away)], "The hivelord did not plan to keep its distance from a target too close")
	controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT(hivelord.spawn_brood.next_use_time > world.time, "Spawning brood did not start its cooldown")
	var/mob/living/basic/hivelord_brood/brood = aquila_mining_wait(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_mining_find), /mob/living/basic/hivelord_brood, get_turf(hivelord)))
	TEST_ASSERT(brood, "The brood ability made no brood next to the hivelord")
	TEST_ASSERT_EQUAL(brood.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The brood did not get the hivelord's target")
	TEST_ASSERT("mining" in brood.faction, "The brood is not in the hivelord's faction")

	brood.forceMove(get_step(victim, WEST))
	brood.ai_controller.SelectBehaviors(1)
	var/brute_before = victim.getBruteLoss()
	aquila_mining_melee(brood)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The brood did not bite its target through its AI")
	qdel(brood)

	controller.CancelActions()
	hivelord.death()
	var/obj/item/organ/regenerative_core/core = locate() in corner
	TEST_ASSERT(core, "The dead hivelord dropped no regenerative core")
	qdel(core)
	TEST_ASSERT(aquila_mining_wait(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_mining_find), /mob/living/basic/hivelord_brood, corner)), "The dying hivelord released no brood")
	for(var/mob/living/basic/hivelord_brood/leftover in range(2, corner))
		qdel(leftover)

/// The legion launches a skull at its target through the AI; the skull infests a dying human, which makes a legion
/// holding the body; that legion drops the body and its core when it dies
/datum/unit_test/aquila_mining_legion

/datum/unit_test/aquila_mining_legion/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/mining/legion/legion = allocate(/mob/living/basic/mining/legion, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, aquila_mining_test_turf(corner, run_loc_floor_top_right, 4))
	var/datum/ai_controller/controller = aquila_mining_find_target(legion)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The legion did not pick the human four tiles away")

	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[use_ability], "The legion with a target did not plan to launch a skull")
	controller.ProcessBehavior(1, use_ability)
	var/mob/living/basic/mining/legion_brood/skull = aquila_mining_wait(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_mining_find), /mob/living/basic/mining/legion_brood, get_turf(victim)))
	TEST_ASSERT(skull, "The launched skull did not land next to the target")
	TEST_ASSERT_EQUAL(skull.created_by?.resolve(), legion, "The skull does not know the legion that launched it")
	TEST_ASSERT_EQUAL(skull.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The skull did not get the legion's target")
	controller.CancelActions()

	// A dying human gets infested by the skull's AI
	victim.Unconscious(1 MINUTES, TRUE, TRUE)
	TEST_ASSERT(victim.stat > SOFT_CRIT, "Could not knock the test human out")
	skull.forceMove(get_step(victim, WEST))
	skull.ai_controller.SelectBehaviors(1)
	aquila_mining_melee(skull)
	var/mob/living/basic/mining/legion/host = aquila_mining_wait(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_mining_holder_of), victim))
	TEST_ASSERT(istype(host), "The skull did not turn the dying human into a legion")
	TEST_ASSERT_EQUAL(victim.stat, DEAD, "The infested human is not dead")
	TEST_ASSERT_EQUAL(host.stored_mob, victim, "The new legion does not hold the body")

	var/turf/host_turf = get_turf(host)
	host.death()
	TEST_ASSERT_EQUAL(victim.loc, host_turf, "The dead legion did not drop the body")
	var/obj/item/organ/regenerative_core/legion/core = locate() in host_turf
	TEST_ASSERT(core, "The dead legion dropped no legion core")
	qdel(core)
	var/humans_around = 0
	for(var/mob/living/carbon/human/body in range(1, host_turf))
		humans_around++
	TEST_ASSERT_EQUAL(humans_around, 1, "A legion holding a body also left a corpse")

/// The legion holding this body, if any
/proc/aquila_mining_holder_of(mob/living/victim)
	return istype(victim.loc, /mob/living/basic/mining/legion) ? victim.loc : null

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
