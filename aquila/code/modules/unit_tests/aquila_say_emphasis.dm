// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wyróżnienia mowy nie dotykają znaczników: _podkreślenie_ parowało się z podkreślnikiem w klasie "command_headset"
/datum/unit_test/aquila_say_emphasis

/datum/unit_test/aquila_say_emphasis/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human)

	var/message = listener.compose_message(speaker, /datum/language/common, "+a+ _b_ |c|", null, list(SPAN_COMMAND), list())
	TEST_ASSERT(findtext(message, "<b>a</b>"), "Bold emphasis missing: [html_encode(message)]")
	TEST_ASSERT(findtext(message, "<u>b</u>"), "Underline emphasis missing: [html_encode(message)]")
	TEST_ASSERT(findtext(message, "<i>c</i>"), "Italics emphasis missing: [html_encode(message)]")
	TEST_ASSERT(findtext(message, "<span class='[SPAN_COMMAND] '>"), "The [SPAN_COMMAND] span class was broken: [html_encode(message)]")
	TEST_ASSERT(!findtext(message, "command<u>"), "Underline paired with the underscore in a class name: [html_encode(message)]")

	// Bez znaczników wynik się nie zmienia
	TEST_ASSERT(speaker.say_emphasis("+a+ _b_ |c|") == "<b>a</b> <u>b</u> <i>c</i>", "Plain text emphasis changed")

#undef TEST_ASSERT
