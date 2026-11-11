// AQUILA - tg basic mobs from before behaviour trees (tg 926bf40c5a, decision D15): bear, space bat, killer tomato, frog
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// A space bear finds the human next to it through the AI and mauls it; bear armour makes it tougher
/datum/unit_test/aquila_bear_ai_attack

/datum/unit_test/aquila_bear_ai_attack/Run()
	var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = bear.ai_controller

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	TEST_ASSERT(controller.current_behaviors[find_target], "The bear did not plan to look for prey")
	controller.ProcessBehavior(1, find_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The bear did not pick the human next to it")

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/basic_melee_attack/attack = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	TEST_ASSERT(controller.current_behaviors[attack], "The bear with prey did not plan a melee attack")
	controller.ProcessBehavior(1, attack)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	bear.next_move = 0
	var/health_before = victim.health
	controller.ProcessBehavior(1, attack)
	TEST_ASSERT(victim.health < health_before, "The bear attack did not hurt the human")

	var/obj/item/bear_armor/armor = allocate(/obj/item/bear_armor)
	victim.put_in_active_hand(armor)
	var/health_max_before = bear.maxHealth
	armor.afterattack(bear, victim, TRUE)
	TEST_ASSERT(bear.armored, "Bear armour did not go on the bear")
	TEST_ASSERT_EQUAL(bear.maxHealth, health_max_before + 60, "Bear armour did not make the bear tougher")

	var/mob/living/basic/bear/butter/butter = allocate(/mob/living/basic/bear/butter, get_step(run_loc_floor_bottom_left, NORTH))
	butter.adjustBruteLoss(20)
	var/butter_health = butter.health
	butter.Life()
	TEST_ASSERT(butter.health > butter_health, "The butter bear did not regenerate")

/// A space bat leaves people alone until hit, then goes for the one who hit it
/datum/unit_test/aquila_bat_retaliates

/datum/unit_test/aquila_bat_retaliates/Run()
	var/mob/living/basic/bat/bat = allocate(/mob/living/basic/bat, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = bat.ai_controller
	TEST_ASSERT(bat.movement_type & FLYING, "The space bat does not fly")

	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The bat attacks without being hit")

	puncher.set_combat_mode(TRUE)
	bat.attack_hand(puncher)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "The bat did not go for the one who hit it")

/// A killer tomato hunts people; a frog bite gives space drugs
/datum/unit_test/aquila_tomato_frog

/datum/unit_test/aquila_tomato_frog/Run()
	var/mob/living/basic/killer_tomato/tomato = allocate(/mob/living/basic/killer_tomato, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = tomato.ai_controller
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	controller.ProcessBehavior(1, find_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The killer tomato did not go for the human")

	var/mob/living/basic/frog/frog = allocate(/mob/living/basic/frog, get_step(run_loc_floor_bottom_left, NORTH))
	frog.melee_attack(victim, ignore_cooldown = TRUE)
	TEST_ASSERT(victim.reagents.has_reagent(/datum/reagent/drug/space_drugs), "The frog bite gave no space drugs")
	var/mob/living/basic/frog/rare/rare = allocate(/mob/living/basic/frog/rare, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT_EQUAL(rare.icon_state, "rare_frog", "The rare frog does not look rare")

/// Sergeant Araneus takes no cold or atmos damage, like the old simple animal (minbodytemp 0, no atmos requirements)
/datum/unit_test/aquila_araneus_space_proof

/datum/unit_test/aquila_araneus_space_proof/Run()
	var/mob/living/basic/bat/sgt_araneus/araneus = allocate(/mob/living/basic/bat/sgt_araneus, run_loc_floor_bottom_left)
	araneus.bodytemperature = 100
	SEND_SIGNAL(araneus, COMSIG_LIVING_LIFE, SSMOBS_DT, 1)
	TEST_ASSERT_EQUAL(araneus.health, araneus.maxHealth, "Sergeant Araneus took cold damage")
	TEST_ASSERT_EQUAL(araneus.unsuitable_atmos_damage, 0, "Sergeant Araneus is hurt by bad air")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
