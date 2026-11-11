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

#undef LEFT_CLICK
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
