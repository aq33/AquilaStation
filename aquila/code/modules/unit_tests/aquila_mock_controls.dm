// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define LEFT_CLICK_PARAMS "icon-x=16;icon-y=16;left=1;button=left"
#define CTRL_CLICK_PARAMS "icon-x=16;icon-y=16;left=1;button=left;ctrl=1"

/**
 * Gives a mob without a player the control mode of a player: combat mode or the legacy intents.
 *
 * Works for any mob type through the mock client (GET_CLIENT), so a test does not need a subtype
 * overriding uses_legacy_intents() for every mob it clicks with. Returns the mock client.
 */
/datum/unit_test/proc/set_test_controls(mob/user, legacy)
	var/datum/client_interface/mock = user.mock_client
	if(!mock)
		mock = new
		mock.prefs = new /datum/preferences
		user.mock_client = mock
	// A player always has a mind, and parts of the click chain read it (CtrlClick on a human: mind.martial_art)
	user.mind_initialize()
	if(legacy)
		mock.prefs.chat_toggles |= CHAT_LEGACY_INTENTS
	else
		mock.prefs.chat_toggles &= ~CHAT_LEGACY_INTENTS
	user.sync_intent_with_combat_mode()
	return mock

/// AQUILA: the mock client picks the control mode, and a real ClickOn grabs a mob in both modes
/// (combat mode: Ctrl+click, legacy intents: the grab intent and a plain left click)
/datum/unit_test/aquila_mock_controls

/datum/unit_test/aquila_mock_controls/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(!user.uses_legacy_intents(), "A mob without a client uses the legacy controls")

	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		set_test_controls(user, legacy)
		TEST_ASSERT(user.uses_legacy_intents() == legacy, "[mode]: the mock client did not set the control mode")
		user.stop_pulling()
		user.next_click = 0
		user.next_move = 0
		if(legacy)
			user.a_intent_change(INTENT_GRAB)
			user.ClickOn(victim, LEFT_CLICK_PARAMS)
		else
			user.ClickOn(victim, CTRL_CLICK_PARAMS)
		TEST_ASSERT(user.pulling == victim, "[mode]: the grab click did not grab the other human")

	// The disarm intent is the secondary action only in the legacy controls
	user.a_intent_change(INTENT_DISARM)
	TEST_ASSERT(user.is_secondary_click(LEFT_CLICK_PARAMS), "legacy intents: a disarm click is not the secondary action")
	set_test_controls(user, FALSE)
	TEST_ASSERT(!user.is_secondary_click(LEFT_CLICK_PARAMS), "combat mode: a left click is the secondary action")
	user.stop_pulling()
	user.mock_client = null

#undef TEST_ASSERT
#undef LEFT_CLICK_PARAMS
#undef CTRL_CLICK_PARAMS

