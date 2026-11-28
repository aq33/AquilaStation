// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - usunięcie moba z afazją: zdejmowanie blokady języków nie może odtwarzać holdera języków na usuwanym mobie
/// (runtime „Langauge holder added to a qdeleting thing”, losowo w teście reagentów z ciężką traumą)
/datum/unit_test/aphasia_owner_qdel

/datum/unit_test/aphasia_owner_qdel/Run()
	var/mob/living/carbon/human/patient = new(run_loc_floor_bottom_left)
	var/datum/brain_trauma/trauma = patient.gain_trauma(/datum/brain_trauma/severe/aphasia, TRAUMA_RESILIENCE_ABSOLUTE)
	TEST_ASSERT(trauma, "The human did not get aphasia")
	var/runtimes_before = GLOB.total_runtimes
	qdel(patient)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Deleting a human with aphasia caused a runtime")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
