// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Język gry: preferencja ma oba języki, a słownik czatu dla EN istnieje i ma szablony
/datum/unit_test/aquila_game_language

/datum/unit_test/aquila_game_language/Run()
	var/datum/preference/choiced/game_language/preference = GLOB.preference_entries[/datum/preference/choiced/game_language]
	TEST_ASSERT(preference, "No game_language preference entry")
	var/list/choices = preference.get_choices()
	TEST_ASSERT(("pl" in choices) && ("en" in choices), "game_language should offer pl and en")

	// Zasób czytany z dysku przy starcie (file()), brak pliku wywaliłby rejestrację zasobu
	TEST_ASSERT(fexists("strings/i18n/en_chat.json"), "strings/i18n/en_chat.json is missing, run tools/i18n/build_chat_dict.py")
	var/list/dictionary = json_decode(file2text("strings/i18n/en_chat.json"))
	TEST_ASSERT(islist(dictionary), "en_chat.json is not valid JSON")
	TEST_ASSERT(length(dictionary["exact"]), "en_chat.json has no constant texts")
	TEST_ASSERT(length(dictionary["templates"]), "en_chat.json has no templates")
	TEST_ASSERT(dictionary["exact"]["skrzynka narzędziowa"] == "toolbox", "en_chat.json lost a basic item name")

#undef TEST_ASSERT
