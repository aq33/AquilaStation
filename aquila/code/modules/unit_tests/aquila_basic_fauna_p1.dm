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

/// Walking mushrooms fight only each other: the winner chews on the fainted one and devours it on the third bite to level up
/datum/unit_test/aquila_mushroom_devours_and_levels

/datum/unit_test/aquila_mushroom_devours_and_levels/Run()
	var/mob/living/basic/mushroom/eater = allocate(/mob/living/basic/mushroom, run_loc_floor_bottom_left)
	var/mob/living/basic/mushroom/victim = allocate(/mob/living/basic/mushroom, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/ai_controller/controller = eater.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The mushroom did not go for the other mushroom")
	TEST_ASSERT(bystander != controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], "The mushroom went for a human")

	// The fight itself does not bruise the victim, or no mushroom would ever level up from a meal it beat up
	eater.melee_attack(victim, ignore_cooldown = TRUE)
	TEST_ASSERT(victim.health < victim.maxHealth, "The mushroom did not bite the other mushroom")
	TEST_ASSERT(!victim.bruised, "A bite of another mushroom bruised the victim")
	victim.death()
	TEST_ASSERT_EQUAL(victim.stat, DEAD, "The victim mushroom did not faint")
	var/level_before = eater.powerlevel
	for(var/bite in 1 to 3)
		controller.SelectBehaviors(1)
		aquila_ai_melee_once(controller)
	TEST_ASSERT(QDELETED(victim), "Three bites did not devour the fainted mushroom")
	TEST_ASSERT(eater.powerlevel > level_before, "Devouring a mushroom did not level up the eater")

	// A bruised mushroom gives no level when eaten
	var/mob/living/basic/mushroom/bruised = allocate(/mob/living/basic/mushroom, get_step(run_loc_floor_bottom_left, EAST))
	bystander.set_combat_mode(TRUE)
	bruised.attack_hand(bystander)
	TEST_ASSERT(bruised.bruised, "Punching the mushroom did not bruise it")
	bruised.death()
	level_before = eater.powerlevel
	eater.consume_mushroom(bruised)
	TEST_ASSERT_EQUAL(eater.powerlevel, level_before, "A bruised mushroom still gave a level")

/// A fainted mushroom comes back when fed a mushroom (once in a while); the killer fruit trait wakes up a basic walking mushroom
/datum/unit_test/aquila_mushroom_recovers

/datum/unit_test/aquila_mushroom_recovers/Run()
	var/mob/living/basic/mushroom/shroom = allocate(/mob/living/basic/mushroom, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	shroom.death()
	var/obj/item/food/grown/mushroom/chanterelle/meal = allocate(/obj/item/food/grown/mushroom/chanterelle)
	feeder.put_in_active_hand(meal)
	shroom.attackby(meal, feeder)
	TEST_ASSERT_EQUAL(shroom.stat, CONSCIOUS, "Feeding a mushroom did not bring the fainted one back")
	TEST_ASSERT(QDELETED(meal), "The mushroom was not eaten")
	shroom.death()
	var/obj/item/food/grown/mushroom/chanterelle/second = allocate(/obj/item/food/grown/mushroom/chanterelle)
	feeder.put_in_active_hand(second)
	shroom.attackby(second, feeder)
	TEST_ASSERT_EQUAL(shroom.stat, DEAD, "The mushroom came back twice in a row")

	var/datum/plant_trait/fruit/killer/friendly/walking/trait = /datum/plant_trait/fruit/killer/friendly/walking
	TEST_ASSERT(ispath(initial(trait.awaken_mob), /mob/living/basic/mushroom), "The walking killer fruit trait does not wake up a basic walking mushroom")

/// The Faithless hunts people, smashes lights it sees and drags away the people it knocked out
/datum/unit_test/aquila_faithless_ai

/datum/unit_test/aquila_faithless_ai/Run()
	var/mob/living/basic/faithless/faithless = allocate(/mob/living/basic/faithless, run_loc_floor_bottom_left)
	var/obj/machinery/light/light = allocate(/obj/machinery/light, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/ai_controller/controller = faithless.ai_controller

	// No one around: the light is next
	var/datum/ai_behavior/find_lights = GET_AI_BEHAVIOR(/datum/ai_behavior/find_hunt_target/light_fixtures)
	for(var/i in 1 to 10)
		controller.SelectBehaviors(1)
		if(controller.current_behaviors[find_lights])
			break
	TEST_ASSERT(controller.current_behaviors[find_lights], "The Faithless never looked for lights")
	controller.ProcessBehavior(1, find_lights)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_LOW_PRIORITY_HUNTING_TARGET], light, "The Faithless did not pick the light next to it")
	var/datum/ai_behavior/smash = GET_AI_BEHAVIOR(/datum/ai_behavior/hunt_target/interact_with_target/light_fixtures)
	for(var/i in 1 to 10)
		controller.SelectBehaviors(1)
		if(controller.current_behaviors[smash])
			break
	TEST_ASSERT(controller.current_behaviors[smash], "The Faithless did not go to smash the light")
	for(var/i in 1 to 5)
		faithless.next_move = 0
		faithless.next_click = 0
		controller.ProcessBehavior(1, smash)
		if(QDELETED(light) || light.status == LIGHT_BROKEN)
			break
	TEST_ASSERT(QDELETED(light) || light.status == LIGHT_BROKEN, "The Faithless did not smash the light")

	// A knocked out human gets picked by the AI and grabbed instead of hit
	controller.CancelActions()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	victim.Unconscious(20 SECONDS)
	victim.set_stat(UNCONSCIOUS)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The Faithless AI did not go for the knocked out human")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)], "The Faithless AI did not plan to attack the knocked out human")
	aquila_ai_melee_once(controller)
	TEST_ASSERT_EQUAL(faithless.pulling, victim, "The Faithless did not drag the knocked out human")

/// A player Faithless pries an airlock open outside combat mode and beats on it in combat mode, in both control modes
/datum/unit_test/aquila_faithless_pries_doors

/datum/unit_test/aquila_faithless_pries_doors/Run()
	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/mob/living/basic/faithless/faithless = allocate(legacy ? /mob/living/basic/faithless/legacy_intents_test : /mob/living/basic/faithless, run_loc_floor_bottom_left)
		faithless.ai_controller.set_ai_status(AI_STATUS_OFF)
		var/obj/machinery/door/airlock/airlock = allocate(/obj/machinery/door/airlock, get_step(run_loc_floor_bottom_left, EAST))

		if(legacy)
			faithless.a_intent_change(INTENT_HARM)
		else
			faithless.set_combat_mode(TRUE)
		faithless.next_click = 0
		faithless.next_move = 0
		var/integrity = airlock.obj_integrity
		faithless.ClickOn(airlock, "icon-x=16;icon-y=16;left=1;button=left")
		TEST_ASSERT(airlock.obj_integrity < integrity, "[mode]: the Faithless in combat did not beat on the airlock")
		TEST_ASSERT(airlock.density, "[mode]: the Faithless in combat opened the airlock")

		if(legacy)
			faithless.a_intent_change(INTENT_HELP)
		else
			faithless.set_combat_mode(FALSE)
		faithless.next_click = 0
		faithless.next_move = 0
		faithless.ClickOn(airlock, "icon-x=16;icon-y=16;left=1;button=left")
		var/waited = 0
		while(airlock.density && waited < 30)
			sleep(1)
			waited++
		TEST_ASSERT(!airlock.density, "[mode]: the Faithless did not open the airlock outside combat")
		qdel(airlock)
		qdel(faithless)

	// A powered airlock it has no access to gets pried open (and damaged) after a while; a bolted one stays shut
	var/mob/living/basic/faithless/pryer = allocate(/mob/living/basic/faithless, run_loc_floor_bottom_left)
	pryer.ai_controller.set_ai_status(AI_STATUS_OFF)
	pryer.RemoveElement(/datum/element/door_pryer)
	pryer.AddElement(/datum/element/door_pryer, 0.5 SECONDS)
	pryer.set_combat_mode(FALSE)
	var/obj/machinery/door/airlock/no_access = allocate(/obj/machinery/door/airlock, get_step(run_loc_floor_bottom_left, EAST))
	no_access.protected_door = TRUE // powered, so neither the no power branch nor allowed() opens it
	no_access.req_access = list(ACCESS_CAPTAIN)
	TEST_ASSERT(!no_access.allowed(pryer), "The Faithless has access to the captain's airlock")
	var/door_integrity = no_access.obj_integrity
	pryer.next_click = 0
	pryer.next_move = 0
	pryer.ClickOn(no_access, "icon-x=16;icon-y=16;left=1;button=left")
	var/pry_wait = 0
	while((no_access.density || no_access.obj_integrity >= door_integrity) && pry_wait < 40)
		sleep(1)
		pry_wait++
	TEST_ASSERT(!no_access.density, "The Faithless did not pry open an airlock it has no access to")
	TEST_ASSERT(no_access.obj_integrity < door_integrity, "Prying the airlock open did not damage it")
	qdel(no_access)

	var/obj/machinery/door/airlock/bolted = allocate(/obj/machinery/door/airlock, get_step(run_loc_floor_bottom_left, EAST))
	bolted.req_access = list(ACCESS_CAPTAIN)
	bolted.bolt() // before protected_door: bolt() does nothing on a protected door
	bolted.protected_door = TRUE
	TEST_ASSERT(bolted.locked, "The test airlock did not bolt")
	var/bolted_integrity = bolted.obj_integrity
	pryer.next_click = 0
	pryer.next_move = 0
	pryer.ClickOn(bolted, "icon-x=16;icon-y=16;left=1;button=left")
	sleep(20)
	TEST_ASSERT(bolted.density, "The Faithless pried open a bolted airlock")
	TEST_ASSERT_EQUAL(bolted.obj_integrity, bolted_integrity, "The Faithless pried at a bolted airlock")

/mob/living/basic/faithless/legacy_intents_test

/mob/living/basic/faithless/legacy_intents_test/uses_legacy_intents()
	return TRUE

/// The space dolphin bites back the one who hit it (tiring them out), the space lasso still catches it and a ghost
/// playing it bites with a click in both control modes
/datum/unit_test/aquila_dolphin

/datum/unit_test/aquila_dolphin/Run()
	var/mob/living/basic/dolphin/dolphin = allocate(/mob/living/basic/dolphin, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = dolphin.ai_controller
	TEST_ASSERT(dolphin.playable, "Ghosts cannot take the dolphin over")
	TEST_ASSERT(dolphin.spacewalk, "The space dolphin cannot swim through space")

	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The dolphin attacks without being hit")
	puncher.set_combat_mode(TRUE)
	dolphin.attack_hand(puncher)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "The dolphin did not go for the one who hit it")
	controller.SelectBehaviors(1)
	aquila_ai_melee_once(controller)
	TEST_ASSERT(puncher.getStaminaLoss() > 0, "The dolphin bite did not tire the human")

	var/obj/item/mob_lasso/lasso = allocate(/obj/item/mob_lasso)
	TEST_ASSERT(lasso.check_allowed(dolphin), "The space lasso does not catch the basic dolphin")

	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/mob/living/basic/dolphin/player = allocate(legacy ? /mob/living/basic/dolphin/legacy_intents_test : /mob/living/basic/dolphin, get_step(run_loc_floor_bottom_left, NORTH))
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTHEAST))
		TEST_ASSERT(player.combat_mode_indicator, "[mode]: the playable dolphin has no combat mode indicator")
		var/health_before = target.health
		if(legacy)
			player.a_intent_change(INTENT_HARM)
		else
			player.set_combat_mode(TRUE)
		player.next_click = 0
		player.next_move = 0
		player.ClickOn(target, "icon-x=16;icon-y=16;left=1;button=left")
		TEST_ASSERT(target.health < health_before, "[mode]: the player dolphin did not bite")
		qdel(player)
		qdel(target)

/mob/living/basic/dolphin/legacy_intents_test

/mob/living/basic/dolphin/legacy_intents_test/uses_legacy_intents()
	return TRUE

/// The empty simple_animal/pet base is gone: the animal gibspawner takes its blood from a basic pet now
/datum/unit_test/aquila_animal_gibs_without_simple_pet

/datum/unit_test/aquila_animal_gibs_without_simple_pet/Run()
	var/turf/spot = get_step(run_loc_floor_bottom_left, NORTHEAST)
	var/list/before = list()
	for(var/obj/effect/decal/cleanable/blood/gibs/gib in range(7, spot))
		before += gib
	new /obj/effect/gibspawner/generic/animal(spot)
	var/list/gibs = list()
	for(var/obj/effect/decal/cleanable/blood/gibs/gib in range(7, spot))
		if(!(gib in before))
			gibs += gib
	TEST_ASSERT(length(gibs), "The animal gibspawner made no gibs")
	for(var/obj/effect/decal/cleanable/gib as anything in gibs)
		qdel(gib)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
