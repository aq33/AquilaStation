#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - piracki rajder na overmapie (pirate_raider.dm): gubi okręt po jego skoku, przybija tylko do okrętu gracza,
/// a wczytywanie promu z rajdera nie wysyła kolejnego rajdera
/datum/unit_test/aquila_pirate_raider

/datum/unit_test/aquila_pirate_raider/Run()
	var/obj/structure/overmap/spacepirate/ai/boarding/raider/raider = allocate(/obj/structure/overmap/spacepirate/ai/boarding/raider)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/other = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	raider.ai_controlled = FALSE
	other.ai_controlled = FALSE
	TEST_ASSERT(length(SSstar_system.systems) >= 2, "Za mało systemów gwiezdnych do testu")
	var/datum/star_system/here = SSstar_system.systems[1]
	var/datum/star_system/elsewhere = SSstar_system.systems[2]

	TEST_ASSERT(raider.lost_track_of(null), "Rajder widzi okręt, którego nie ma")
	other.current_system = null
	TEST_ASSERT(raider.lost_track_of(other), "Rajder widzi okręt w skoku FTL")
	raider.current_system = here
	other.current_system = here
	TEST_ASSERT(!raider.lost_track_of(other), "Rajder gubi okręt w tym samym systemie")
	other.current_system = elsewhere
	TEST_ASSERT(raider.lost_track_of(other), "Rajder nie gubi okrętu w innym systemie")
	raider.current_system = null
	other.current_system = null

	// Rajder przybija tylko do okrętu gracza (inne okręty AI nie dostają piratów)
	TEST_ASSERT(!raider.try_board(other), "Rajder przybija do okrętu, który nie jest okrętem gracza")
	TEST_ASSERT(!raider.docked, "Rajder oznaczył prom jako wypuszczony bez przybicia")

	// Prom wczytywany z rajdera idzie starą drogą, bez drugiego rajdera
	GLOB.pirate_raider_docking = TRUE
	var/sent = aquila_send_pirate_raider()
	GLOB.pirate_raider_docking = FALSE
	TEST_ASSERT(!sent, "Wczytywanie promu z rajdera wysłało kolejny rajder")

#undef TEST_ASSERT
