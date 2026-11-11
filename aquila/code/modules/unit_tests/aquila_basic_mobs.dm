// AQUILA - basic mobs (port of BeeStation/BeeStation-Hornet /mob/living/basic): AI planning, attacks and retaliation
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Test-only basic mob that attacks whoever it can see
/mob/living/basic/aquila_test_critter
	name = "testowy stwór"
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	maxHealth = 50
	health = 50
	melee_damage = 10
	faction = list(FACTION_HOSTILE)
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile

/// Test-only basic mob that only fights back
/mob/living/basic/aquila_test_critter/retaliate
	faction = list(FACTION_NEUTRAL)
	ai_controller = /datum/ai_controller/basic_controller/aquila_test_retaliate

/mob/living/basic/aquila_test_critter/retaliate/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/aquila_test_retaliate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// A hostile basic mob finds a target, plans a melee attack and its click reaches attack_basic_mob() and attack_animal()
/datum/unit_test/aquila_basic_mob_ai_planning

/datum/unit_test/aquila_basic_mob_ai_planning/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/basic/aquila_test_critter/critter = allocate(/mob/living/basic/aquila_test_critter, left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/ai_controller/basic_controller/controller = critter.ai_controller
	TEST_ASSERT(istype(controller), "Basic mob has no basic controller")
	TEST_ASSERT(controller.able_to_run, "Healthy basic mob cannot run its AI")
	// friendly/attacktext mirrors for core attack code
	TEST_ASSERT_EQUAL(critter.attacktext, critter.attack_verb_continuous, "attacktext does not mirror attack_verb_continuous")

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	TEST_ASSERT(controller.current_behaviors[find_target], "Hostile basic mob did not plan to look for targets")
	controller.ProcessBehavior(1, find_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "Hostile basic mob did not pick the human next to it")

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/basic_melee_attack/attack = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	TEST_ASSERT(controller.current_behaviors[attack], "Basic mob with a target did not plan a melee attack")
	TEST_ASSERT_EQUAL(controller.current_movement_target, victim, "Melee attack does not move towards the target")

	// First run only starts the attack delay
	controller.ProcessBehavior(1, attack)
	TEST_ASSERT(controller.blackboard[BB_BASIC_MOB_MELEE_COOLDOWN_TIMER], "Melee attack did not start its delay")
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	critter.next_move = 0
	var/health_before = victim.health
	controller.ProcessBehavior(1, attack)
	TEST_ASSERT(victim.health < health_before, "Basic mob melee attack did not hurt the human")

/// A peaceful basic mob with ai_retaliate remembers who hit it and targets them
/datum/unit_test/aquila_basic_mob_retaliation

/datum/unit_test/aquila_basic_mob_retaliation/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/basic/aquila_test_critter/retaliate/critter = allocate(/mob/living/basic/aquila_test_critter/retaliate, left)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/ai_controller/controller = critter.ai_controller

	controller.SelectBehaviors(1)
	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "Peaceful basic mob picked a target nobody gave it")

	// A friendly pat does not count as an attack
	puncher.set_combat_mode(FALSE)
	critter.attack_hand(puncher)
	TEST_ASSERT(!length(controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]), "Petting counted as an attack")

	puncher.set_combat_mode(TRUE)
	var/health_before = critter.health
	critter.attack_hand(puncher)
	TEST_ASSERT(critter.health < health_before, "Punch did not hurt the basic mob")
	TEST_ASSERT(puncher in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "Basic mob did not remember who hit it")

	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[from_list], "Basic mob did not plan to pick a target from its enemies")
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "Basic mob did not target the one who hit it")

	// Death: the mob looks dead and stops blocking movement
	critter.death()
	TEST_ASSERT_EQUAL(critter.icon_state, critter.icon_dead, "Dead basic mob does not look dead")
	TEST_ASSERT(!critter.density, "Dead basic mob is still dense")
	TEST_ASSERT(!controller.able_to_run, "Dead basic mob can still run its AI")
	critter.revive(full_heal = TRUE, admin_revive = TRUE)
	TEST_ASSERT_EQUAL(critter.icon_state, critter.icon_living, "Revived basic mob still looks dead")
	TEST_ASSERT(controller.able_to_run, "Revived basic mob did not get its AI back")


/// Test-only pet: tamed by meat, obeys stay/follow/free
/mob/living/basic/pet/aquila_test_pet
	name = "testowy zwierzak"
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	ai_controller = /datum/ai_controller/basic_controller/aquila_test_pet

/mob/living/basic/pet/aquila_test_pet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat/slab), tame_chance = 100, bonus_tame_chance = 0, unique = FALSE)
	AddComponent(/datum/component/obeys_commands, list(/datum/pet_command/idle, /datum/pet_command/free, /datum/pet_command/follow))

/datum/ai_controller/basic_controller/aquila_test_pet
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
	)

/// Feeding tames the pet (tameable + basic_eating), then a Polish spoken command makes it follow its new friend
/datum/unit_test/aquila_pet_taming_and_commands

/datum/unit_test/aquila_pet_taming_and_commands/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/basic/pet/aquila_test_pet/pet = allocate(/mob/living/basic/pet/aquila_test_pet, left)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/ai_controller/controller = pet.ai_controller

	// Strangers are ignored
	owner.say("za mną")
	TEST_ASSERT(isnull(controller.blackboard[BB_ACTIVE_PET_COMMAND]), "Pet obeyed a stranger")

	var/obj/item/food/meat/slab/meat = allocate(/obj/item/food/meat/slab, get_turf(owner))
	owner.put_in_active_hand(meat)
	pet.attackby(meat, owner)
	TEST_ASSERT(QDELETED(meat), "Pet did not eat the food it likes")
	TEST_ASSERT(owner in controller.blackboard[BB_FRIENDS_LIST], "Feeding did not tame the pet")
	TEST_ASSERT(REF(owner) in pet.faction, "Tamed pet does not share a faction with its owner")

	owner.say("Za mną!")
	var/datum/pet_command/command = controller.blackboard[BB_ACTIVE_PET_COMMAND]
	TEST_ASSERT(istype(command, /datum/pet_command/follow), "Pet did not take the spoken follow command")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_CURRENT_PET_TARGET], owner, "Follow command does not target the owner")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/pet_follow_friend)], "Pet with a follow command did not plan to follow")

	owner.say("siad")
	TEST_ASSERT(istype(controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/idle), "Pet did not take the spoken stay command")

	// Hitting it ends the friendship (unfriend element is not on this pet, so unfriend by hand like unfriend_attacker would)
	pet.unfriend(owner)
	TEST_ASSERT(!(owner in controller.blackboard[BB_FRIENDS_LIST]), "Unfriended owner stayed on the friends list")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
