// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the hub status goes out as pure ASCII, Polish letters as HTML entities
/datum/unit_test/hub_status_ascii

/datum/unit_test/hub_status_ascii/Run()
	TEST_ASSERT_EQUAL(aq_ascii_entities("<b>Zażółć</b> 13"), "<b>Za&#380;&#243;&#322;&#263;</b> 13", "Polskie litery nie zamieniły się na encje")
	world.update_status()
	TEST_ASSERT_EQUAL(findtext(world.status, regex(@"[^\x01-\x7F]")), 0, "Status huba ma znaki spoza ASCII")

#undef TEST_ASSERT_EQUAL
