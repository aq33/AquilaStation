// AQUILA - basic pets from BeeStation/BeeStation-Hornet#14771 (fox, penguin, sloth, hamster)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// A penguin chick grows into an emperor penguin; holodeck and mapped penguin chicks do not grow
/datum/unit_test/aquila_penguin_chick_grows

/datum/unit_test/aquila_penguin_chick_grows/Run()
	var/mob/living/basic/pet/penguin/baby/chick = allocate(/mob/living/basic/pet/penguin/baby, run_loc_floor_bottom_left)
	var/datum/component/growth_and_differentiation/growth = chick.GetComponent(/datum/component/growth_and_differentiation)
	TEST_ASSERT(growth, "The penguin chick cannot grow up")
	var/mob/living/basic/pet/penguin/emperor/adult = growth.grow(TRUE)
	TEST_ASSERT(istype(adult), "The penguin chick grew into [adult?.type] instead of an emperor penguin")
	allocated += adult
	TEST_ASSERT(adult.GetComponent(/datum/component/waddling), "The grown penguin does not waddle")
	var/mob/living/basic/pet/penguin/baby/permanent/holo = allocate(/mob/living/basic/pet/penguin/baby/permanent, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(!holo.GetComponent(/datum/component/growth_and_differentiation), "A permanent penguin chick grows up")

/// A fox bite hurts small animals more (tiny_mob_hunter); the captain's fox does not hunt on its own, a common fox does
/datum/unit_test/aquila_fox_hunter

/datum/unit_test/aquila_fox_hunter/Run()
	var/mob/living/basic/pet/fox/fox = allocate(/mob/living/basic/pet/fox, run_loc_floor_bottom_left)
	var/mob/living/basic/chicken/hen = allocate(/mob/living/basic/chicken, get_step(run_loc_floor_bottom_left, EAST))
	var/health_before = hen.health
	fox.melee_attack(hen, ignore_cooldown = TRUE)
	TEST_ASSERT(health_before - hen.health >= fox.melee_damage + 10, "The fox bite took [health_before - hen.health] health from a chicken, expected the small mob bonus")

	var/datum/targeting_strategy/targeting = GET_TARGETING_STRATEGY(fox.ai_controller.blackboard[BB_TARGETING_STRATEGY])
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/captain = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(targeting.can_attack(fox, mouse), "A fox does not hunt mice")
	TEST_ASSERT(!targeting.can_attack(fox, captain), "A fox hunts people")
	var/hunts = FALSE
	for(var/datum/ai_planning_subtree/subtree as anything in fox.ai_controller.planning_subtrees)
		if(istype(subtree, /datum/ai_planning_subtree/simple_find_target))
			hunts = TRUE
	TEST_ASSERT(hunts, "A common fox does not look for prey")

	// Renault hunts vermin only: mice and cockroaches yes, Ian, Runtime and the hens no
	var/mob/living/basic/pet/fox/renault/renault = allocate(/mob/living/basic/pet/fox/renault, get_step(run_loc_floor_bottom_left, SOUTHEAST))
	var/datum/targeting_strategy/renault_targeting = GET_TARGETING_STRATEGY(renault.ai_controller.blackboard[BB_TARGETING_STRATEGY])
	var/mob/living/basic/cockroach/roach = allocate(/mob/living/basic/cockroach, get_step(run_loc_floor_bottom_left, NORTHWEST))
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(run_loc_floor_bottom_left, WEST))
	var/mob/living/basic/pet/cat/cat = allocate(/mob/living/basic/pet/cat, get_step(run_loc_floor_bottom_left, SOUTH))
	TEST_ASSERT(renault_targeting.can_attack(renault, mouse), "Renault does not hunt mice")
	TEST_ASSERT(renault_targeting.can_attack(renault, roach), "Renault does not hunt cockroaches")
	TEST_ASSERT(!renault_targeting.can_attack(renault, corgi), "Renault hunts the corgi")
	TEST_ASSERT(!renault_targeting.can_attack(renault, cat), "Renault hunts the cat")
	TEST_ASSERT(!renault_targeting.can_attack(renault, hen), "Renault hunts chickens")
	TEST_ASSERT(!renault_targeting.can_attack(renault, captain), "Renault hunts people")
	TEST_ASSERT(renault.GetComponent(/datum/component/obeys_commands), "Renault does not obey commands")

/// A sloth that "attacks" a tree climbs it, and comes down when it moves
/datum/unit_test/aquila_sloth_climbs_trees

/datum/unit_test/aquila_sloth_climbs_trees/Run()
	var/mob/living/basic/sloth/sloth = allocate(/mob/living/basic/sloth, run_loc_floor_bottom_left)
	var/obj/structure/flora/tree/pine/tree = allocate(/obj/structure/flora/tree/pine, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/component/tree_climber/climber = sloth.GetComponent(/datum/component/tree_climber)
	TEST_ASSERT(climber, "The sloth cannot climb trees")
	sloth.melee_attack(tree, ignore_cooldown = TRUE)
	TEST_ASSERT(climber.current_tree == tree, "The sloth did not climb the tree it clicked")
	TEST_ASSERT(sloth.loc == tree.loc, "The sloth is not on the tree's tile")
	TEST_ASSERT(tree.obj_integrity == tree.max_integrity, "Climbing the tree damaged it")
	sloth.SetStun(0)
	climber.remove_from_tree()
	TEST_ASSERT(isnull(climber.current_tree), "The sloth did not come down from the tree")

/// Vector the hamster carries a disease for the extrapolator, as before
/datum/unit_test/aquila_hamster_vector

/datum/unit_test/aquila_hamster_vector/Run()
	var/mob/living/basic/pet/hamster/vector/vector = allocate(/mob/living/basic/pet/hamster/vector, run_loc_floor_bottom_left)
	TEST_ASSERT(length(vector.extrapolatordisease), "Vector carries no disease for the extrapolator")

#undef TEST_ASSERT
