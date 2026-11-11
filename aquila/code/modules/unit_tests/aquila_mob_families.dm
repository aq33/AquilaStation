// AQUILA - basic mob families of part 2 (tg 926bf40c5a): hivebots, goose, simple xenomorphs, carp.
// The AI is exercised through the controller (SelectBehaviors / ProcessBehavior); the framework test mobs and helpers
// (aquila_bullet_recorder, aquila_wait_for_hit) are in aquila_mob_abilities.dm.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define LEFT_CLICK "icon-x=16;icon-y=16;left=1;button=left"

/// Records what a mob says
/datum/aquila_say_recorder
	var/list/messages = list()

/datum/aquila_say_recorder/proc/on_say(datum/source, list/speech_args)
	SIGNAL_HANDLER
	messages += speech_args[SPEECH_MESSAGE]

/// Hivebots: the ranged ones shoot their target through the AI (and a player in one shoots by clicking), the plain one
/// claws, a dead hivebot falls apart into debris, and they beep binary at each other although they are silent mobs
/datum/unit_test/aquila_hivebot_family

/datum/unit_test/aquila_hivebot_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)

	// Ranged hivebots shoot a human three tiles away
	for(var/shooter_type in list(/mob/living/basic/hivebot/range, /mob/living/basic/hivebot/rapid, /mob/living/basic/hivebot/strong))
		var/mob/living/basic/hivebot/shooter = allocate(shooter_type, corner)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 3, corner.y, corner.z))
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		var/datum/ai_controller/controller = shooter.ai_controller
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, find_target)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "[shooter_type] did not pick the human three tiles away")
		controller.SelectBehaviors(1)
		var/shoot_type = shooter_type == /mob/living/basic/hivebot/rapid ? /datum/ai_behavior/basic_ranged_attack/hivebot_rapid : /datum/ai_behavior/basic_ranged_attack/hivebot
		var/datum/ai_behavior/shoot = GET_AI_BEHAVIOR(shoot_type)
		TEST_ASSERT(controller.current_behaviors[shoot], "[shooter_type] with a target did not plan its ranged attack")
		var/health_before = victim.health
		controller.ProcessBehavior(1, shoot)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[shooter_type]: the shot did not hit the human")
		TEST_ASSERT(istype(recorder.projectiles[1], /obj/item/projectile/hivebotbullet), "[shooter_type] did not fire a hivebot bullet")
		TEST_ASSERT(victim.health < health_before, "[shooter_type]: the shot did not hurt")
		controller.CancelActions()

		// A ghost in the hivebot shoots by clicking the far human
		controller.set_ai_status(AI_STATUS_OFF)
		recorder.projectiles.Cut()
		var/datum/component/ranged_attacks/ranged = shooter.GetComponent(/datum/component/ranged_attacks)
		COOLDOWN_RESET(ranged, fire_cooldown)
		shooter.next_click = 0
		shooter.next_move = 0
		shooter.ClickOn(victim, LEFT_CLICK)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[shooter_type]: a player click on a far target did not shoot")
		qdel(recorder)
		qdel(shooter)
		qdel(victim)

	// The plain hivebot has no gun and claws
	var/mob/living/basic/hivebot/clawer = allocate(/mob/living/basic/hivebot, corner)
	TEST_ASSERT(!clawer.GetComponent(/datum/component/ranged_attacks), "The plain hivebot has a gun")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(corner, EAST))
	var/datum/ai_controller/controller = clawer.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_target)
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	TEST_ASSERT(controller.current_behaviors[melee], "The plain hivebot did not plan a melee attack")
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	clawer.next_move = 0
	clawer.next_click = 0
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The plain hivebot did not claw the human")
	controller.CancelActions()
	qdel(victim)

	// Hive chatter: a silent hivebot still beeps binary at its partner
	var/mob/living/basic/hivebot/partner = allocate(/mob/living/basic/hivebot, get_step(corner, NORTH))
	TEST_ASSERT(!clawer.should_talk, "The hivebot is not a silent mob any more")
	var/datum/aquila_say_recorder/speech = new
	speech.RegisterSignal(clawer, COMSIG_MOB_SAY, TYPE_PROC_REF(/datum/aquila_say_recorder, on_say))
	controller.set_blackboard_key("BB_hive_partner", partner)
	controller.queue_behavior(/datum/ai_behavior/relay_message, "BB_hive_partner")
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/relay_message))
	TEST_ASSERT(length(speech.messages), "The hivebot did not beep at its partner")
	var/beep = speech.messages[1]
	var/digits = copytext(beep, 1, 5)
	TEST_ASSERT(length(digits) == 4 && !length(replacetext(replacetext(digits, "0", ""), "1", "")), "The hivebot said [beep] instead of four binary digits")
	TEST_ASSERT(!clawer.should_talk, "Beeping left the hivebot able to talk")
	qdel(speech)

	// Death: it falls apart into robot debris
	var/turf/death_turf = get_turf(clawer)
	clawer.death()
	TEST_ASSERT(QDELETED(clawer), "A dead hivebot was not deleted")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/robot_debris) in death_turf, "A dead hivebot left no robot debris")

/// Goose: the AI finds food right next to it and gobbles it up (and ignores other junk), plastic chokes it to death,
/// a player feeds it by hand; Birdboat keeps what it eats and throws it all up through its ability, used by the AI
/datum/unit_test/aquila_goose_family

/datum/unit_test/aquila_goose_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/goose/goose = allocate(/mob/living/basic/goose, corner)
	var/datum/ai_controller/controller = goose.ai_controller
	// Keep it calm: no random anger during the test
	controller.set_blackboard_key(BB_RANDOM_AGGRO_CHANCE, 0.0001) // 0 falls back to the default
	var/obj/item/wrench/junk = allocate(/obj/item/wrench, get_step(corner, NORTH))
	var/obj/item/food/cookie/cookie = allocate(/obj/item/food/cookie, get_step(corner, EAST))
	var/datum/ai_behavior/find_food = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list/goose_food)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)

	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[find_food], "The goose did not plan to look for food")
	controller.ProcessBehavior(1, find_food)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], cookie, "The goose did not go for the cookie next to it (or went for the wrench)")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[melee], "The goose with food in sight did not plan to peck at it")
	controller.ProcessBehavior(1, melee) // the first run only sets the attack delay
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	goose.next_move = 0
	goose.next_click = 0
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(QDELETED(cookie), "The goose did not eat the cookie")
	TEST_ASSERT(!QDELETED(junk) && junk.loc == get_step(corner, NORTH), "The goose ate or moved the wrench")
	controller.CancelActions()

	// Plastic: the goose chokes on it and dies when the choking runs out
	var/obj/item/stack/sheet/plastic/plastic = allocate(/obj/item/stack/sheet/plastic, get_step(corner, EAST))
	TEST_ASSERT(goose_is_plastic(plastic), "A plastic sheet does not count as plastic")
	controller.set_blackboard_key(BB_NEXT_FOOD_EAT, 0)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_food)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], plastic, "The goose did not go for the plastic")
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	goose.next_move = 0
	goose.next_click = 0
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(plastic.loc == goose, "The goose did not swallow the plastic")
	var/datum/status_effect/goose_choking/choking = goose.has_status_effect(/datum/status_effect/goose_choking)
	TEST_ASSERT(choking, "The goose is not choking on the plastic")
	TEST_ASSERT(controller.blackboard[BB_GOOSE_PANICKED], "A choking goose does not panic")
	controller.CancelActions()
	controller.set_blackboard_key(BB_NEXT_FOOD_EAT, 0)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[find_food], "A choking goose looks for more food")
	choking.duration = world.time - 1
	choking.process()
	TEST_ASSERT_EQUAL(goose.stat, DEAD, "The goose did not die when the choking ran out")
	TEST_ASSERT(plastic.loc != goose, "The dead goose kept the plastic inside")

	// A player feeds Birdboat by hand (no combat mode); it keeps the food inside
	var/mob/living/basic/goose/vomit/birdboat = allocate(/mob/living/basic/goose/vomit, locate(corner.x + 2, corner.y + 2, corner.z))
	var/datum/ai_controller/boat_controller = birdboat.ai_controller
	boat_controller.set_ai_status(AI_STATUS_OFF)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human, get_step(birdboat, WEST))
	feeder.set_combat_mode(FALSE, silent = TRUE)
	for(var/i in 1 to 3)
		var/obj/item/food/badrecipe/slop = allocate(/obj/item/food/badrecipe)
		feeder.put_in_active_hand(slop)
		feeder.next_click = 0
		feeder.next_move = 0
		feeder.ClickOn(birdboat, LEFT_CLICK)
		TEST_ASSERT(slop.loc == birdboat, "Birdboat did not eat the slop a player fed it")
	TEST_ASSERT_EQUAL(boat_controller.blackboard[BB_GOOSE_VOMIT_CHANCE], 9, "Gross food did not make Birdboat more likely to throw up")

	// The AI throws up: the vomit ability is used and everything comes back out
	boat_controller.set_ai_status(AI_STATUS_ON)
	boat_controller.set_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 100)
	var/datum/action/cooldown/mob_cooldown/goose_vomit/vomit = birdboat.vomit_action
	TEST_ASSERT(vomit.IsAvailable(), "Birdboat with a full stomach cannot throw up")
	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/use_mob_ability)
	boat_controller.SelectBehaviors(1)
	TEST_ASSERT(boat_controller.current_behaviors[use_ability], "Birdboat about to throw up did not plan to use its ability")
	boat_controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT(vomit.next_use_time > world.time, "The vomit ability was not used")
	var/wait_until = world.time + 10 SECONDS
	while(world.time < wait_until && length(birdboat.contents))
		sleep(1)
	TEST_ASSERT(!length(birdboat.contents), "Birdboat did not throw everything up")
	wait_until = world.time + 3 SECONDS // the status notices the empty stomach on its next tick
	while(world.time < wait_until && birdboat.has_status_effect(/datum/status_effect/goose_vomit))
		sleep(1)
	TEST_ASSERT(!birdboat.has_status_effect(/datum/status_effect/goose_vomit), "Birdboat kept throwing up with an empty stomach")
	TEST_ASSERT(!vomit.IsAvailable(), "The vomit ability is available with an empty stomach")
	TEST_ASSERT(vomit.next_use_time <= world.time, "The vomit ability stayed on cooldown after throwing up")

#undef LEFT_CLICK
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
