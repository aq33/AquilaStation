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
	// zły podział węzłów (opis czapki poczty przed <i>) dawał pusty tekst, oględziny pokazywały pustkę
	TEST_ASSERT(isnull(i18n_en_exact("Nakrycie głowy poczty")), "A Polish phrase is translated to an empty text")
	var/html = i18n_en_html("<b>skrzynka narzędziowa</b> i coś nieznanego")
	TEST_ASSERT(html == "<b>toolbox</b> i coś nieznanego", "HTML text nodes are not translated one by one: [html]")

	// Szablony serwera (dymki, runechat): wstawka tłumaczona słownikiem, gałąź warunku według alternatywy
	var/full = i18n_en_html("skrzynka narzędziowa jest pełny!")
	TEST_ASSERT(full == "toolbox is full!", "Server template with an embed failed: [full]")
	var/mode = i18n_en_html("Jest ustawiony w tryb: piła.")
	TEST_ASSERT(mode == "It's set to saw mode.", "Server template alternative picked the wrong branch: [mode]")
	// Oryginały portów (en_original.json): ogólne słowa bez znaczenia z jednej mapy nazw albo z identyfikatora
	TEST_ASSERT(i18n_en_exact("Brak") == "None", "Generic 'Brak' got a context-specific translation: [i18n_en_exact("Brak")]")
	TEST_ASSERT(i18n_en_exact("wyłączony") == "off", "Generic 'wyłączony' has a broken casing: [i18n_en_exact("wyłączony")]")
	// Angielski warunek oryginału z tym samym warunkiem co polski jest gałęzią szablonu (bez "from exit the")
	var/mirror = i18n_en_html("Coś nie pozwala ci tu wyjść ze świata luster!")
	TEST_ASSERT(mirror == "Something is blocking you from exiting the mirror's realm here!", "Original template with an English alternative failed: [mirror]")
	var/mixed = i18n_en_html("zupełnie nieznane polskie zdanie jest pełny!")
	TEST_ASSERT(mixed == "zupełnie nieznane polskie zdanie jest pełny!", "Template made a mixed-language text: [mixed]")
	TEST_ASSERT(i18n_lowercase_letters("żółw Jan") == 4, "Polish lowercase first letters are not counted")

	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)

	// Nazwa z obszarem w nawiasie (screentip "alarm powietrza (Komora Programowania SI)") i etykieta z dwukropkiem (tooltip)
	var/with_area = i18n_en_exact("alarm powietrza (Komora Programowania SI)")
	TEST_ASSERT(with_area == "air alarm (AI Upload Chamber)", "Name with a parenthesised area is not translated: [with_area]")
	// Nieznany polski dopisek w nawiasie: bez mieszanki "Blood (po zaschnięciu)", szablon "[name] (po zaschnięciu)" wygrywa
	var/dried = i18n_en_html("krew (po zaschnięciu)")
	TEST_ASSERT(dried == "dried blood", "Polish suffix in parentheses made a mixed name: [dried]")
	// Opis sklejony z dwóch kilkuzdaniowych opisów ("[part.desc] [desc]"): każdy kawałek osobno, bez mieszanki.
	// Dwa istniejące opisy hardsuitów: opisy motywów MOD zniknęły z kodu razem z MOD-ami (aq33/AquilaStation#583)
	var/obj/item/clothing/suit/space/hardsuit/control = /obj/item/clothing/suit/space/hardsuit
	var/obj/item/clothing/suit/space/hardsuit/syndi/second = /obj/item/clothing/suit/space/hardsuit/syndi
	var/first_en = i18n_en_exact(initial(control.desc))
	var/second_en = i18n_en_exact(initial(second.desc))
	TEST_ASSERT(first_en && second_en, "The hardsuit descriptions used by the joined description check have no translation")
	var/mod_desc = i18n_en_html("[initial(control.desc)] [initial(second.desc)]")
	TEST_ASSERT(mod_desc == "[first_en] [second_en]", "Joined description is not translated sentence by sentence: [mod_desc]")
	// Część MOD-a po nałożeniu motywu ("[part.name] (model [name])"), jak w mod_theme.dm
	var/mod_part = i18n_en_html("hełm MOD (model inżynieryjny)")
	TEST_ASSERT(mod_part == "engineering MOD helmet", "MOD part name with a theme is not translated: [mod_part]")
	var/half = i18n_en_html("[initial(control.desc)] Zupełnie nieznane polskie zdanie.")
	TEST_ASSERT(half == "[initial(control.desc)] Zupełnie nieznane polskie zdanie.", "Joined description with an unknown sentence made a mixed text: [half]")
	// Screentip z wstawką ("[panel_open ? "Zamknij" : "Otwórz"] panel serwisowy") idzie przez szablony
	var/screentip = i18n_en_html("[GLOB.lmb_icon] Otwórz panel serwisowy <br>", TRUE)
	TEST_ASSERT(!findtext(screentip, "panel serwisowy"), "Screentip action with an embed is not translated: [screentip]")
	var/label = i18n_en_html("opis<br><b>Siła:</b> niska")
	TEST_ASSERT(findtext(label, "<b>[i18n_en_exact("Siła")]:</b>"), "Label with a colon is not translated: [label]")

	// Okna HTML (browse, /datum/browser): węzły tekstowe także przez szablony, wcięcia zostają
	var/window_html = i18n_en_html("<div>\n\tLosowo: wył.\n</div><b>Ciśnienie:</b>", TRUE)
	TEST_ASSERT(findtext(window_html, "\n\t[i18n_en_template("Losowo: wył.")]\n") && findtext(window_html, "<b>[i18n_en_exact("Ciśnienie")]:</b>"), "HTML window text is not translated: [window_html]")
	var/with_code = i18n_en_html("<script>skrzynka narzędziowa</script><b>skrzynka narzędziowa</b><STYLE>skrzynka narzędziowa</STYLE>", TRUE)
	TEST_ASSERT(with_code == "<script>skrzynka narzędziowa</script><b>toolbox</b><STYLE>skrzynka narzędziowa</STYLE>", "Script or style block in an HTML window was translated: [with_code]")
	TEST_ASSERT(i18n_browse_html(viewer,"<b>Ciśnienie:</b>") == "<b>Ciśnienie:</b>", "HTML window changed for a player without English")

	// Pierwsze wejście: bez wyboru języka lobby nie wpuszcza do gry, ale zostawia resztę przycisków
	TEST_ASSERT(i18n_lobby_href_joins(list("ready" = "1")) && i18n_lobby_href_joins(list("ready" = "[PLAYER_READY_TO_OBSERVE]")), "Ready or observe is not blocked before choosing a language")
	TEST_ASSERT(i18n_lobby_href_joins(list("late_join" = "1")) && i18n_lobby_href_joins(list("SelectedJob" = "Captain")), "Late join is not blocked before choosing a language")
	TEST_ASSERT(!i18n_lobby_href_joins(list("ready" = "[PLAYER_NOT_READY]")) && !i18n_lobby_href_joins(list("show_preferences" = "1")) && !i18n_lobby_href_joins(list("manifest" = "1")), "Lobby blocks a button that does not join the game")
	var/datum/preferences/new_prefs = new(null)
	TEST_ASSERT(!new_prefs.game_language_chosen, "A new player starts with a chosen language")
	TEST_ASSERT(!new_prefs.choose_game_language("de") && !new_prefs.game_language_chosen, "An unknown language was accepted")
	TEST_ASSERT(new_prefs.choose_game_language(GAME_LANGUAGE_EN) && new_prefs.game_language == GAME_LANGUAGE_EN && new_prefs.game_language_chosen, "Choosing English did not set the language")
	TEST_ASSERT(new_prefs.choose_game_language(GAME_LANGUAGE_PL) && new_prefs.game_language == GAME_LANGUAGE_PL, "Switching back to Polish failed")

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

	// Dymek "[src] klika." z pustej broni: BYOND dokleja "The" przed nazwą pospolitą, po polsku ma go nie być
	var/obj/item/clicking = allocate(/obj/item)
	clicking.name = "protokinetyczny akcelerator"
	var/stripped = strip_auto_articles("[clicking] klika.")
	TEST_ASSERT(stripped == "protokinetyczny akcelerator klika.", "BYOND article is left in a Polish balloon: [stripped]")

#undef TEST_ASSERT
