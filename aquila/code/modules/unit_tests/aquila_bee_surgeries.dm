// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation stomach pump and identity recalibration, on the new surgery skeleton (aquila/code/modules/surgery_tg/)
/datum/unit_test/aquila_bee_surgeries

/datum/unit_test/aquila_bee_surgeries/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	ADD_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS, TRAIT_SOURCE_UNIT_TESTS)
	patient.set_resting(TRUE)

	// Stomach pump purges most chemicals
	patient.reagents.add_reagent(/datum/reagent/toxin, 30)
	var/datum/surgery_operation/organ/stomach_pump/pump = GLOB.operations.operations_by_typepath[/datum/surgery_operation/organ/stomach_pump]
	var/obj/item/organ/stomach/stomach = patient.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT(pump && stomach, "No stomach pump operation or no stomach")
	TEST_ASSERT(pump.state_check(stomach), "Stomach pump cannot be done on a human with a stomach")
	pump.on_success(stomach, surgeon, IMPLEMENT_HAND, list())
	TEST_ASSERT(patient.reagents.get_reagent_amount(/datum/reagent/toxin) <= 10, "Stomach pump did not purge the toxin")

	// Identity recalibration is not offered on an organic chest (the robotic one is in aquila_surgery_tg_advanced)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_ORGANS_CUT)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_name = "Testowy Robot"
	var/datum/surgery_operation/rename = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/identity_recalibration]
	var/list/operations = surgeon.get_available_operations(patient, card, BODY_ZONE_CHEST)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		TEST_ASSERT(entry[1] != rename, "Identity recalibration is offered on an organic chest")
	chest.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

#undef TEST_ASSERT
