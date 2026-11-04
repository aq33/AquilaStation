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

	// Tłumacz serwera (dymki, runechat, screentipy): stałe, doklejona kropka, spacje na brzegach, węzły HTML
	TEST_ASSERT(length(i18n_en_table()), "en_dm.json did not load")
	TEST_ASSERT(i18n_en_exact("skrzynka narzędziowa") == "toolbox", "Server table lost a basic item name")
	TEST_ASSERT(i18n_en_exact(" skrzynka narzędziowa.") == " toolbox.", "Trailing period or spaces are not kept")
	TEST_ASSERT(isnull(i18n_en_exact("Zdanie, którego nie ma w słowniku.")), "Unknown text should not be translated")
	var/html = i18n_en_html("<b>skrzynka narzędziowa</b> i coś nieznanego")
	TEST_ASSERT(html == "<b>toolbox</b> i coś nieznanego", "HTML text nodes are not translated one by one: [html]")

	// Szablony serwera (dymki, runechat): wstawka tłumaczona słownikiem, gałąź warunku według alternatywy
	var/full = i18n_en_html("skrzynka narzędziowa jest pełny!")
	TEST_ASSERT(full == "toolbox is full!", "Server template with an embed failed: [full]")
	var/mode = i18n_en_html("Jest ustawiony w tryb: piła.")
	TEST_ASSERT(mode == "It's set to saw mode.", "Server template alternative picked the wrong branch: [mode]")
	var/mixed = i18n_en_html("zupełnie nieznane polskie zdanie jest pełny!")
	TEST_ASSERT(mixed == "zupełnie nieznane polskie zdanie jest pełny!", "Template made a mixed-language text: [mixed]")

#undef TEST_ASSERT
