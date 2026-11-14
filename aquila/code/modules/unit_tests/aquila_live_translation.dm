// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/**
 * Tłumaczenie na żywo (live_translation.dm): obcokrajowiec od razu dostaje polski oryginał, a tłumaczenie przychodzi potem.
 * Bez sieci: klucz API jest udawany, a zapytanie wisi w SStranslation.pending, więc wynik podajemy ręcznie.
 */
/datum/unit_test/aquila_live_translation
	var/heard_language
	var/heard_raw
	var/list/heard_mods
	var/old_key
	var/old_can_fire

/datum/unit_test/aquila_live_translation/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	heard_language = hearing_args[3]
	heard_raw = hearing_args[HEARING_RAW_MESSAGE]
	heard_mods = hearing_args[7]

/// Zapytanie, które translate() zastanie w toku: dopisze do niego callback i nie pójdzie do sieci
/datum/unit_test/aquila_live_translation/proc/fake_job(text)
	var/datum/translation_job/job = new
	job.texts = list(text)
	job.source_lang = DEEPL_LANG_PL
	job.target_lang = DEEPL_LANG_EN
	job.started = world.time
	SStranslation.pending["[DEEPL_LANG_PL]>[DEEPL_LANG_EN]|[json_encode(list(text))]"] = job
	return job

/datum/unit_test/aquila_live_translation/proc/finish_job(datum/translation_job/job, list/translations)
	for(var/key in SStranslation.pending)
		if(SStranslation.pending[key] == job)
			SStranslation.pending -= key
			break
	for(var/datum/callback/callback as anything in job.callbacks)
		callback.Invoke(translations)

/datum/unit_test/aquila_live_translation/Run()
	old_key = CONFIG_GET(string/deepl_api_key)
	old_can_fire = SStranslation.can_fire
	SStranslation.can_fire = FALSE
	CONFIG_SET(string/deepl_api_key, "test-bez-sieci:fx")

	var/mob/living/carbon/human/foreigner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	foreigner.mind_initialize()
	foreigner.aq_make_foreigner()
	var/obj/item/aquila_translator/translator = allocate(/obj/item/aquila_translator, run_loc_floor_bottom_left)
	TEST_ASSERT(foreigner.put_in_hands(translator), "Could not pick up the translator")
	RegisterSignal(foreigner, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

	// Z pamięci: od razu tłumaczenie, bez oryginału
	SStranslation.cache_set(DEEPL_LANG_PL, DEEPL_LANG_EN, "Dzień dobry.", "Good morning.")
	TEST_ASSERT(!SStranslation.will_request(list("Dzień dobry."), DEEPL_LANG_PL, DEEPL_LANG_EN), "Cached text would still go to the API")
	foreigner.aq_translate_heard("", crew, /datum/language/common, "Dzień dobry.", null, list(), list())
	TEST_ASSERT(heard_raw == "Good morning.", "Cached translation was not heard at once: [heard_raw]")

	// Na żywo: oryginał od razu, w Angielskim, którego obcokrajowiec nie musi rozumieć po polsku
	heard_raw = null
	var/datum/translation_job/job = fake_job("Cześć.")
	TEST_ASSERT(SStranslation.will_request(list("Cześć."), DEEPL_LANG_PL, DEEPL_LANG_EN), "Uncached text with a key would not go to the API")
	foreigner.aq_translate_heard("", crew, /datum/language/common, "Cześć.", null, list(), list())
	TEST_ASSERT(heard_raw == "Cześć.", "Original was not heard before the translation: [heard_raw]")
	TEST_ASSERT(heard_language == /datum/language/english, "Original came in a language the foreigner does not read: [heard_language]")
	TEST_ASSERT(heard_mods?[MODE_AQ_TRANSLATED], "Original went back to the translator (no MODE_AQ_TRANSLATED)")
	TEST_ASSERT(length(job.callbacks) == 1, "Live hearing did not wait for the translation: [length(job.callbacks)] callbacks")
	TEST_ASSERT(isnull(foreigner.aq_live_wrap_id), "Wrap id stayed set after hearing")

	// Bez klienta linijka nie przechodzi przez compose_message(), więc tłumaczenie przychodzi nową linijką
	heard_raw = null
	finish_job(job, list("Hi."))
	TEST_ASSERT(heard_raw == "Hi.", "Translation of an unwrapped line was not heard: [heard_raw]")

	// Błąd API: nic więcej nie przychodzi, oryginał już był
	heard_raw = null
	job = fake_job("Na razie.")
	foreigner.aq_translate_heard("", crew, /datum/language/common, "Na razie.", null, list(), list())
	heard_raw = null
	finish_job(job, null)
	TEST_ASSERT(isnull(heard_raw), "Failed translation sent another line: [heard_raw]")

	// Owinięcie treści w linijce, także z formatowaniem mowy
	foreigner.aq_live_wrap_id = "aqtr-test"
	foreigner.aq_live_wrap_text = "|Cześć| tu."
	foreigner.aq_live_wrapped = FALSE
	var/line = foreigner.compose_message(crew, /datum/language/english, "|Cześć| tu.", null, list(), list())
	TEST_ASSERT(findtext(line, "data-aq-tr=\"aqtr-test\"><i>Cześć</i> tu.</span>"), "Speech was not wrapped in the chat line: [line]")
	TEST_ASSERT(foreigner.aq_live_wrapped, "Wrapping was not reported")
	TEST_ASSERT(isnull(foreigner.aq_live_wrap_id), "Wrap id was used twice")
	line = foreigner.compose_message(crew, /datum/language/english, "|Cześć| tu.", null, list(), list())
	TEST_ASSERT(!findtext(line, "data-aq-tr"), "Second line got wrapped too: [line]")

	foreigner.aq_live_wrap_text = null
	// Wynik mowy obcokrajowca bez dymka „…” (nikt nie patrzył) nie psuje usuwania
	TEST_ASSERT(!aq_remove_chat_bubble(null), "Removing a missing bubble reported success")

	UnregisterSignal(foreigner, COMSIG_MOVABLE_HEAR)
	SSticker.minds -= foreigner.mind

/datum/unit_test/aquila_live_translation/Destroy()
	CONFIG_SET(string/deepl_api_key, old_key || "")
	SStranslation.can_fire = old_can_fire
	SStranslation.pending = list()
	SStranslation.cache = list()
	return ..()

#undef TEST_ASSERT
