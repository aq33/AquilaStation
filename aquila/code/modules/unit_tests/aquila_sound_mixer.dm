// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Mikser dźwięku: suwaki w oknie, zapis kategorii, odczyt z bazy, mowa postaci i mnożnik głośności u słuchacza
/datum/unit_test/aquila_sound_mixer

/datum/unit_test/aquila_sound_mixer/Run()
	var/datum/preferences/prefs = new

	// Nowy gracz słyszy wszystko jak dotąd, a każda kategoria ma suwak, który ją zapisuje
	for(var/category in GLOB.sound_mixer_categories)
		TEST_ASSERT_EQUAL(prefs.get_volume_pref(category), 100, "A new player does not hear [category] at full volume")
		var/datum/preference/numeric/sound_mixer/slider = GLOB.preference_entries_by_key["sound_mixer_[category]"]
		TEST_ASSERT(istype(slider), "There is no mixer slider for [category]")
		TEST_ASSERT_EQUAL(slider.volume_category, category, "The slider sound_mixer_[category] sets another category")
		TEST_ASSERT(prefs.update_preference(slider, 30), "The slider for [category] refused 30%")
		TEST_ASSERT_EQUAL(slider.read_value(prefs), 30, "The slider for [category] did not save 30%")
		TEST_ASSERT_EQUAL(prefs.get_volume_pref(category), 30, "30% on the slider did not lower [category]")

	// Wejście z okna jest niezaufane
	var/datum/preference/numeric/sound_mixer/guns = GLOB.preference_entries_by_key["sound_mixer_[VOLUME_PREF_GUNS]"]
	TEST_ASSERT_EQUAL(guns.deserialize(150, prefs), 100, "The slider accepted more than 100%")
	TEST_ASSERT_EQUAL(guns.deserialize(-5, prefs), 0, "The slider accepted less than 0%")
	TEST_ASSERT_EQUAL(guns.deserialize("45", prefs), 45, "The slider did not read a number sent as text")
	TEST_ASSERT(isnull(guns.deserialize("głośno", prefs)), "The slider accepted text")
	prefs.set_sound_volume("nie_ma_takiej", 10)
	TEST_ASSERT(!("nie_ma_takiej" in prefs.get_sound_volumes()), "An unknown category was saved")

	// Zapis do bazy i odczyt: JSON, uszkodzone i nieznane wpisy odpadają
	prefs.set_sound_volume(VOLUME_PREF_SHIP_ALERTS, 0)
	prefs.sound_volumes = json_decode(json_encode(prefs.get_sound_volumes()))
	prefs.sanitize_sound_volumes()
	TEST_ASSERT_EQUAL(prefs.get_sound_volume(VOLUME_PREF_SHIP_ALERTS), 0, "Muted ship alarms did not survive saving")
	TEST_ASSERT_EQUAL(prefs.get_sound_volume(VOLUME_PREF_GUNS), 30, "The firearms volume did not survive saving")
	prefs.sound_volumes = list(VOLUME_PREF_GUNS = "40", VOLUME_PREF_EMOTES = "głośno", VOLUME_PREF_TTS = 500, "stara" = 10)
	prefs.sanitize_sound_volumes()
	TEST_ASSERT_EQUAL(prefs.get_sound_volume(VOLUME_PREF_GUNS), 40, "A volume saved as text was lost")
	TEST_ASSERT_EQUAL(prefs.get_sound_volume(VOLUME_PREF_EMOTES), 100, "A broken volume did not fall back to 100%")
	TEST_ASSERT_EQUAL(prefs.get_sound_volume(VOLUME_PREF_TTS), 100, "A volume above 100% was not clamped")
	TEST_ASSERT(!("stara" in prefs.get_sound_volumes()), "An unknown category from the database was kept")
	prefs.sound_volumes = "zepsute"
	prefs.sanitize_sound_volumes()
	TEST_ASSERT_EQUAL(prefs.get_volume_pref(VOLUME_PREF_GUNS), 100, "A broken saved mixer did not reset to full volume")

	// Mowa postaci: suwak mnoży się z trybem „hmm” / Goon / cisza, tesla ma własny suwak
	prefs.set_sound_volume(VOLUME_PREF_VOICES, 50)
	TEST_ASSERT_EQUAL(prefs.get_volume_pref(VOLUME_PREF_SPEECH), 50, "The speech slider did not lower our speech sounds")
	TEST_ASSERT_EQUAL(prefs.get_volume_pref(VOLUME_PREF_SPEECH_ANY), 50, "The speech slider did not lower machine and animal speech")
	TEST_ASSERT_EQUAL(prefs.get_volume_pref(VOLUME_PREF_SPEECH_GOON), 0, "The speech slider unmuted Goon voices for a player who did not pick them")
	prefs.tesla_volume = 70
	TEST_ASSERT_EQUAL(prefs.get_volume_pref(VOLUME_PREF_TESLA), 70, "The mixer broke the tesla volume")

	// Słuchacz: dźwięki wysyłane wprost (relay okrętu, otoczenie, TTS) mnożą się przez to samo ustawienie
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(listener.sound_volume_mult(VOLUME_PREF_SHIP_FX), 1, "A mob without a client got a lowered volume")
	var/datum/client_interface/mock = new
	mock.prefs = prefs
	listener.mock_client = mock
	prefs.set_sound_volume(VOLUME_PREF_SHIP_ALERTS, 0)
	prefs.set_sound_volume(VOLUME_PREF_SHIP_FX, 25)
	TEST_ASSERT_EQUAL(listener.sound_volume_mult(VOLUME_PREF_SHIP_ALERTS), 0, "Muted ship alarms still play")
	TEST_ASSERT_EQUAL(listener.sound_volume_mult(VOLUME_PREF_SHIP_FX), 0.25, "25% ship effects play at another volume")
	TEST_ASSERT_EQUAL(listener.sound_volume_mult(null), 1, "A sound without a category was lowered")
	listener.mock_client = null

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
