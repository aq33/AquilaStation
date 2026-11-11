// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - każdy wygląd rdzenia SI z listy w preferencjach (w tym Claude) ma stan w icons/mob/ai.dmi
/datum/unit_test/aquila_ai_core_displays

/datum/unit_test/aquila_ai_core_displays/Run()
	for(var/display in GLOB.ai_core_display_screens)
		// Random losuje z listy, a Portrait otwiera wybór portretu
		if(display == "Random" || display == "Portrait")
			continue
		var/state = resolve_ai_icon(display)
		TEST_ASSERT(icon_exists('icons/mob/ai.dmi', state), "Wygląd SI [display]: brak stanu [state]")
	TEST_ASSERT(icon_exists('icons/mob/ai.dmi', "ai-claude_dead"), "Wygląd SI Claude nie ma stanu po śmierci rdzenia")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
