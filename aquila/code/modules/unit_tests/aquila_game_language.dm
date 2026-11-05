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
	TEST_ASSERT(i18n_lowercase_letters("żółw Jan") == 4, "Polish lowercase first letters are not counted")

	// Okienka alert(): bez odbiorcy argumenty przesuwają się o jedno, domyślny przycisk to "Ok"
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/list/shifted = i18n_alert_args(viewer, "Tekst", "Tytuł", "Tak", "Nie")
	TEST_ASSERT(shifted[1] == viewer && shifted[2] == "Tekst" && shifted[3] == "Tytuł" && shifted[4] == "Tak" && shifted[5] == "Nie", "alert() without a recipient is not shifted to usr")
	var/list/direct = i18n_alert_args(null, viewer, "Tekst")
	TEST_ASSERT(direct[1] == viewer && direct[2] == "Tekst" && direct[4] == "Ok", "alert(user, text) lost the default Ok button")
	// Przyciski: dwa o tym samym tłumaczeniu zostają po polsku, żeby kod dostał właściwy
	var/list/buttons = i18n_alert_buttons(list("skrzynka narzędziowa", null, null))
	TEST_ASSERT(buttons[1] == "toolbox" && isnull(buttons[2]), "alert() buttons are not translated: [buttons[1]]")
	var/list/same = i18n_alert_buttons(list("skrzynka narzędziowa", "skrzynka narzędziowa", null))
	TEST_ASSERT(same[1] == "skrzynka narzędziowa", "Colliding button translations should stay Polish")
	// Bez klienta z językiem EN tekst okienka input() zostaje
	TEST_ASSERT(i18n_dialog_text(viewer, "skrzynka narzędziowa") == "skrzynka narzędziowa", "input() text changed for a player without English")

	// Nazwa z obszarem w nawiasie (screentip "alarm powietrza (Komora Programowania SI)") i etykieta z dwukropkiem (tooltip)
	var/with_area = i18n_en_exact("alarm powietrza (Komora Programowania SI)")
	TEST_ASSERT(with_area == "air alarm (AI Upload Chamber)", "Name with a parenthesised area is not translated: [with_area]")
	var/label = i18n_en_html("opis<br><b>Siła:</b> niska")
	TEST_ASSERT(findtext(label, "<b>[i18n_en_exact("Siła")]:</b>"), "Label with a colon is not translated: [label]")

	// Okna HTML (browse, /datum/browser): węzły tekstowe także przez szablony, wcięcia zostają
	var/window_html = i18n_en_html("<div>\n\tLosowo: wył.\n</div><b>Ciśnienie:</b>", TRUE)
	TEST_ASSERT(findtext(window_html, "\n\t[i18n_en_template("Losowo: wył.")]\n") && findtext(window_html, "<b>[i18n_en_exact("Ciśnienie")]:</b>"), "HTML window text is not translated: [window_html]")
	TEST_ASSERT(i18n_browse_html(viewer, "<b>Ciśnienie:</b>") == "<b>Ciśnienie:</b>", "HTML window changed for a player without English")

	// Ikony HUD-u: angielska kopia ma te same stany co polski plik (inaczej guzik znika)
	for(var/polish_key in GLOB.i18n_hud_icons_en)
		var/english = GLOB.i18n_hud_icons_en[polish_key]
		var/polish = GLOB.i18n_hud_icons_pl["[english]"]
		TEST_ASSERT("[polish]" == polish_key, "HUD icon [english] does not map back to [polish_key]")
		var/list/missing = icon_states(polish) - icon_states(english)
		TEST_ASSERT(!length(missing), "English HUD icon [english] lacks states: [jointext(missing, ", ")]; run tools/i18n/hud_en_icons.py")
	TEST_ASSERT(i18n_hud_icon('icons/mob/screen_midnight.dmi', TRUE) == 'aquila/icons/hud/en/screen_midnight.dmi', "Midnight HUD style has no English copy")
	TEST_ASSERT(i18n_hud_icon('aquila/icons/hud/en/screen_midnight.dmi', FALSE) == 'icons/mob/screen_midnight.dmi', "English HUD icon does not go back to Polish")
	TEST_ASSERT(i18n_hud_icon('icons/obj/storage.dmi', TRUE) == 'icons/obj/storage.dmi', "Icon without an English copy changed")

#undef TEST_ASSERT
