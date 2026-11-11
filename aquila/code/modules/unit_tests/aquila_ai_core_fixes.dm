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

/// A2 + A6: an aggressive monkey attacks crew it shares the "neutral" faction with, and keeps a target 7 tiles away
/datum/unit_test/aquila_ai_aggressive_monkey

/datum/unit_test/aquila_ai_aggressive_monkey/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	TEST_ASSERT(!strategy.can_attack(monkey, victim, MONKEY_ENEMY_VISION), "A calm monkey wants to attack a crew member")

	controller.set_blackboard_key(BB_MONKEY_AGGRESSIVE, TRUE)
	TEST_ASSERT(strategy.can_attack(monkey, victim, MONKEY_ENEMY_VISION), "An aggressive monkey does not want to attack a crew member")
	controller.set_blackboard_key(BB_MONKEY_CURRENT_ATTACK_TARGET, victim)
	var/datum/ai_behavior/monkey_attack_mob/attack = GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_attack_mob)
	monkey.next_move = 0
	var/flags = attack.perform(1, controller, BB_MONKEY_CURRENT_ATTACK_TARGET)
	TEST_ASSERT(!(flags & AI_BEHAVIOR_SUCCEEDED), "The aggressive monkey gave up on its target instead of attacking")
	TEST_ASSERT(monkey.next_move > world.time, "The aggressive monkey did not attack")

	// A6: the target was picked from MONKEY_ENEMY_VISION, so the line of sight check must reach that far
	var/turf/far_left = locate(left.x, run_loc_floor_top_right.y + 3, left.z)
	var/turf/far_right = far_left && locate(left.x + 7, far_left.y, left.z)
	TEST_ASSERT(far_right, "No row of turfs above the test room")
	monkey.forceMove(far_left)
	victim.forceMove(far_right)
	TEST_ASSERT(strategy.can_attack(monkey, victim, MONKEY_ENEMY_VISION), "A monkey loses a target 7 tiles away in plain sight")
	var/datum/targeting_strategy/basic/basic_strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic)
	var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, far_left)
	TEST_ASSERT(basic_strategy.can_attack(bear, victim), "can_attack() without a range does not see as far as targets are picked")

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

/// A4: an idle monkey without an instrument does not queue an instrument search every plan, one with an instrument does
/datum/unit_test/aquila_ai_monkey_instrument_search

/datum/unit_test/aquila_ai_monkey_instrument_search/Run()
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, run_loc_floor_bottom_left)
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	controller.set_blackboard_key(BB_NEXT_HUNGRY, world.time + 10 MINUTES)
	var/datum/ai_behavior/search = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_hands)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[search], "A monkey without an instrument searches its hands for one")

	var/obj/item/instrument/violin/violin = allocate(/obj/item/instrument/violin, run_loc_floor_bottom_left)
	monkey.put_in_hands(violin)
	controller.CancelActions()
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[search], "A monkey with an instrument in hand does not pick it up to play")

/// A5 + A7: the press target of a monkey is never itself and is cleared when the press is done or dropped from the plan
/datum/unit_test/aquila_ai_monkey_press_target

/datum/unit_test/aquila_ai_monkey_press_target/Run()
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, run_loc_floor_bottom_left)
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	var/datum/ai_behavior/find_nearby/find = GET_AI_BEHAVIOR(/datum/ai_behavior/find_nearby)
	for(var/i in 1 to 200)
		find.perform(1, controller, BB_MONKEY_CURRENT_PRESS_TARGET)
		TEST_ASSERT(controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET] != monkey, "The monkey picked itself to press")
		controller.clear_blackboard_key(BB_MONKEY_CURRENT_PRESS_TARGET)

	var/turf/target_turf = get_step(run_loc_floor_bottom_left, EAST)
	controller.set_blackboard_key(BB_MONKEY_CURRENT_PRESS_TARGET, target_turf)
	controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
	var/datum/ai_behavior/use_on_object/use = GET_AI_BEHAVIOR(/datum/ai_behavior/use_on_object)
	TEST_ASSERT(controller.current_behaviors[use], "The press was not queued")
	// A plan without the press (A7: SelectBehaviors passes the stored arguments of the dropped behaviour)
	var/list/old_subtrees = controller.planning_subtrees
	controller.planning_subtrees = list()
	controller.SelectBehaviors(1)
	controller.planning_subtrees = old_subtrees
	TEST_ASSERT(!controller.current_behaviors[use], "The dropped press is still running")
	TEST_ASSERT(isnull(controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET]), "The dropped press kept its target")

/// A8: a human body run by an AI without a player is "not himself", even while its AI is off (stun, no clients)
/datum/unit_test/aquila_ai_examine_not_catatonic

/datum/unit_test/aquila_ai_examine_not_catatonic/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/examiner = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	body.ai_controller = new /datum/ai_controller/monkey(body)
	TEST_ASSERT(body.ai_controller.ai_status != AI_STATUS_ON, "The AI is on without clients, the test does not check the off case")
	var/text = jointext(body.examine(examiner), "")
	TEST_ASSERT(findtext(text, "Nie wydaje się być sobą"), "An AI body is not described as not being himself")
	TEST_ASSERT(!findtext(text, "katatonii"), "An AI body with its AI off is described as catatonic")

/// C5/E3: a controller goes idle without living clients nearby and wakes up when one comes close
/datum/unit_test/aquila_ai_idle_without_clients

/datum/unit_test/aquila_ai_idle_without_clients/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	var/turf/far_turf = locate(min(left.x + controller.interesting_dist + 5, world.maxx), left.y, left.z)
	var/mob/living/carbon/human/fake_client = allocate(/mob/living/carbon/human, far_turf)
	// No real clients in unit tests: put a mob in the client list of the z-level for the check, then take it out
	SSmobs.clients_by_zlevel[left.z] += fake_client
	var/far_distance = get_dist(far_turf, left)
	var/idle_far = controller.should_idle()
	var/status_far = controller.get_expected_ai_status()
	fake_client.forceMove(get_step(left, EAST))
	var/idle_near = controller.should_idle()
	var/status_near = controller.get_expected_ai_status()
	SSmobs.clients_by_zlevel[left.z] -= fake_client
	var/idle_none = controller.should_idle()
	controller.reset_ai_status()

	TEST_ASSERT(far_distance > controller.interesting_dist, "The far turf is not far enough ([far_distance])")
	TEST_ASSERT(idle_far, "A controller with the only client [far_distance] tiles away does not idle")
	TEST_ASSERT_EQUAL(status_far, AI_STATUS_IDLE, "A controller far from clients is not expected to idle")
	TEST_ASSERT(!idle_near, "A controller next to a client idles")
	TEST_ASSERT_EQUAL(status_near, AI_STATUS_ON, "A controller next to a client is not expected to run")
	TEST_ASSERT(idle_none, "A controller with no clients at all does not idle")

/// E1 + E4: IsReachableBy() answers the common cases without CanReach(), and an empty target search backs off until the
/// mob is attacked or finds a target
/datum/unit_test/aquila_ai_reach_and_search_backoff

/datum/unit_test/aquila_ai_reach_and_search_backoff/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	var/obj/item/wrench/held = allocate(/obj/item/wrench, left)
	monkey.put_in_hands(held)
	var/obj/item/wrench/adjacent = allocate(/obj/item/wrench, get_step(left, EAST))
	var/obj/item/wrench/far = allocate(/obj/item/wrench, get_step(get_step(left, EAST), EAST))
	var/obj/item/storage/box/box = allocate(/obj/item/storage/box, left)
	monkey.put_in_hands(box)
	var/obj/item/wrench/boxed = new(box)
	TEST_ASSERT(held.IsReachableBy(monkey), "The monkey cannot reach what it holds")
	TEST_ASSERT(adjacent.IsReachableBy(monkey), "The monkey cannot reach an item next to it")
	TEST_ASSERT(!far.IsReachableBy(monkey), "The monkey reaches an item two tiles away")
	TEST_ASSERT(far.IsReachableBy(monkey, 2), "A reach of 2 does not reach two tiles away")
	TEST_ASSERT(boxed.IsReachableBy(monkey), "The monkey cannot reach into the box it holds")
	qdel(monkey)

	var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, left)
	var/datum/ai_controller/controller = bear.ai_controller
	var/datum/ai_behavior/find_potential_targets/find = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	for(var/i in 1 to 5)
		find.perform(1, controller, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_FIND_TARGETS_EMPTY_SCANS], 5, "Empty target scans are not counted")
	TEST_ASSERT_EQUAL(find.get_cooldown(controller), FIND_TARGETS_MAX_BACKOFF, "Five empty scans did not back off to the longest wait")
	SEND_SIGNAL(bear, COMSIG_ATOM_WAS_ATTACKED, bear)
	TEST_ASSERT_EQUAL(find.get_cooldown(controller), find.action_cooldown, "An attack did not reset the target search")

	find.perform(1, controller, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_FIND_TARGETS_EMPTY_SCANS], 1, "The scan after the reset was not counted")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	find.perform(1, controller, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The bear did not find the human")
	TEST_ASSERT(isnull(controller.blackboard[BB_FIND_TARGETS_EMPTY_SCANS]), "Finding a target did not reset the backoff")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
