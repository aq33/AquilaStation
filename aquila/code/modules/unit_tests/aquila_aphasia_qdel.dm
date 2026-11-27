#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - człowiek z afazją usuwany przez qdel nie tworzy od nowa language_holder (runtime w /datum/language_holder/New,
/// widoczny w CI po teście reagentów umysłu, który losowo daje afazję). Poprawka: AQ EDIT w code/datums/brain_damage/severe.dm.
/datum/unit_test/aquila_aphasia_qdel

/datum/unit_test/aquila_aphasia_qdel/Run()
	var/mob/living/carbon/human/patient = new(run_loc_floor_bottom_left)
	var/datum/brain_trauma/trauma = patient.gain_trauma(/datum/brain_trauma/severe/aphasia)
	TEST_ASSERT(trauma, "The patient did not get aphasia")
	TEST_ASSERT(patient.has_language(/datum/language/aphasia), "Aphasia did not give its language")
	var/datum/language_holder/holder = patient.get_language_holder()
	qdel(patient)
	TEST_ASSERT(QDELETED(patient), "The patient with aphasia was not deleted")
	TEST_ASSERT(QDELETED(holder) || holder.owner != patient, "The deleted patient still owns a language holder")
	// Sama afazja odebrana żywemu pacjentowi dalej zdejmuje swój język
	var/mob/living/carbon/human/cured = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/brain_trauma/cured_trauma = cured.gain_trauma(/datum/brain_trauma/severe/aphasia)
	qdel(cured_trauma)
	TEST_ASSERT(!cured.has_language(/datum/language/aphasia), "Curing aphasia did not take its language away")

#undef TEST_ASSERT
