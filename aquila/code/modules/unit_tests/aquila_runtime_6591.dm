// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - runda 6591: span_* z aquila/code/__DEFINES/span.dm nie miały nawiasów wokół argumentu,
/// więc span_deadsay(warunek ? "a" : "b") liczyło "<span ...>" + warunek (oględziny martwego kota i kozy)
/datum/unit_test/aquila_span_macro_ternary

/datum/unit_test/aquila_span_macro_ternary/Run()
	var/naive = FALSE
	TEST_ASSERT_EQUAL(span_deadsay(naive ? "spi" : "martwy"), "<span class='deadsay'>martwy</span>", "span_deadsay() does not wrap a ternary argument")

/// AQUILA - runda 6591: wybiórcze oczyszczanie krwi w nosicielu bez reagentów sypało runtime'em co tick (306 razy)
/datum/unit_test/aquila_nanite_purging_no_reagents

/datum/unit_test/aquila_nanite_purging_no_reagents/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	QDEL_NULL(host.reagents)
	var/datum/nanite_program/purging_advanced/program = new
	program.host_mob = host
	TEST_ASSERT(!program.check_conditions(), "The program reported work on a host without toxins or reagents")
	program.active_effect()
	program.host_mob = null
	qdel(program)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
