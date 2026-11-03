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
	var/list/printable = reloaded.design_for_printing(1)
	TEST_ASSERT(printable, "No printable design")
	TEST_ASSERT_EQUAL(printable["name"], "Testowy układ", "Wrong name after reload")
	TEST_ASSERT_EQUAL(printable["materials"][glass], 500, "Material cost changed after reload")
	TEST_ASSERT(printable["integrated_circuit"], "The circuit flag was lost")

	TEST_ASSERT(reloaded.remove_design(1), "The design was not removed")
	TEST_ASSERT_EQUAL(length(reloaded.designs), 0, "The library is not empty after removal")
	fdel(reloaded.save_path())
	qdel(library)
	qdel(reloaded)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
