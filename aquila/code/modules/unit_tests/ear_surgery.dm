// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Ear surgery (#268) on the new skeleton (/datum/surgery_operation/organ/repair/ears): repairs failed ears, failure stabs the brain
/datum/unit_test/ear_surgery

/datum/unit_test/ear_surgery/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)
	var/obj/item/organ/ears/ears = patient.getorganslot(ORGAN_SLOT_EARS)
	TEST_ASSERT(ears, "Patient has no ears")
	var/datum/surgery_operation/organ/repair/ears/operation = GLOB.operations.operations_by_typepath[/datum/surgery_operation/organ/repair/ears]
	TEST_ASSERT(operation, "Ear surgery is not in the operation list")

	// Ears destroyed by a loud noise: failing and deaf
	ears.applyOrganDamage(ears.maxHealth)
	ears.deaf = 200
	TEST_ASSERT(ears.organ_flags & ORGAN_FAILING, "Fully damaged ears are not failing")

	TEST_ASSERT(operation.state_check(ears), "Ear surgery cannot be done on a patient with ears")

	// An interrupted operation (only preop) changes nothing
	operation.on_preop(ears, surgeon, hemostat, list())
	TEST_ASSERT(ears.organ_flags & ORGAN_FAILING, "Starting the operation already fixed the ears")

	// A botched operation stabs the brain and leaves the ears broken
	var/brain_before = patient.getOrganLoss(ORGAN_SLOT_BRAIN)
	operation.on_failure(ears, surgeon, hemostat, list())
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_BRAIN) > brain_before, "Failure did not damage the brain")
	TEST_ASSERT(ears.organ_flags & ORGAN_FAILING, "Failure fixed the ears")

	// Success: healthy ears, a short temporary deafness, still exactly one pair of ears
	operation.on_success(ears, surgeon, hemostat, list())
	TEST_ASSERT_EQUAL(ears.damage, 0, "Ears still damaged")
	TEST_ASSERT(!(ears.organ_flags & ORGAN_FAILING), "Ears still failing")
	TEST_ASSERT_EQUAL(ears.deaf, 20, "Deafness not reset to the short recovery time")
	TEST_ASSERT_EQUAL(patient.getorganslot(ORGAN_SLOT_EARS), ears, "Ears were replaced")
	var/ear_count = 0
	for(var/obj/item/organ/ears/E in patient.internal_organs)
		ear_count++
	TEST_ASSERT_EQUAL(ear_count, 1, "Wrong number of ears after surgery")
	for(var/i in 1 to 25) // the recovery deafness wears off on its own
		ears.on_life()
	TEST_ASSERT_EQUAL(ears.deaf, 0, "Recovery deafness did not wear off")

	// Offered with a hemostat on an opened head, but not once the ears are gone
	patient.set_resting(TRUE)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_HEAD)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	head.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	TEST_ASSERT(offers_operation(surgeon, patient, hemostat, operation), "Ear surgery not offered on an opened head")
	ears.Remove(patient)
	qdel(ears)
	TEST_ASSERT(!offers_operation(surgeon, patient, hemostat, operation), "Ear surgery offered without ears")
	head.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

/// Is this operation offered for the tool on the patient's head
/datum/unit_test/ear_surgery/proc/offers_operation(mob/living/surgeon, mob/living/patient, tool, datum/surgery_operation/operation)
	var/list/operations = surgeon.get_available_operations(patient, tool, BODY_ZONE_HEAD)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
