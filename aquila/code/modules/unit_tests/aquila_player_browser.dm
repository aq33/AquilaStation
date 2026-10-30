// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - przeglądarka graczy: działa bez bazy i nie przepuszcza do zapytań znaków spoza ckey
/datum/unit_test/aquila_player_browser

/datum/unit_test/aquila_player_browser/Run()
	var/datum/player_browser/browser = new
	TEST_ASSERT(islist(browser.players), "Player list is not a list without the database")

	// wyszukiwarka idzie przez ckey(), więc % i _ z LIKE nie przejdą
	browser.search = ckey("Ab%_c D")
	TEST_ASSERT(browser.search == "abcd", "Search text was not sanitised to a ckey: [browser.search]")
	browser.load_players()

	browser.select_player("")
	TEST_ASSERT(isnull(browser.selected_ckey), "An empty ckey was selected")
	TEST_ASSERT(isnull(browser.bans), "Bans were loaded for an empty ckey")

	var/list/data = browser.ui_data(null)
	TEST_ASSERT(!isnull(data["db_connected"]), "ui_data has no database state")
	qdel(browser)

#undef TEST_ASSERT
