// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_LEFT_CLICK "icon-x=16;icon-y=16;left=1;button=left"
#define RIGHT_CLICK_PARAMS "icon-x=16;icon-y=16;right=1;button=right"

/// AQUILA: basic mobs driven by real player clicks (ClickOn), in both control modes: combat mode and the legacy intents.
/// Calling attackby() or the component procs directly skips the click chain, so these catch what a player actually hits.
/datum/unit_test/aquila_basic_clicks

/// Click as the player; mode "combat" toggles combat mode, mode "legacy" uses the four intents
/datum/unit_test/aquila_basic_clicks/proc/click(mob/living/carbon/human/user, atom/target, harm = FALSE, right = FALSE)
	if(user.uses_legacy_intents())
		user.a_intent_change(harm ? INTENT_HARM : (right ? INTENT_DISARM : INTENT_HELP))
	else
		user.set_combat_mode(harm, silent = TRUE)
	user.next_click = 0
	user.next_move = 0
	// The legacy controls turn the disarm intent into a right click
	user.ClickOn(target, (right && !user.uses_legacy_intents()) ? RIGHT_CLICK_PARAMS : TEST_LEFT_CLICK)

/datum/unit_test/aquila_basic_clicks/proc/make_user(legacy, turf/where)
	return allocate(legacy ? /mob/living/carbon/human/legacy_intents_test : /mob/living/carbon/human, where)

/datum/unit_test/aquila_basic_clicks/Run()
	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/turf/start = run_loc_floor_bottom_left
		var/mob/living/carbon/human/user = make_user(legacy, start)

		// Feeding a dog a bone from the hand tames it (30% + 15% a try, so ten bones are always enough)
		var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(start, EAST))
		corgi.ai_controller.set_ai_status(AI_STATUS_OFF)
		var/tries = 0
		while(!(user in corgi.ai_controller.blackboard[BB_FRIENDS_LIST]) && tries < 10)
			tries++
			var/obj/item/stack/sheet/bone/bone = allocate(/obj/item/stack/sheet/bone, start)
			user.put_in_active_hand(bone)
			click(user, corgi)
			TEST_ASSERT(QDELETED(bone) || bone.loc != user, "[mode]: the corgi did not eat a bone from the hand")
		TEST_ASSERT(user in corgi.ai_controller.blackboard[BB_FRIENDS_LIST], "[mode]: ten bones from the hand did not tame the corgi")
		TEST_ASSERT(corgi.health == corgi.maxHealth, "[mode]: feeding hurt the corgi")

		// Commands: spoken and the Alt+click menu
		user.say("za mną")
		TEST_ASSERT(istype(corgi.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/follow), "[mode]: the tamed corgi ignored the spoken follow command")
		TEST_ASSERT(SEND_SIGNAL(corgi, COMSIG_CLICK_ALT, user) & COMPONENT_INTERCEPT_ALT, "[mode]: Alt+click does not open the command menu for the owner")

		// Petting with an empty hand does not hurt, a harmful click does
		user.drop_all_held_items()
		click(user, corgi)
		TEST_ASSERT(corgi.health == corgi.maxHealth, "[mode]: petting hurt the corgi")
		click(user, corgi, harm = TRUE)
		TEST_ASSERT(corgi.health < corgi.maxHealth, "[mode]: a harmful click did not hurt the corgi")

		// Wheat tames a cow, a beaker milks it
		var/mob/living/basic/cow/cow = allocate(/mob/living/basic/cow, get_step(start, NORTH))
		cow.ai_controller.set_ai_status(AI_STATUS_OFF)
		tries = 0
		while(!(user in cow.ai_controller.blackboard[BB_FRIENDS_LIST]) && tries < 10)
			tries++
			var/obj/item/food/grown/wheat/wheat = allocate(/obj/item/food/grown/wheat, start)
			user.put_in_active_hand(wheat)
			click(user, cow)
		TEST_ASSERT(user in cow.ai_controller.blackboard[BB_FRIENDS_LIST], "[mode]: ten wheat stalks from the hand did not tame the cow")
		user.drop_all_held_items()
		var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker, start)
		user.put_in_active_hand(beaker)
		click(user, cow)
		TEST_ASSERT(beaker.reagents.total_volume > 0, "[mode]: clicking a cow with a beaker did not milk it")
		TEST_ASSERT(cow.health == cow.maxHealth, "[mode]: milking hurt the cow")
		user.drop_all_held_items()

		// Bear armor goes on the bear instead of hitting it
		var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, get_step(start, NORTHEAST))
		bear.ai_controller.set_ai_status(AI_STATUS_OFF)
		var/obj/item/bear_armor/armor = allocate(/obj/item/bear_armor, start)
		user.put_in_active_hand(armor)
		var/bear_health = bear.health
		click(user, bear)
		TEST_ASSERT(bear.armored, "[mode]: clicking a bear with bear armor did not armor it")
		TEST_ASSERT(bear.health >= bear_health, "[mode]: bear armor hit the bear")
		TEST_ASSERT(!(user in bear.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]), "[mode]: putting armor on made the bear retaliate")

		// Lasso: a ranged click catches the mob, a second click next to it ties it up and tames it
		var/mob/living/basic/goat/goat = allocate(/mob/living/basic/goat, locate(start.x + 3, start.y, start.z))
		var/obj/item/mob_lasso/antag/debug/lasso = allocate(/obj/item/mob_lasso/antag/debug, start)
		user.put_in_active_hand(lasso)
		click(user, goat)
		TEST_ASSERT(lasso.mob_target == goat, "[mode]: a ranged lasso click did not catch the goat")
		// The lasso throws the mob at the user (the throw starts on the next tick); wait until it lands, like a player would
		sleep(1 SECONDS)
		var/land_until = world.time + 3 SECONDS
		while(world.time < land_until && goat.throwing)
			sleep(1)
		if(!goat.Adjacent(user))
			goat.forceMove(get_step(user, NORTH))
		click(user, goat)
		var/wait_until = world.time + 3 SECONDS
		while(world.time < wait_until && lasso.mob_target)
			sleep(1)
		TEST_ASSERT(user in goat.ai_controller?.blackboard[BB_FRIENDS_LIST], "[mode]: untying the lassoed goat did not tame it")
		user.say("za mną")
		TEST_ASSERT(istype(goat.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/follow), "[mode]: the lassoed goat ignored the spoken follow command")

		for(var/atom/movable/thing as anything in list(user, corgi, cow, bear, goat, lasso, beaker))
			if(!QDELETED(thing))
				qdel(thing)

#undef TEST_LEFT_CLICK
#undef RIGHT_CLICK_PARAMS
#undef TEST_ASSERT
