// AQUILA - basic mobs part 2, "rest" group (tg 926bf40c5a): mimics, venus human trap, Netherworld, clowns, fugu, lightgeist,
// space dragon. The AI is driven through its controller (SelectBehaviors/ProcessBehavior), player clicks through ClickOn().
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
#define RIGHT_CLICK_PARAMS "icon-x=16;icon-y=16;right=1;button=right"

/// Lets the controller plan and run one behaviour of the given type; returns TRUE if it was planned
/proc/aquila_rest_run_behavior(datum/ai_controller/controller, behavior_type)
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/behavior = GET_AI_BEHAVIOR(behavior_type)
	if(!controller.current_behaviors[behavior])
		return FALSE
	controller.ProcessBehavior(1, behavior)
	return TRUE

/// Clicks as a player in a basic mob, in combat mode or with the legacy intents
/proc/aquila_rest_click(mob/living/clicker, atom/target, harm = FALSE, right = FALSE)
	if(clicker.uses_legacy_intents())
		clicker.a_intent_change(harm ? INTENT_HARM : (right ? INTENT_DISARM : INTENT_HELP))
	else
		clicker.set_combat_mode(harm, silent = TRUE)
	clicker.next_click = 0
	clicker.next_move = 0
	clicker.ClickOn(target, (right && !clicker.uses_legacy_intents()) ? RIGHT_CLICK_PARAMS : LEFT_CLICK)

/// The lightgeist with the legacy intents
/mob/living/basic/lightgeist/aquila_legacy

/mob/living/basic/lightgeist/aquila_legacy/uses_legacy_intents()
	return TRUE

/// A lightgeist's AI goes for a hurt mob and heals it (healing_touch), leaves healthy ones alone;
/// a player lightgeist heals by clicking, in both control modes
/datum/unit_test/aquila_lightgeist_heals

/datum/unit_test/aquila_lightgeist_heals/Run()
	var/mob/living/basic/lightgeist/geist = allocate(/mob/living/basic/lightgeist, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = geist.ai_controller

	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The lightgeist did not look for patients")
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The lightgeist picked a healthy human")

	patient.adjustBruteLoss(20)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], patient, "The lightgeist did not pick the hurt human")
	var/brute_before = patient.getBruteLoss()
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	geist.next_move = 0
	geist.next_click = 0
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The lightgeist did not go for its patient")
	TEST_ASSERT(patient.getBruteLoss() < brute_before, "The lightgeist's AI did not heal the patient")
	TEST_ASSERT(patient in controller.blackboard[BB_FRIENDS_LIST], "The healed human did not become the lightgeist's friend")
	controller.CancelActions()

	for(var/legacy in list(FALSE, TRUE))
		var/mob/living/basic/lightgeist/player = allocate(legacy ? /mob/living/basic/lightgeist/aquila_legacy : /mob/living/basic/lightgeist, get_step(run_loc_floor_bottom_left, NORTH))
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		TEST_ASSERT(player.combat_mode_indicator, "A playable lightgeist has no combat mode indicator")
		for(var/harm in list(FALSE, TRUE))
			patient.adjustFireLoss(10)
			var/burn_before = patient.getFireLoss()
			aquila_rest_click(player, patient, harm)
			TEST_ASSERT(patient.getFireLoss() < burn_before, "[legacy ? "legacy intents" : "combat mode"], [harm ? "harm" : "help"]: a player lightgeist did not heal by clicking")
		qdel(player)

/// A Netherworld creature finds and hits a human through its AI and hits harder when hurt (health_scaling_effects);
/// its teleport is not blocked when nobody sees it (unobserved_actor); the blank body scales too
/datum/unit_test/aquila_netherworld_creatures

/datum/unit_test/aquila_netherworld_creatures/Run()
	var/mob/living/basic/creature/creature = allocate(/mob/living/basic/creature, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = creature.ai_controller
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The creature did not look for targets")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The creature did not pick the human next to it")
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	creature.next_move = 0
	creature.next_click = 0
	var/brute_before = victim.getBruteLoss()
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The creature did not go for its target")
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The creature's AI attack did not hurt the human")
	controller.CancelActions()

	var/full_damage = creature.melee_damage
	creature.adjustBruteLoss(creature.maxHealth * 0.8)
	sleep(1) // the stats update asynchronously
	TEST_ASSERT(creature.melee_damage > full_damage, "A hurt creature does not hit harder")
	creature.adjustBruteLoss(-creature.maxHealth)
	sleep(1)
	TEST_ASSERT_EQUAL(creature.melee_damage, full_damage, "A healed creature kept the extra damage")

	var/datum/component/unobserved_actor/blocker = creature.GetComponent(/datum/component/unobserved_actor)
	TEST_ASSERT(blocker, "The creature's teleport has no unobserved actor component")
	var/datum/action/cooldown/spell/jaunt/creature_teleport/teleport = locate() in creature.actions
	TEST_ASSERT(teleport, "The creature has no teleport")
	TEST_ASSERT(!(SEND_SIGNAL(creature, COMSIG_MOB_BEFORE_SPELL_CAST, teleport, creature) & SPELL_CANCEL_CAST), "The teleport was blocked although no player sees the creature")

	var/mob/living/basic/blankbody/blank = allocate(/mob/living/basic/blankbody, get_step(run_loc_floor_bottom_left, NORTH))
	var/blank_damage = blank.melee_damage
	blank.adjustBruteLoss(blank.maxHealth * 0.8)
	sleep(1)
	TEST_ASSERT(blank.melee_damage > blank_damage, "A hurt blank body does not hit harder")

// --- end of the "rest" group tests
#undef LEFT_CLICK
#undef RIGHT_CLICK_PARAMS
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
