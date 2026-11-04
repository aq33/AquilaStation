// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - a circuit scanned in the module duplicator survives the round in the player's library and prints with the same cost
/datum/unit_test/aquila_circuit_library

/datum/unit_test/aquila_circuit_library/Run()
	var/test_ckey = "unittestcircuitlibrary"
	var/datum/circuit_library/library = new(test_ckey)
	fdel(library.save_path())
	library.designs.Cut()

	var/datum/material/glass = getmaterialref(/datum/material/glass)
	var/list/scanned = list(
		"name" = "Testowy układ",
		"desc" = "Opis",
		"integrated_circuit" = TRUE,
		"dupe_data" = "{\"components\":\[\]}",
		"materials" = list((glass) = 500),
	)
	TEST_ASSERT(library.add_design(scanned), "The design was not added")
	TEST_ASSERT(library.add_design(scanned), "Saving the same name again failed")
	TEST_ASSERT_EQUAL(length(library.designs), 1, "The same name should replace the old design")

	// A new round reads the library back from the file
	var/datum/circuit_library/reloaded = new(test_ckey)
	TEST_ASSERT_EQUAL(length(reloaded.designs), 1, "The library was not read back from the file")
	var/list/printable = reloaded.design_for_printing("Testowy układ")
	TEST_ASSERT(printable, "No printable design")
	TEST_ASSERT_EQUAL(printable["name"], "Testowy układ", "Wrong name after reload")
	TEST_ASSERT_EQUAL(printable["materials"][glass], 500, "Material cost changed after reload")
	TEST_ASSERT(printable["integrated_circuit"], "The circuit flag was lost")

	TEST_ASSERT(!reloaded.remove_design("Inny układ"), "Removed a design that is not in the library")
	TEST_ASSERT(reloaded.remove_design("Testowy układ"), "The design was not removed")
	TEST_ASSERT_EQUAL(length(reloaded.designs), 0, "The library is not empty after removal")
	// A broken file gives an empty library instead of a runtime, and is kept as .bak
	fdel(reloaded.save_path())
	fdel("[reloaded.save_path()].bak")
	text2file("{not json", reloaded.save_path())
	var/datum/circuit_library/broken = new(test_ckey)
	TEST_ASSERT_EQUAL(length(broken.designs), 0, "A broken file should give an empty library")
	TEST_ASSERT_EQUAL(trim(file2text("[broken.save_path()].bak")), "{not json", "The broken file was not kept as .bak") // text2file adds a line break
	fdel(broken.save_path())
	fdel("[broken.save_path()].bak")
	qdel(library)
	qdel(reloaded)
	qdel(broken)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
