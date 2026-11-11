// AQUILA - zombies and skeletons as tg basic mobs (mobabilities part 2), with the maintenance trap and the skeleton pit
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Runs the melee attack behaviour of a controller until it lands (it waits for its attack delay first)
/datum/unit_test/proc/aquila_ai_melee_once(datum/ai_controller/controller)
	var/datum/ai_behavior/basic_melee_attack/attack = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	controller.ProcessBehavior(1, attack)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	var/mob/living/pawn = controller.pawn
	pawn.next_move = 0
	controller.ProcessBehavior(1, attack)

/// A zombie finds the human next to it and bites; when it dies the zombie human corpse drops in its place
/datum/unit_test/aquila_zombie_bites_and_drops_corpse

/datum/unit_test/aquila_zombie_bites_and_drops_corpse/Run()
	var/mob/living/basic/zombie/zombie = allocate(/mob/living/basic/zombie, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = zombie.ai_controller

	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The zombie did not go for the human")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)], "The zombie did not plan to bite")
	var/health_before = victim.health
	aquila_ai_melee_once(controller)
	TEST_ASSERT(victim.health < health_before, "The zombie bite did not hurt")

	var/turf/zombie_turf = get_turf(zombie)
	zombie.death()
	TEST_ASSERT(QDELETED(zombie), "The dead zombie mob stayed")
	var/mob/living/carbon/human/corpse
	for(var/mob/living/carbon/human/body in zombie_turf)
		corpse = body
	TEST_ASSERT(corpse, "The zombie left no corpse")
	TEST_ASSERT(istype(corpse.dna?.species, /datum/species/zombie), "The zombie corpse is not a zombie")
	qdel(corpse)

/// A rotten zombie is weaker and does not smash obstacles; the trap zombie leaves knocked out people alone
/datum/unit_test/aquila_zombie_variants

/datum/unit_test/aquila_zombie_variants/Run()
	var/mob/living/basic/zombie/rotten/assistant/rotten = allocate(/mob/living/basic/zombie/rotten/assistant, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(rotten.maxHealth, 60, "Rotten zombie health")
	TEST_ASSERT(!(locate(/datum/ai_planning_subtree/attack_obstacle_in_path) in rotten.ai_controller.planning_subtrees), "The rotten zombie smashes obstacles")
	TEST_ASSERT_EQUAL(rotten.zombiejob, JOB_NAME_ASSISTANT, "The rotten assistant zombie wears no assistant outfit")

	// The maintenance trap spawns the hugbox zombie already after the one who stepped on it
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/effect/trap/nexus/trickyspawner/zombie/trap = allocate(/obj/effect/trap/nexus/trickyspawner/zombie, get_step(run_loc_floor_bottom_left, EAST))
	var/list/before = GLOB.mob_living_list.Copy()
	trap.crossattempts = 0
	trap.TrapEffect(victim)
	var/mob/living/basic/zombie/hugbox/hugbox
	for(var/mob/living/basic/zombie/hugbox/spawned in GLOB.mob_living_list - before)
		hugbox = spawned
	TEST_ASSERT(hugbox, "The zombie trap spawned no basic zombie")
	TEST_ASSERT_EQUAL(hugbox.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The trap zombie did not go after the one who stepped on the trap")
	victim.Unconscious(20 SECONDS)
	victim.set_stat(UNCONSCIOUS)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(hugbox.ai_controller.blackboard[BB_TARGETING_STRATEGY])
	TEST_ASSERT(!strategy.can_attack(hugbox, victim), "The trap zombie attacks knocked out people")
	qdel(hugbox)

/// A skeleton drinks milk to heal, burns itself on soy milk, crumbles into remains; the eskimo drops its gear
/datum/unit_test/aquila_skeleton_milk_and_remains

/datum/unit_test/aquila_skeleton_milk_and_remains/Run()
	var/mob/living/basic/skeleton/skeleton = allocate(/mob/living/basic/skeleton, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/food/condiment/milk/milk = allocate(/obj/item/reagent_containers/food/condiment/milk, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = skeleton.ai_controller
	skeleton.adjustBruteLoss(30)

	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], milk, "The hurt skeleton did not go for the milk")
	controller.SelectBehaviors(1)
	var/hurt = skeleton.health
	aquila_ai_melee_once(controller)
	TEST_ASSERT(skeleton.health > hurt, "The skeleton did not heal from the milk")

	var/obj/item/reagent_containers/food/condiment/soymilk/soymilk = allocate(/obj/item/reagent_containers/food/condiment/soymilk)
	var/healthy = skeleton.health
	skeleton.UnarmedAttack(soymilk, TRUE)
	TEST_ASSERT(skeleton.health < healthy, "Soy milk did not hurt the skeleton")

	var/turf/skeleton_turf = get_turf(skeleton)
	skeleton.death()
	TEST_ASSERT(QDELETED(skeleton), "The dead skeleton did not crumble")
	TEST_ASSERT(locate(/obj/effect/decal/remains/human) in skeleton_turf, "The skeleton left no remains")

	var/mob/living/basic/skeleton/eskimo/eskimo = allocate(/mob/living/basic/skeleton/eskimo, get_step(run_loc_floor_bottom_left, NORTH))
	var/turf/eskimo_turf = get_turf(eskimo)
	eskimo.death()
	TEST_ASSERT(locate(/obj/item/spear) in eskimo_turf, "The eskimo dropped no spear")
	TEST_ASSERT(locate(/obj/item/clothing/suit/hooded/wintercoat) in eskimo_turf, "The eskimo dropped no winter coat")
	for(var/obj/item/loot in eskimo_turf)
		qdel(loot)
	for(var/obj/item/loot in skeleton_turf)
		qdel(loot)

/// The skeleton pit keeps count of its basic skeletons: a dead one makes room for a new one
/datum/unit_test/aquila_skeleton_pit_counts_basic_mobs

/datum/unit_test/aquila_skeleton_pit_counts_basic_mobs/Run()
	var/obj/structure/spawner/skeleton/pit = allocate(/obj/structure/spawner/skeleton, run_loc_floor_bottom_left)
	var/datum/component/spawner/spawner = pit.GetComponent(/datum/component/spawner)
	spawner.spawn_delay = 0
	spawner.try_spawn_mob()
	TEST_ASSERT_EQUAL(length(spawner.spawned_mobs), 1, "The pit spawned no skeleton")
	var/mob/living/basic/skeleton/skeleton = spawner.spawned_mobs[1]
	TEST_ASSERT(istype(skeleton), "The pit spawned [skeleton?.type]")
	skeleton.death()
	TEST_ASSERT_EQUAL(length(spawner.spawned_mobs), 0, "The dead skeleton still counts against the pit")
	for(var/obj/effect/decal/remains/human/remains in range(1, pit))
		qdel(remains)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
