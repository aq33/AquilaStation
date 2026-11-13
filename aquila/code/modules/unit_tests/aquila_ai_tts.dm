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

/// Ogłoszenie, którego syntezator nie odtworzył, oddaje znaki i nie blokuje następnego
/datum/unit_test/aquila_ai_tts_failure_refund

/datum/unit_test/aquila_ai_tts_failure_refund/Run()
	var/mob/living/carbon/human/brain_holder = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/silicon/ai/ai = allocate(/mob/living/silicon/ai, run_loc_floor_bottom_left, null, brain_holder)
	var/old_endpoint = CONFIG_GET(string/squad_tts_endpoint)
	var/old_timeout = CONFIG_GET(number/squad_tts_timeout)
	var/old_limit = CONFIG_GET(number/squad_tts_round_char_limit)
	var/old_used = GLOB.squad_tts_chars_used
	var/old_next = GLOB.aq_ai_tts_next_announcement
	// port 9 na localhost odrzuca połączenie, więc zapytanie kończy się błędem bez sieci
	CONFIG_SET(string/squad_tts_endpoint, "http://127.0.0.1:9")
	CONFIG_SET(number/squad_tts_timeout, 3)
	CONFIG_SET(number/squad_tts_round_char_limit, 100)
	GLOB.squad_tts_chars_used = 0
	var/message = "Uwaga, test"
	squad_tts_reserve_chars(message)
	var/next_announcement = world.time + 60 SECONDS
	GLOB.aq_ai_tts_next_announcement = next_announcement
	ai.aq_tts_announce(message, list(), next_announcement)
	var/used_after = GLOB.squad_tts_chars_used
	var/next_after = GLOB.aq_ai_tts_next_announcement
	CONFIG_SET(string/squad_tts_endpoint, old_endpoint)
	CONFIG_SET(number/squad_tts_timeout, old_timeout)
	CONFIG_SET(number/squad_tts_round_char_limit, old_limit)
	GLOB.squad_tts_chars_used = old_used
	GLOB.aq_ai_tts_next_announcement = old_next
	TEST_ASSERT(used_after == 0, "Nieudane ogłoszenie zostawiło [used_after] zużytych znaków")
	TEST_ASSERT(next_after <= world.time, "Nieudane ogłoszenie dalej blokuje następne")

#undef TEST_ASSERT
