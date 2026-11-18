// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Głosy mowy z Goona: wybór w oknie postaci, warianty pytania i okrzyku, głos narzucony przez rasę i wyłączenie dźwięków mowy
/datum/unit_test/aquila_speech_voices

/datum/unit_test/aquila_speech_voices/Run()
	var/datum/preference/choiced/speech_voice/entry = GLOB.preference_entries_by_key["speech_voice"]
	TEST_ASSERT(istype(entry), "There is no speech voice entry in the preferences window")
	TEST_ASSERT_EQUAL(entry.feature_key, "speech_voice", "The speech voice entry does not write features\[\"speech_voice\"\]")
	for(var/voice in entry.get_choices())
		if(voice == "species")
			continue
		TEST_ASSERT(GLOB.goon_speech_voices[voice], "Selectable voice [voice] has no recordings")

	TEST_ASSERT_EQUAL(get_goon_voice_sound("speak_2", "?"), 'aquila/sound/voice/goon/speak_2_ask.ogg', "A question did not use the question recording")
	TEST_ASSERT_EQUAL(get_goon_voice_sound("speak_2", "!"), 'aquila/sound/voice/goon/speak_2_exclaim.ogg', "An exclamation did not use the exclamation recording")
	TEST_ASSERT_EQUAL(get_goon_voice_sound("speak_2", "."), 'aquila/sound/voice/goon/speak_2.ogg', "A plain line did not use the plain recording")
	TEST_ASSERT(isnull(get_goon_voice_sound("nonexistent", "?")), "An unknown voice returned a recording")

	// Bez wyboru postać ma stały głos z Goona liczony z imienia, wybór go zastępuje, a głos rasy jest osobno
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	speaker.real_name = "Jan Kowalski"
	var/automatic = speaker.get_goon_voice()
	TEST_ASSERT(automatic in (GLOB.selectable_speech_voices - "species"), "A character without a choice has no Goon voice for Goon listeners")
	TEST_ASSERT_EQUAL(speaker.get_goon_voice(), automatic, "The automatic Goon voice is not stable")
	speaker.dna.features["speech_voice"] = "speak_3"
	TEST_ASSERT_EQUAL(speaker.get_goon_voice(), "speak_3", "The chosen Goon voice was not used")
	TEST_ASSERT(isnull(speaker.get_species_goon_voice()), "A human has a species voice")
	speaker.dna.species.goon_voice = "pug"
	TEST_ASSERT_EQUAL(speaker.get_species_goon_voice(), "pug", "The species voice is not reported")
	speaker.dna.species.goon_voice = null
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, run_loc_floor_bottom_left)
	TEST_ASSERT(isnull(corgi.get_goon_voice()), "An animal got a Goon voice")

	// Słuchacz wybiera: nasze „hmm”, głosy z Goona albo cisza. Dźwięki bez wersji z Goona słychać w obu trybach.
	var/datum/preferences/prefs = new
	var/datum/preference/choiced/speech_sounds/mode = GLOB.preference_entries_by_key["speech_sounds"]
	TEST_ASSERT(istype(mode), "There is no speech sounds entry in the game preferences")
	var/list/expected = list(
		"hmm" = list(VOLUME_PREF_SPEECH = 100, VOLUME_PREF_SPEECH_GOON = 0, VOLUME_PREF_SPEECH_ANY = 100),
		"goon" = list(VOLUME_PREF_SPEECH = 0, VOLUME_PREF_SPEECH_GOON = 100, VOLUME_PREF_SPEECH_ANY = 100),
		"off" = list(VOLUME_PREF_SPEECH = 0, VOLUME_PREF_SPEECH_GOON = 0, VOLUME_PREF_SPEECH_ANY = 0),
	)
	TEST_ASSERT_EQUAL(mode.read_value(prefs), "hmm", "A new player does not hear our speech sounds by default")
	for(var/value in expected)
		mode.write_value(prefs, value)
		TEST_ASSERT_EQUAL(mode.read_value(prefs), value, "The speech sounds mode [value] was not saved")
		var/list/volumes = expected[value]
		for(var/category in volumes)
			TEST_ASSERT_EQUAL(prefs.get_volume_pref(category), volumes[category], "Mode [value]: wrong volume of [category]")
	TEST_ASSERT_EQUAL(prefs.get_volume_pref(VOLUME_PREF_TESLA), prefs.tesla_volume, "The speech override broke other volume categories")

/// Krzyki ras i pierdnięcia z Goona trafiają do puli dźwięków
/datum/unit_test/aquila_species_screams

/datum/unit_test/aquila_species_screams/Run()
	var/datum/emote/living/carbon/human/scream/scream = new
	var/mob/living/carbon/human/screamer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	screamer.set_species(/datum/species/oozeling)
	TEST_ASSERT_EQUAL(scream.get_sound(screamer), 'aquila/sound/voice/scream/skyrat_jelly_scream.ogg', "An oozeling does not scream like jelly")
	screamer.set_species(/datum/species/human/felinid)
	var/cat_scream = scream.get_sound(screamer)
	TEST_ASSERT(cat_scream == 'nsv13/sound/voice/felinid/scream_cat.ogg' || cat_scream == 'aquila/sound/voice/scream/skyrat_scream_cat.ogg', "A felinid scream [cat_scream] is not a cat scream")

	var/obj/item/organ/butt/butt = allocate(/obj/item/organ/butt)
	var/list/fart_pool = list(butt.fart_sound) + butt.extra_fart_sounds
	TEST_ASSERT(length(butt.extra_fart_sounds) == 7, "The Goon farts are missing from the human butt")
	for(var/i in 1 to 10)
		TEST_ASSERT(butt.get_fart_sound() in fart_pool, "A fart sound came from outside the pool")
	var/obj/item/organ/butt/xeno/xeno_butt = allocate(/obj/item/organ/butt/xeno)
	TEST_ASSERT_EQUAL(xeno_butt.get_fart_sound(), 'aquila/sound/misc/alienfart.ogg', "A xenomorph butt farts like a human")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
