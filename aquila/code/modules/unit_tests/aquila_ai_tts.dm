// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Ogłoszenia SI i rozkazy drużyn dzielą budżet znaków TTS na rundę
/datum/unit_test/aquila_ai_tts_char_budget

/datum/unit_test/aquila_ai_tts_char_budget/Run()
	var/old_limit = CONFIG_GET(number/squad_tts_round_char_limit)
	var/old_used = GLOB.squad_tts_chars_used
	CONFIG_SET(number/squad_tts_round_char_limit, 10)
	GLOB.squad_tts_chars_used = 0
	var/first = squad_tts_reserve_chars("Uwaga")
	var/used_after_first = GLOB.squad_tts_chars_used
	var/second = squad_tts_reserve_chars("Ewakuacja")
	var/used_after_second = GLOB.squad_tts_chars_used
	CONFIG_SET(number/squad_tts_round_char_limit, old_limit)
	GLOB.squad_tts_chars_used = old_used
	TEST_ASSERT(first, "Pięć znaków nie zmieściło się w limicie 10")
	TEST_ASSERT(used_after_first == 5, "Po ogłoszeniu 5 znaków licznik pokazuje [used_after_first]")
	TEST_ASSERT(!second, "Ogłoszenie przekraczające limit przeszło")
	TEST_ASSERT(used_after_second == 5, "Odrzucone ogłoszenie zużyło znaki (licznik [used_after_second])")

#undef TEST_ASSERT
