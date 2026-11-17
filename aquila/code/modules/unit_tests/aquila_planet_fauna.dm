// AQUILA - planety: fauna nowych typów planet (aquila/code/modules/planets/shiptest_fauna/)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Every new mob and spawner of the planet fauna spawns without deleting itself; basic mobs come with an AI controller,
/// the burrows only spawn mob types that exist, the pack spawners spawn their packs
/datum/unit_test/planet_fauna_spawns

/datum/unit_test/planet_fauna_spawns/Run()
	var/static/list/mob_types = list(
		/mob/living/basic/mining/wolf,
		/mob/living/basic/mining/wolf/alpha,
		/mob/living/basic/mining/polarbear,
		/mob/living/basic/mining/polarbear/warrior,
		/mob/living/basic/bear/cave,
		/mob/living/basic/mining/legion/snow,
		/mob/living/basic/mining/legion/snow/spawner_made,
		/mob/living/basic/mining/legion_brood/snow,
		/mob/living/basic/snow_monkey,
		/mob/living/basic/mining/ice_demon,
		/mob/living/basic/mining/ice_demon/old,
		/mob/living/basic/mining/demon_afterimage,
		/mob/living/basic/mining/ice_whelp,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/lobstrosity/beach,
		/mob/living/basic/capybara,
		/mob/living/basic/mining/antlion,
		/mob/living/basic/mining/antlion/mega,
		/mob/living/basic/mining/royalcrab,
		/mob/living/basic/mining/goliath/rockplanet,
		/mob/living/basic/mining/goliath/whitesands,
		/mob/living/basic/mining/goliath/whitesands/nest,
		/mob/living/basic/mining/goliath/whitesands/ancient,
		/mob/living/basic/mining/basilisk/whitesands,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet,
	)
	for(var/mob_type in mob_types)
		var/mob/living/creature = new mob_type(run_loc_floor_top_right)
		TEST_ASSERT(!QDELETED(creature), "[mob_type] deleted itself right after spawning")
		if(isbasicmob(creature))
			TEST_ASSERT(creature.ai_controller, "[mob_type] has no AI controller")
		TEST_ASSERT(creature.icon_state, "[mob_type] has no icon state")
		qdel(creature)

	// Random variants turn into one of their kinds
	for(var/random_type in list(/mob/living/basic/mining/wolf/random, /mob/living/basic/mining/ice_demon/random, /mob/living/basic/mining/goliath/whitesands/random))
		new random_type(run_loc_floor_top_right)
	var/random_count = 0
	for(var/mob/living/creature in run_loc_floor_top_right)
		random_count++
		qdel(creature)
	TEST_ASSERT_EQUAL(random_count, 3, "Random planet fauna did not leave exactly one mob each")

	var/static/list/burrow_types = list(
		/obj/structure/spawner/burrow/ice_planet,
		/obj/structure/spawner/burrow/ice_planet/hard,
		/obj/structure/spawner/burrow/jungle_planet,
		/obj/structure/spawner/burrow/rock_plant,
		/obj/structure/spawner/burrow/sand_planet,
		/obj/structure/spawner/burrow/asteroid,
		/obj/structure/spawner/carp,
		/obj/structure/spawner/hivebot,
	)
	for(var/burrow_type in burrow_types)
		var/obj/structure/spawner/burrow = new burrow_type(run_loc_floor_top_right)
		TEST_ASSERT(!QDELETED(burrow), "[burrow_type] deleted itself right after spawning")
		TEST_ASSERT(length(burrow.mob_types), "[burrow_type] has no mobs to spawn")
		for(var/spawned_type in burrow.mob_types)
			TEST_ASSERT(ispath(spawned_type, /mob/living), "[burrow_type] spawns [spawned_type], which is not a mob")
		TEST_ASSERT(burrow.GetComponent(/datum/component/spawner), "[burrow_type] has no spawner component")
		qdel(burrow)

	// Pack spawners: 2-5 snow monkeys, 7 chickens, one bear
	var/static/list/pack_sizes = list(
		/obj/effect/spawner/lootdrop/snow_monkey_pack = list(2, 5),
		/obj/effect/spawner/lootdrop/jungle_chicken_flock = list(7, 7),
		/obj/effect/spawner/lootdrop/polar_bear = list(1, 1),
	)
	for(var/pack_type in pack_sizes)
		new pack_type(run_loc_floor_top_right)
		var/count = 0
		for(var/mob/living/creature in run_loc_floor_top_right)
			count++
			qdel(creature)
		var/list/size = pack_sizes[pack_type]
		TEST_ASSERT(count >= size[1] && count <= size[2], "[pack_type] spawned [count] mobs, expected [size[1]]-[size[2]]")

/// Every hostile planet animal goes for a human next to it and hurts them in melee
/datum/unit_test/planet_fauna_hostile_melee

/datum/unit_test/planet_fauna_hostile_melee/Run()
	var/static/list/hostile_types = list(
		/mob/living/basic/mining/wolf,
		/mob/living/basic/mining/wolf/alpha,
		/mob/living/basic/mining/polarbear,
		/mob/living/basic/mining/polarbear/warrior,
		/mob/living/basic/mining/legion/snow,
		/mob/living/basic/mining/ice_demon,
		/mob/living/basic/mining/ice_whelp,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/lobstrosity/beach,
		/mob/living/basic/mining/antlion,
		/mob/living/basic/mining/antlion/mega,
		/mob/living/basic/mining/royalcrab,
		/mob/living/basic/mining/goliath/rockplanet,
		/mob/living/basic/mining/goliath/whitesands,
		/mob/living/basic/mining/basilisk/whitesands,
	)
	for(var/hostile_type in hostile_types)
		var/mob/living/basic/hostile = new hostile_type(run_loc_floor_bottom_left)
		var/mob/living/carbon/human/victim = new(get_step(run_loc_floor_bottom_left, EAST))
		var/datum/ai_controller/controller = hostile.ai_controller
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "[hostile_type] did not go for the human next to it")
		var/health_before = victim.health
		controller.SelectBehaviors(1)
		// Mobs whose AI opens with an ability next to their target (teleport, eruption, skull) still bite when they can
		if(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)])
			aquila_ai_melee_once(controller)
		else
			hostile.melee_attack(victim, ignore_cooldown = TRUE)
		TEST_ASSERT(victim.health < health_before, "[hostile_type] did not hurt the human in melee")
		qdel(hostile)
		qdel(victim)
	// The ranged fauna also shoots from a distance (in the planning, not waiting for the projectile)
	var/mob/living/basic/mining/ice_demon/demon = allocate(/mob/living/basic/mining/ice_demon, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/far_victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	demon.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, far_victim)
	demon.ai_controller.SelectBehaviors(1)
	TEST_ASSERT(demon.ai_controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/ranged_skirmish)] || demon.ai_controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)], "The ice demon neither shoots nor teleports at a target four tiles away")

/// The wolf lunge and the lobstrosity charge knock down whoever they reach
/datum/unit_test/planet_fauna_charge

/datum/unit_test/planet_fauna_charge/Run()
	var/turf/far_turf = locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	for(var/charger_type in list(/mob/living/basic/mining/wolf, /mob/living/basic/mining/lobstrosity))
		var/mob/living/basic/charger = new charger_type(run_loc_floor_bottom_left)
		var/mob/living/carbon/human/victim = new(far_turf)
		var/datum/ai_controller/controller = charger.ai_controller
		controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
		controller.SelectBehaviors(1)
		TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)], "[charger_type] does not plan a charge at a target four tiles away")
		controller.set_ai_status(AI_STATUS_OFF)
		var/datum/action/cooldown/mob_cooldown/planet_charge/charge = controller.blackboard[BB_TARGETED_ACTION]
		TEST_ASSERT(charge.Activate(victim), "[charger_type] could not start its charge")
		sleep(charge.charge_delay + 1 SECONDS)
		TEST_ASSERT(victim.IsKnockdown(), "The [charger_type] charge did not knock the human down")
		TEST_ASSERT(get_dist(charger, victim) <= 1, "[charger_type] did not reach the human in its charge")
		qdel(charger)
		qdel(victim)

/// The ice whelp's eruption freezes and burns everyone around it; the ice demon conjures afterimages and teleports away
/datum/unit_test/planet_fauna_ice_abilities

/datum/unit_test/planet_fauna_ice_abilities/Run()
	var/mob/living/basic/mining/ice_whelp/whelp = allocate(/mob/living/basic/mining/ice_whelp, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTHEAST))
	whelp.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/eruption = locate() in whelp.actions
	TEST_ASSERT(eruption, "The ice whelp has no eruption")
	var/temperature_before = victim.bodytemperature
	TEST_ASSERT(eruption.Trigger(target = whelp), "The ice whelp could not erupt")
	sleep(eruption.forecast_delay + 0.5 SECONDS)
	TEST_ASSERT(victim.getFireLoss() > 0, "The ice eruption did not burn the human next to the whelp")
	TEST_ASSERT(victim.bodytemperature < temperature_before, "The ice eruption did not chill the human next to the whelp")

	var/mob/living/basic/mining/ice_demon/demon = allocate(/mob/living/basic/mining/ice_demon, get_step(run_loc_floor_top_right, SOUTH))
	var/mob/living/carbon/human/hunted = allocate(/mob/living/carbon/human, get_step(demon, WEST))
	var/datum/ai_controller/controller = demon.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, hunted)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)], "The ice demon does not teleport away from someone next to it")
	controller.set_ai_status(AI_STATUS_OFF)
	var/datum/action/cooldown/mob_cooldown/ice_demon_afterimages/clones = locate() in demon.actions
	TEST_ASSERT(clones.Activate(demon), "The ice demon could not conjure afterimages")
	var/afterimage_count = 0
	for(var/mob/living/basic/mining/demon_afterimage/afterimage in range(1, demon))
		afterimage_count++
		TEST_ASSERT(afterimage.faction_check_mob(demon), "An afterimage is not on the demon's side")
	TEST_ASSERT_EQUAL(afterimage_count, 2, "The ice demon did not conjure two afterimages")
	QDEL_LIST(clones.afterimages)

/// The antlion burrows, becomes untouchable and bursts out next to its target; the sand basilisk's shell soaks damage
/// until it cracks and drops diamonds
/datum/unit_test/planet_fauna_antlion_and_shell

/datum/unit_test/planet_fauna_antlion_and_shell/Run()
	var/turf/start_turf = run_loc_floor_bottom_left
	var/turf/target_turf = locate(start_turf.x + 4, start_turf.y, start_turf.z)
	var/list/changed_turfs = list()
	for(var/turf/T as anything in block(start_turf, locate(start_turf.x + 4, start_turf.y + 1, start_turf.z)))
		changed_turfs[T] = T.type
		for(var/obj/effect/decal/cleanable/stain in T)
			qdel(stain)
		T.ChangeTurf(/turf/open/floor/plating/asteroid/basalt)
	var/mob/living/basic/mining/antlion/antlion = allocate(/mob/living/basic/mining/antlion, start_turf)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, target_turf)
	antlion.ai_controller.set_ai_status(AI_STATUS_OFF)
	TEST_ASSERT(antlion.burrow.Activate(victim), "The antlion could not burrow in sand")
	TEST_ASSERT(antlion.burrow.burrowed, "The antlion is not underground after burrowing")
	TEST_ASSERT(antlion.status_flags & GODMODE, "The burrowed antlion can be hurt")
	sleep(3.5 SECONDS)
	TEST_ASSERT(!antlion.burrow.burrowed, "The antlion did not come back out")
	TEST_ASSERT(!(antlion.status_flags & GODMODE), "The antlion stays untouchable after coming out")
	TEST_ASSERT(get_dist(antlion, victim) <= 1, "The antlion did not come out next to its target")
	TEST_ASSERT(victim.health < victim.maxHealth, "The antlion did not bite its target when coming out")
	for(var/turf/T as anything in changed_turfs)
		T.ChangeTurf(changed_turfs[T])

	var/mob/living/basic/mining/basilisk/whitesands/basilisk = allocate(/mob/living/basic/mining/basilisk/whitesands, run_loc_floor_top_right)
	basilisk.ai_controller.set_ai_status(AI_STATUS_OFF)
	basilisk.adjustBruteLoss(30)
	TEST_ASSERT(basilisk.health > basilisk.maxHealth - 10, "The sand basilisk's shell did not soak the damage")
	basilisk.adjustBruteLoss(40)
	TEST_ASSERT(basilisk.shell_health <= 0, "The sand basilisk's shell did not crack")
	TEST_ASSERT(locate(/obj/item/stack/ore/diamond) in get_turf(basilisk), "The cracked shell did not drop diamonds")
	var/health_before = basilisk.health
	basilisk.adjustBruteLoss(10)
	TEST_ASSERT_EQUAL(basilisk.health, health_before - 10, "The sand basilisk without its shell still soaks damage")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
