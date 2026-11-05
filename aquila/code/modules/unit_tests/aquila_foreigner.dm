// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
// treat_message() dokleja kropkę na końcu zdania, stąd kropki w oczekiwanych tekstach
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Obcokrajowiec: bez tłumacza mówi po angielsku, z tłumaczem załoga słyszy polski we Wspólnym (z pamięci tłumaczeń, bez sieci)
/datum/unit_test/aquila_foreigner
	var/heard_language
	var/heard_raw
	var/list/heard_mods

/datum/unit_test/aquila_foreigner/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	heard_language = hearing_args[3]
	heard_raw = hearing_args[HEARING_RAW_MESSAGE]
	heard_mods = hearing_args[7]

/datum/unit_test/aquila_foreigner/Run()
	var/mob/living/carbon/human/foreigner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	foreigner.mind_initialize()
	foreigner.aq_make_foreigner()
	TEST_ASSERT(foreigner.mind.aq_foreigner, "Foreigner flag was not set on the mind")
	TEST_ASSERT(!foreigner.has_language(/datum/language/common), "Foreigner still understands Common")
	TEST_ASSERT(foreigner.has_language(/datum/language/english, TRUE), "Foreigner cannot speak English")
	TEST_ASSERT(foreigner.get_selected_language() == /datum/language/english, "Foreigner does not speak English by default (tongue list?)")
	TEST_ASSERT(!crew.has_language(/datum/language/english), "Crew should not understand English")

	RegisterSignal(crew, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

	// Bez tłumacza: angielski, którego załoga nie rozumie
	foreigner.say("Hello there")
	TEST_ASSERT(heard_language == /datum/language/english, "Speech without translator was not English: [heard_language]")
	TEST_ASSERT(heard_raw == "Hello there.", "Speech without translator changed: [heard_raw]")

	// Z tłumaczem i zdaniem w pamięci: polski we Wspólnym, przedrostek szeptu zostaje
	var/obj/item/aquila_translator/translator = allocate(/obj/item/aquila_translator, run_loc_floor_bottom_left)
	TEST_ASSERT(foreigner.put_in_hands(translator), "Could not pick up the translator")
	TEST_ASSERT(HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Translator in hand gives no trait")
	SStranslation.cache_set(DEEPL_LANG_EN, DEEPL_LANG_PL, "Hello there", "Cześć")
	heard_raw = null
	foreigner.say("Hello there")
	TEST_ASSERT(heard_language == /datum/language/common, "Translated speech was not Common: [heard_language]")
	TEST_ASSERT(heard_raw == "Cześć.", "Crew did not hear the translation: [heard_raw]")
	heard_raw = null
	foreigner.say("#Hello there")
	TEST_ASSERT(heard_raw == "Cześć.", "Whispered translation lost: [heard_raw]")
	TEST_ASSERT(heard_mods?[WHISPER_MODE], "Whisper prefix was lost after translation")
	TEST_ASSERT(!foreigner.aq_translated_say, "Translated say flag stayed on")

	// Bez klucza API i bez pamięci: tekst przechodzi bez tłumaczenia, ale we Wspólnym
	if(!CONFIG_GET(string/deepl_api_key))
		heard_raw = null
		foreigner.say("Sentence nobody translated")
		TEST_ASSERT(heard_language == /datum/language/common, "Untranslated fallback was not Common: [heard_language]")
		TEST_ASSERT(heard_raw == "Sentence nobody translated.", "Untranslated fallback changed the text: [heard_raw]")

	// Słuchanie: z tłumaczem polska mowa idzie do tłumacza, bez niego zostaje bełkot
	TEST_ASSERT(foreigner.aq_hears_via_translator(/datum/language/common), "Foreigner with translator does not get Polish speech translated")
	TEST_ASSERT(!crew.aq_hears_via_translator(/datum/language/common), "Crew without foreigner flag would get speech translated")
	foreigner.dropItemToGround(translator)
	TEST_ASSERT(!HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Dropped translator still works")
	TEST_ASSERT(!foreigner.aq_hears_via_translator(/datum/language/common), "Foreigner without translator still gets translations")

	UnregisterSignal(crew, COMSIG_MOVABLE_HEAR)
	SSticker.minds -= foreigner.mind
	SStranslation.cache = list()

#undef TEST_ASSERT
