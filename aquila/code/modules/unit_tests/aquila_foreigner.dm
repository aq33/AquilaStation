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

/// Czip tłumacza: własne gniazdo w słuchawkach (klucze zostają wolne), działa tylko na uszach, wychodzi multitoolem
/datum/unit_test/aquila_translator_chip/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/radio/headset/headset = allocate(/obj/item/radio/headset, run_loc_floor_bottom_left)
	var/obj/item/aquila_translator_chip/chip = allocate(/obj/item/aquila_translator_chip, run_loc_floor_bottom_left)

	TEST_ASSERT(wearer.put_in_hands(chip), "Could not pick up the chip")
	headset.attackby(chip, wearer)
	TEST_ASSERT(headset.aq_translator_chip == chip && chip.loc == headset, "Chip did not go into the headset slot")
	TEST_ASSERT(!headset.keyslot && !headset.keyslot2, "Chip took an encryption key slot")

	// Oba gniazda na klucze dalej przyjmują klucze
	for(var/i in 1 to 2)
		var/obj/item/encryptionkey/key = allocate(/obj/item/encryptionkey/headset_sec, run_loc_floor_bottom_left)
		TEST_ASSERT(wearer.put_in_hands(key), "Could not pick up key [i]")
		headset.attackby(key, wearer)
	TEST_ASSERT(headset.keyslot && headset.keyslot2, "Encryption keys did not fit next to the chip")

	TEST_ASSERT(wearer.put_in_hands(headset), "Could not pick up the headset")
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Headset in hand already translates")
	TEST_ASSERT(wearer.equip_to_slot_if_possible(headset, ITEM_SLOT_EARS), "Could not wear the headset")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Worn headset with chip does not translate")
	TEST_ASSERT(wearer.has_language(/datum/language/english), "Worn chip gives no English understanding")

	// Śrubokręt wyjmuje klucze, czip zostaje
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver, run_loc_floor_bottom_left)
	headset.attackby(screwdriver, wearer)
	TEST_ASSERT(!headset.keyslot && !headset.keyslot2, "Screwdriver did not remove the keys")
	TEST_ASSERT(headset.aq_translator_chip == chip && HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Screwdriver removed the chip")

	// Multitool wyjmuje czip i wyłącza tłumacza
	var/obj/item/multitool/multitool = allocate(/obj/item/multitool, run_loc_floor_bottom_left)
	wearer.drop_all_held_items()
	TEST_ASSERT(headset.multitool_act(wearer, multitool), "Multitool did not act on the chip")
	TEST_ASSERT(!headset.aq_translator_chip && chip.loc != headset, "Chip still in the headset after the multitool")
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Translator stayed on after removing the chip")

	// Obcokrajowiec ze słuchawkami dostaje czip w nich, a zdjęte słuchawki przestają tłumaczyć
	wearer.aq_give_translator(wearer)
	TEST_ASSERT(istype(headset.aq_translator_chip), "Spawn translator did not go into the worn headset")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Spawn chip does not translate")
	wearer.dropItemToGround(headset)
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Dropped headset still translates")
	TEST_ASSERT(!headset.aq_translator_wearer, "Dropped headset still remembers its wearer")
	SStranslation.cache = list()

#undef TEST_ASSERT
