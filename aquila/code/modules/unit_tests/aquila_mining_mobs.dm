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
/proc/aquila_mining_melee(mob/living/basic/pawn, behavior_type = /datum/ai_behavior/basic_melee_attack)
	var/datum/ai_controller/controller = pawn.ai_controller
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(behavior_type)
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
	TEST_ASSERT(isturf(victim.loc) && get_dist(victim, host_turf) <= 1, "The dead legion did not drop the body") // content_barfer may push it a step
	var/obj/item/organ/regenerative_core/legion/core = locate() in host_turf
	TEST_ASSERT(core, "The dead legion dropped no legion core")
	qdel(core)
	var/humans_around = 0
	for(var/mob/living/carbon/human/body in range(1, host_turf))
		humans_around++
	TEST_ASSERT_EQUAL(humans_around, 1, "A legion holding a body also left a corpse")

/// The goliath digs tentacles under a target it has held for a while through the AI, the tentacles grab and hurt, a grabbed
/// target gets hit in melee; a punch next to it releases tentacles around it (revenge); a goliath killed mostly by
/// a crusher keeps its trophy for butchering; a tamed goliath can be ridden
/datum/unit_test/aquila_mining_goliath

/datum/unit_test/aquila_mining_goliath/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/mining/goliath/goliath = allocate(/mob/living/basic/mining/goliath, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, aquila_mining_test_turf(corner, run_loc_floor_top_right, 3))
	var/datum/ai_controller/controller = aquila_mining_find_target(goliath)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The goliath did not pick the human three tiles away")
	TEST_ASSERT(goliath.GetComponent(/datum/component/ai_target_timer), "The goliath has no target timer")

	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[use_ability], "The goliath used its tentacles before keeping its target for a while")
	controller.CancelActions()
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.set_blackboard_key(BB_BASIC_MOB_HAS_TARGET_TIME, 5 SECONDS)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[use_ability], "The goliath that kept its target did not plan to use its tentacles")
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT(goliath.tentacles.next_use_time > world.time, "The tentacles did not start their cooldown")
	TEST_ASSERT(locate(/obj/effect/temp_visual/goliath_tentacle) in get_turf(victim), "No tentacle came up under the target")
	TEST_ASSERT(aquila_mining_wait(CALLBACK(victim, TYPE_PROC_REF(/mob/living, IsStun)), 2 SECONDS), "The tentacle did not grab the target")
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The tentacle did not hurt the target")
	controller.CancelActions()

	// A grabbed target is hit in melee
	goliath.forceMove(get_step(victim, WEST))
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[use_ability], "The goliath went for its tentacles on a grabbed target")
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack/goliath)], "The goliath did not plan a melee attack on the grabbed target")
	brute_before = victim.getBruteLoss()
	aquila_mining_melee(goliath, /datum/ai_behavior/basic_melee_attack/goliath)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The goliath did not hit the grabbed target in melee")
	controller.CancelActions()

	// A punch next to it releases tentacles all around (revenge ability)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(goliath, NORTH))
	puncher.set_combat_mode(TRUE)
	puncher.UnarmedAttack(goliath, TRUE)
	TEST_ASSERT(goliath.melee_tentacles.next_use_time > world.time, "A punch did not make the goliath release tentacles around it")
	var/tentacles_around = 0
	for(var/obj/effect/temp_visual/goliath_tentacle/tentacle in range(1, goliath))
		tentacles_around++
	TEST_ASSERT(tentacles_around >= 3, "The tentacle burst made only [tentacles_around] tentacles")

	// Taming makes it rideable through our riding component
	goliath.tamed(puncher)
	TEST_ASSERT(goliath.GetComponent(/datum/component/riding), "A tamed goliath cannot be ridden")

	// Crusher trophy: a goliath killed by a crusher keeps the tentacle trophy for butchering
	var/datum/status_effect/crusher_damage/crusher = goliath.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	crusher.total_damage = goliath.maxHealth * 10
	goliath.death()
	TEST_ASSERT(goliath.guaranteed_butcher_results?[/obj/item/crusher_trophy/goliath_tentacle], "The goliath killed by a crusher has no trophy to butcher")
	TEST_ASSERT(goliath.guaranteed_butcher_results?[/obj/item/stack/sheet/animalhide/goliath_hide], "The goliath has no hide to butcher")
	TEST_ASSERT_EQUAL(goliath.move_resist, MOVE_RESIST_DEFAULT, "The dead goliath kept its huge move resistance")
	for(var/obj/effect/temp_visual/goliath_tentacle/tentacle in range(3, corner))
		qdel(tentacle)

/// The watcher shoots its frost blast at a target through the AI and the shot hits; after holding the target for a while
/// it charges its gaze, which blinds and confuses someone looking at it
/datum/unit_test/aquila_mining_watcher

/datum/unit_test/aquila_mining_watcher/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/mining/watcher/watcher = allocate(/mob/living/basic/mining/watcher, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, aquila_mining_test_turf(corner, run_loc_floor_top_right, 4))
	var/datum/aquila_bullet_recorder/recorder = new
	recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
	var/datum/ai_controller/controller = aquila_mining_find_target(watcher)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The watcher did not pick the human four tiles away")

	var/datum/ai_behavior/shoot = GET_AI_BEHAVIOR(/datum/ai_behavior/ranged_skirmish)
	var/datum/ai_behavior/gaze = GET_AI_BEHAVIOR(/datum/ai_behavior/use_mob_ability)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[gaze], "The watcher gazed before keeping its target for a while")
	TEST_ASSERT(controller.current_behaviors[shoot], "The watcher with a target did not plan to shoot")
	watcher.next_click = 0
	controller.ProcessBehavior(1, shoot)
	TEST_ASSERT(aquila_wait_for_hit(recorder), "The watcher's frost blast did not hit the target")
	var/obj/item/projectile/hit_by = recorder.projectiles[1]
	TEST_ASSERT(istype(hit_by, /obj/item/projectile/temp/basilisk), "The watcher shot something else than its frost blast")
	controller.CancelActions()
	qdel(recorder)

	// The gaze, once the watcher has kept its target for a while
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.set_blackboard_key(BB_BASIC_MOB_HAS_TARGET_TIME, 6 SECONDS)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[gaze], "The watcher that kept its target did not plan to use its gaze")
	victim.setDir(get_dir(victim, watcher))
	controller.ProcessBehavior(1, gaze)
	var/datum/action/cooldown/mob_cooldown/watcher_gaze/gaze_ability = controller.blackboard[BB_GENERIC_ACTION]
	TEST_ASSERT(gaze_ability.stage_timer, "The gaze did not start charging")
	TEST_ASSERT(aquila_mining_wait(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_mining_confused), victim), 3 SECONDS), "The gaze did not confuse the human looking at the watcher")
	TEST_ASSERT(watcher.IsStun(), "The watcher did not stop after its gaze")

/// Is the mob confused
/proc/aquila_mining_confused(mob/living/victim)
	return victim.confused > 0

/// The basilisk shoots from range and bites up close through the AI, and drops its two diamonds when it dies
/datum/unit_test/aquila_mining_basilisk

/datum/unit_test/aquila_mining_basilisk/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/mining/basilisk/basilisk = allocate(/mob/living/basic/mining/basilisk, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, aquila_mining_test_turf(corner, run_loc_floor_top_right, 3))
	var/datum/aquila_bullet_recorder/recorder = new
	recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
	var/datum/ai_controller/controller = aquila_mining_find_target(basilisk)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The basilisk did not pick the human three tiles away")

	var/datum/ai_behavior/shoot = GET_AI_BEHAVIOR(/datum/ai_behavior/ranged_skirmish)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[shoot], "The basilisk with a target did not plan to shoot")
	basilisk.next_click = 0
	controller.ProcessBehavior(1, shoot)
	TEST_ASSERT(aquila_wait_for_hit(recorder), "The basilisk's frost blast did not hit the target")
	controller.CancelActions()
	qdel(recorder)

	basilisk.forceMove(get_step(victim, WEST))
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.SelectBehaviors(1)
	var/brute_before = victim.getBruteLoss()
	aquila_mining_melee(basilisk)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The basilisk did not bite its target in melee")
	controller.CancelActions()

	var/turf/death_turf = get_turf(basilisk)
	basilisk.death()
	var/diamonds = 0
	for(var/obj/item/stack/ore/diamond/diamond in death_turf)
		diamonds += diamond.amount
		qdel(diamond)
	TEST_ASSERT_EQUAL(diamonds, 2, "The dead basilisk did not drop its two diamonds")

/// The goldgrub runs from a human and eats ore it sees through the AI, and spits the ore out when it dies
/datum/unit_test/aquila_mining_goldgrub

/datum/unit_test/aquila_mining_goldgrub/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/mining/goldgrub/grub = allocate(/mob/living/basic/mining/goldgrub, corner)
	grub.will_burrow = FALSE
	for(var/obj/item/stack/ore/swallowed in grub)
		qdel(swallowed)
	var/obj/item/stack/ore/gold/gold = allocate(/obj/item/stack/ore/gold, get_step(corner, EAST))
	var/datum/ai_controller/controller = grub.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], gold, "The goldgrub did not spot the gold ore next to it")
	controller.SelectBehaviors(1)
	aquila_mining_melee(grub)
	TEST_ASSERT(QDELETED(gold) || gold.loc == grub, "The gold ore is still lying next to the goldgrub")
	var/obj/item/stack/ore/gold/swallowed_gold = locate() in grub
	TEST_ASSERT(swallowed_gold, "The goldgrub did not swallow the gold ore")
	controller.CancelActions()

	// Someone outside the mining faction makes it run
	var/mob/living/carbon/human/miner = allocate(/mob/living/carbon/human, aquila_mining_test_turf(corner, run_loc_floor_top_right, 2))
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_FLEE_TARGET], miner, "The goldgrub did not notice the miner")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/run_away_from_target)], "The goldgrub did not plan to run from the miner")
	controller.CancelActions()

	var/turf/death_turf = get_turf(grub)
	grub.death()
	TEST_ASSERT_EQUAL(swallowed_gold.loc, death_turf, "The dead goldgrub did not spit out the ore")

/// The gutlunch eats gibs through the AI, which fills its udder, and gets milked with a beaker; a full guthen keeps its
/// udder overlay; a full guthen breeds with a gubbuck nearby
/datum/unit_test/aquila_mining_gutlunch

/datum/unit_test/aquila_mining_gutlunch/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/basic/mining/gutlunch/guthen/guthen = allocate(/mob/living/basic/mining/gutlunch/guthen, floor)
	var/datum/component/udder/udder_component = guthen.GetComponent(/datum/component/udder)
	TEST_ASSERT(udder_component, "The gutlunch has no udder component")
	STOP_PROCESSING(SSobj, udder_component.udder) // no breeding until the end of the test
	TEST_ASSERT_EQUAL(udder_component.udder.reagents.total_volume, 0, "The gutlunch udder does not start empty")
	var/datum/ai_controller/controller = guthen.ai_controller
	for(var/obj/effect/decal/cleanable/leftover in range(9, floor)) // gibs of earlier tests
		qdel(leftover)
	for(var/i in 1 to 20)
		var/obj/effect/decal/cleanable/blood/gibs/gibs = new(get_step(floor, EAST))
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list))
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], gibs, "The gutlunch did not spot the gibs")
		controller.SelectBehaviors(1)
		aquila_mining_melee(guthen)
		TEST_ASSERT(QDELETED(gibs), "The gutlunch did not eat the gibs")
		controller.CancelActions()
		if(udder_component.udder.reagents.total_volume)
			break
	TEST_ASSERT(udder_component.udder.reagents.total_volume > 0, "Eating gibs did not fill the gutlunch udder")

	var/mob/living/carbon/human/farmer = allocate(/mob/living/carbon/human, get_step(floor, NORTH))
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	farmer.put_in_active_hand(beaker)
	beaker.melee_attack_chain(farmer, guthen)
	TEST_ASSERT(beaker.reagents.total_volume > 0, "Milking the gutlunch gave nothing")
	TEST_ASSERT_EQUAL(guthen.health, guthen.maxHealth, "Milking the gutlunch also hit it")

	// A full udder shows and breeds with a gubbuck nearby
	udder_component.udder.reagents.add_reagent(/datum/reagent/consumable/cream, udder_component.udder.reagents.maximum_volume)
	guthen.udder_changed()
	TEST_ASSERT(guthen.udder_full, "A full guthen does not show its full udder")
	var/mob/living/basic/mining/gutlunch/gubbuck/gubbuck = allocate(/mob/living/basic/mining/gutlunch/gubbuck, get_step(floor, NORTHEAST))
	udder_component.udder.process(1)
	var/mob/living/basic/mining/gutlunch/grublunch/baby = locate() in floor
	TEST_ASSERT(baby, "A full guthen with a gubbuck nearby made no grublunch")
	TEST_ASSERT_EQUAL(udder_component.udder.reagents.total_volume, 0, "Breeding did not empty the udder")
	TEST_ASSERT(!guthen.udder_full, "The guthen kept its full udder overlay after breeding")
	baby.grow_up()
	var/grown_up = 0
	for(var/mob/living/basic/mining/gutlunch/grown in floor)
		if(grown != guthen && !istype(grown, /mob/living/basic/mining/gutlunch/grublunch))
			grown_up++
	TEST_ASSERT_EQUAL(grown_up, 1, "The grublunch did not grow up into a gubbuck or a guthen")
	for(var/mob/living/basic/mining/gutlunch/grown in floor)
		if(grown != guthen)
			qdel(grown)
	qdel(gubbuck)

/// The legion holding this body, if any
/proc/aquila_mining_holder_of(mob/living/victim)
	return istype(victim.loc, /mob/living/basic/mining/legion) ? victim.loc : null

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
