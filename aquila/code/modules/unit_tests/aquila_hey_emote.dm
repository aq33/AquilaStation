// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - *hey: człowiek krzyczy z dźwiękiem, mim krzyczy bez dźwięku
/datum/unit_test/aquila_hey_emote

/datum/unit_test/aquila_hey_emote/Run()
	var/datum/emote/living/carbon/human/hey/hey = GLOB.emote_list["hey"]?[1]
	TEST_ASSERT(istype(hey), "There is no *hey emote")
	var/mob/living/carbon/human/shouter = allocate(/mob/living/carbon/human)
	TEST_ASSERT(hey.can_run_emote(shouter, intentional = TRUE), "A human can't run *hey")
	TEST_ASSERT(hey.get_sound(shouter) == 'aquila/sound/emotes/hey.ogg', "*hey has no sound for a human")
	TEST_ASSERT(shouter.emote("hey", intentional = TRUE), "*hey did not run")

#undef TEST_ASSERT
