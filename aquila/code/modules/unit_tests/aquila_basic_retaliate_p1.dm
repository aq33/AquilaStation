// AQUILA - Wojtek and the ghost as basic mobs (mobabilities part 2): retaliation through ai_retaliate instead of the
// hand-made attacker tracking of the simple animals
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Wojtek leaves the crew alone, goes only for the crewman who hit him and still takes beer from a friend
/datum/unit_test/aquila_wojtek_retaliates_on_crew

/datum/unit_test/aquila_wojtek_retaliates_on_crew/Run()
	var/mob/living/basic/bear/wojtek/wojtek = allocate(/mob/living/basic/bear/wojtek, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/friend = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/basic/ghost/stranger = allocate(/mob/living/basic/ghost, get_step(run_loc_floor_bottom_left, NORTHEAST))
	var/datum/ai_controller/controller = wojtek.ai_controller

	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	controller.SelectBehaviors(1)
	TEST_ASSERT(isnull(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)]), "Wojtek looks for prey on his own")
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "Wojtek attacks without being hit ([controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]])")

	puncher.set_combat_mode(TRUE)
	wojtek.attack_hand(puncher)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "Wojtek did not go for the crewman who hit him")

	var/datum/ai_behavior/basic_melee_attack/attack = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[attack], "Wojtek with a target did not plan a melee attack")
	controller.ProcessBehavior(1, attack)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	wojtek.next_move = 0
	var/health_before = puncher.health
	controller.ProcessBehavior(1, attack)
	TEST_ASSERT(puncher.health < health_before, "Wojtek's swipe did not hurt the one who hit him")

	wojtek.adjustBruteLoss(30)
	var/obj/item/reagent_containers/food/drinks/beer/beer = allocate(/obj/item/reagent_containers/food/drinks/beer)
	friend.put_in_active_hand(beer)
	var/hurt = wojtek.health
	wojtek.attackby(beer, friend)
	TEST_ASSERT(wojtek.health > hurt, "Wojtek did not drink the beer")
	TEST_ASSERT(!beer.reagents.total_volume, "The beer was not drunk")
	TEST_ASSERT(!(friend in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]), "Giving Wojtek a beer made him angry")
	TEST_ASSERT(!(stranger in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]), "Wojtek holds a grudge against a ghost that did nothing")

/// The ghost flies, hits back whoever hit it and turns into ectoplasm on death
/datum/unit_test/aquila_ghost_retaliates_and_vanishes

/datum/unit_test/aquila_ghost_retaliates_and_vanishes/Run()
	var/mob/living/basic/ghost/ghost = allocate(/mob/living/basic/ghost, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = ghost.ai_controller
	TEST_ASSERT(ghost.movement_type & FLYING, "The ghost does not fly")
	TEST_ASSERT(findtext(ghost.name, "duch: ") == 1, "The ghost got no random Polish name ([ghost.name])")

	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The ghost attacks without being hit")
	puncher.set_combat_mode(TRUE)
	ghost.attack_hand(puncher)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "The ghost did not go for the one who hit it")

	var/turf/ghost_turf = get_turf(ghost)
	ghost.death()
	TEST_ASSERT(QDELETED(ghost), "The dead ghost did not vanish")
	var/obj/item/ectoplasm/ectoplasm = locate() in ghost_turf
	TEST_ASSERT(ectoplasm, "The ghost left no ectoplasm")
	qdel(ectoplasm)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
