// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - opisy układów gwiezdnych po polsku: domyślna mapa, mapa w kodzie i stara (angielska) kopia starmap.json
/datum/unit_test/aquila_star_system_desc_pl

/datum/unit_test/aquila_star_system_desc_pl/Run()
	// Każdy opis z domyślnej mapy ma polski odpowiednik w kodzie i to ten sam tekst
	var/list/default_map = json_decode(rustg_file_read("config/starmap/starmap_default.json"))
	TEST_ASSERT(length(default_map), "config/starmap/starmap_default.json did not load")
	for(var/list/entry in default_map)
		var/system_desc = entry["desc"]
		if(!system_desc)
			continue
		TEST_ASSERT_EQUAL(GLOB.star_system_desc_pl[entry["name"]], system_desc, "Polish description of [entry["name"]] differs between the code and starmap_default.json")

	// Wczytane układy mają polskie opisy (nadpisanie New() nie może psuć argumentów nazwanych, inaczej mapa wczytuje się pusta)
	var/datum/star_system/medea = SSstar_system.system_by_id("Medea")
	TEST_ASSERT(medea, "Medea was not loaded from the starmap")
	TEST_ASSERT_EQUAL(medea.desc, GLOB.star_system_desc_pl["Medea"], "Loaded Medea has a non-Polish description")
	for(var/datum/star_system/system as anything in SSstar_system.systems)
		var/polish_desc = GLOB.star_system_desc_pl[system.name]
		if(polish_desc)
			TEST_ASSERT_EQUAL(system.desc, polish_desc, "Loaded system [system.name] has a non-Polish description")

	// Stary starmap.json z serwera ma angielski opis: po wczytaniu układ i tak dostaje polski
	var/datum/star_system/loaded = new /datum/star_system(name = "Medea", desc = "The base of operations for the majority of Nanotrasen's endeavors in combating the Syndicate.", x = 1, y = 1, alignment = "nanotrasen", owner = "nanotrasen", sector = 2, adjacency_list = list(), system_type = list(), system_traits = STARSYSTEM_NO_ANOMALIES | STARSYSTEM_NO_ASTEROIDS | STARSYSTEM_NO_WORMHOLE)
	TEST_ASSERT_EQUAL(loaded.desc, GLOB.star_system_desc_pl["Medea"], "An English description from an old starmap.json was kept")
	qdel(loaded)

	// Układ spoza mapy zachowuje swój opis
	var/datum/star_system/custom = new /datum/star_system(name = "Unit Test Custom System", desc = "Custom admin description", x = 1, y = 1, alignment = "unaligned", owner = "unaligned", sector = 2, adjacency_list = list(), system_type = list(), system_traits = STARSYSTEM_NO_ANOMALIES | STARSYSTEM_NO_ASTEROIDS | STARSYSTEM_NO_WORMHOLE)
	TEST_ASSERT_EQUAL(custom.desc, "Custom admin description", "A system outside the map lost its description")
	qdel(custom)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
