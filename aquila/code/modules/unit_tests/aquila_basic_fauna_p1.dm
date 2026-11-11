// AQUILA - cheap tg basic mobs, part 2: pine tree and festivus pole, giant ant, spaceman (tg 926bf40c5a)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// The pine tree hunts people and bites them, falls apart into wood; rubbing the festivus pole charges cells around it
/datum/unit_test/aquila_tree_and_festivus

/datum/unit_test/aquila_tree_and_festivus/Run()
	var/mob/living/basic/tree/tree = allocate(/mob/living/basic/tree, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = tree.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The pine tree did not go for the human")
	controller.SelectBehaviors(1)
	var/health_before = victim.health
	aquila_ai_melee_once(controller)
	TEST_ASSERT(victim.health < health_before, "The pine tree bite did not hurt")

	var/turf/tree_turf = get_turf(tree)
	tree.death()
	TEST_ASSERT(QDELETED(tree), "The dead pine tree stayed")
	var/obj/item/stack/sheet/mineral/wood/wood = locate() in tree_turf
	TEST_ASSERT(wood, "The pine tree left no wood")
	qdel(wood)

	var/mob/living/basic/tree/festivus/pole = allocate(/mob/living/basic/tree/festivus, get_step(run_loc_floor_bottom_left, NORTH))
	TEST_ASSERT_EQUAL(pole.paralyze_prob, 0, "The festivus pole knocks people down")
	var/obj/item/stock_parts/cell/cell = allocate(/obj/item/stock_parts/cell, get_step(run_loc_floor_bottom_left, NORTHEAST))
	cell.charge = 0
	victim.set_combat_mode(FALSE)
	pole.attack_hand(victim)
	TEST_ASSERT(cell.charge > 0, "Rubbing the festivus pole did not charge the cell next to it")

/// The giant ant leaves people alone, runs from whoever hurts it; the spaceman hits back the one who hit him
/datum/unit_test/aquila_ant_and_spaceman_retaliate

/datum/unit_test/aquila_ant_and_spaceman_retaliate/Run()
	var/mob/living/basic/ant/ant = allocate(/mob/living/basic/ant, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = ant.ai_controller
	TEST_ASSERT_EQUAL(ant.ventcrawler, VENTCRAWLER_ALWAYS, "The giant ant cannot crawl through vents")

	var/datum/ai_behavior/flee_find = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list/nearest)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, flee_find)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The ant picks on people unprovoked")
	puncher.set_combat_mode(TRUE)
	ant.attack_hand(puncher)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, flee_find)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "The ant did not mark the one who hit it")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/run_away_from_target)], "The hurt ant did not run away")

	var/mob/living/basic/spaceman/spaceman = allocate(/mob/living/basic/spaceman, get_step(run_loc_floor_bottom_left, NORTH))
	controller = spaceman.ai_controller
	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The spaceman attacks without being hit")
	spaceman.attack_hand(puncher)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "The spaceman did not go for the one who hit him")
	TEST_ASSERT(isshoefoot(spaceman), "The spaceman has no shoe footsteps")

/// A Kurwinox goes for anyone outside its faction and hits hard
/datum/unit_test/aquila_kurwinox_hunts

/datum/unit_test/aquila_kurwinox_hunts/Run()
	var/mob/living/basic/kurwinoxy/kurwinox = allocate(/mob/living/basic/kurwinoxy, run_loc_floor_bottom_left)
	var/mob/living/basic/kurwinoxy/czerwony/buddy = allocate(/mob/living/basic/kurwinoxy/czerwony, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/ai_controller/controller = kurwinox.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The Kurwinox did not go for the human (it picked [controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]])")
	TEST_ASSERT(buddy != controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], "The Kurwinox picked on its own kind")
	victim.forceMove(get_step(run_loc_floor_bottom_left, EAST))
	controller.SelectBehaviors(1)
	var/health_before = victim.health
	aquila_ai_melee_once(controller)
	TEST_ASSERT(victim.health < health_before, "The Kurwinox hit did not hurt")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
