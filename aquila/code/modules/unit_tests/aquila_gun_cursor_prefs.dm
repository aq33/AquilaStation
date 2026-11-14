// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Kursor rozrzutu i patrzenie na kursor są domyślnie wyłączone, a jednorazowa migracja wyłącza je też graczom
/// z zapisanym „włączone”; po migracji wybór gracza zostaje
/datum/unit_test/aquila_gun_cursor_prefs_off

/datum/unit_test/aquila_gun_cursor_prefs_off/Run()
	var/datum/preferences/prefs = new(null)
	TEST_ASSERT(!prefs.gun_cursor && !prefs.face_cursor_combat, "Fresh preferences have the spread cursor or cursor facing on")

	// Gracz z zapisanym „włączone” sprzed zmiany
	prefs.gun_cursor = TRUE
	prefs.face_cursor_combat = TRUE
	prefs.keybind_migrations = list("storage_grid_rotate")
	TEST_ASSERT(prefs.aq_migrate_gun_cursor_off(), "The migration did not run for saved preferences")
	TEST_ASSERT(!prefs.gun_cursor && !prefs.face_cursor_combat, "The migration left the options on")
	TEST_ASSERT("storage_grid_rotate" in prefs.keybind_migrations, "The migration dropped another migration name")

	// Gracz sam włącza opcje po migracji: przy następnym wczytaniu zostają włączone
	prefs.gun_cursor = TRUE
	prefs.face_cursor_combat = TRUE
	TEST_ASSERT(!prefs.aq_migrate_gun_cursor_off(), "The migration ran a second time")
	TEST_ASSERT(prefs.gun_cursor && prefs.face_cursor_combat, "The migration overrode the player's later choice")
	qdel(prefs)

#undef TEST_ASSERT
