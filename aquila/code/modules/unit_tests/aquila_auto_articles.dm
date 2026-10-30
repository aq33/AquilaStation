// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - BYOND dokleja "the"/"The" przed wstawionym obiektem o nazwie małą literą, a to_chat je wycina
/datum/unit_test/aquila_auto_articles

/datum/unit_test/aquila_auto_articles/Run()
	var/obj/item/folder/folder = allocate(/obj/item/folder)
	folder.name = "teczka"
	TEST_ASSERT_EQUAL(strip_auto_articles("[folder] leży."), "teczka leży.", "The article at the start was not removed")
	TEST_ASSERT_EQUAL(strip_auto_articles("To [folder]."), "To teczka.", "The article inside a sentence was not removed")
	TEST_ASSERT_EQUAL(strip_auto_articles("<span class='notice'>[folder]</span>"), "<span class='notice'>teczka</span>", "The article after a tag was not removed")
	TEST_ASSERT_EQUAL(strip_auto_articles("theme breathe"), "theme breathe", "Words containing \"the\" were changed")
	TEST_ASSERT_EQUAL(strip_auto_articles(null), null, "Null text was changed")

#undef TEST_ASSERT_EQUAL
