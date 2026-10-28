// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - new surgery skeleton (tgstation#93697): limb surgery state, prepping, availability and the bridge to old surgeries
/datum/unit_test/aquila_surgery_tg

/datum/unit_test/aquila_surgery_tg/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	var/obj/item/retractor/retractor = allocate(/obj/item/retractor)
	var/obj/item/cautery/cautery = allocate(/obj/item/cautery)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/surgery_operation/incise = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]
	var/datum/surgery_operation/retract = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/retract_skin]
	var/datum/surgery_operation/close = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/close_skin]
	TEST_ASSERT(incise && retract && close, "Basic operations have no singletons")

	// no randomness and no slowdown from the room
	ADD_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS, TRAIT_SOURCE_UNIT_TESTS)
	surgeon.zone_selected = BODY_ZONE_CHEST
	patient.set_resting(TRUE)

	// Nothing without prepping the zone
	TEST_ASSERT(!length(surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)), "Operations offered on an unprepared patient")

	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE) && HAS_TRAIT(chest, TRAIT_READY_TO_OPERATE), "Prepping the chest did not make it ready to operate")
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	TEST_ASSERT(!HAS_TRAIT(arm, TRAIT_READY_TO_OPERATE), "Prepping the chest prepared an arm too")
	TEST_ASSERT(!length(surgeon.get_available_operations(patient, scalpel, BODY_ZONE_R_ARM)), "Operations offered on an unprepared arm")

	// Incision is offered for a scalpel, retracting needs the cut skin first
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST), incise), "No incision offered for a scalpel on a prepped chest")
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, retractor, BODY_ZONE_CHEST), retract), "Retracting offered without an incision")
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, cautery, BODY_ZONE_CHEST), close), "Closing offered without an incision")

	// Incision changes the limb state
	surgeon.put_in_active_hand(scalpel)
	incise.try_perform(chest, surgeon, scalpel, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(chest, SURGERY_SKIN_CUT|SURGERY_VESSELS_UNCLAMPED), "Incision did not cut the skin and the vessels")
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST), incise), "Incision offered again on cut skin")
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, retractor, BODY_ZONE_CHEST), retract), "No retracting offered after an incision")

	// Cauterizing closes everything
	surgeon.dropItemToGround(scalpel)
	surgeon.put_in_active_hand(cautery)
	close.try_perform(chest, surgeon, cautery, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(!chest.surgery_state, "Cauterizing left surgery states: [chest.surgery_state]")

	// An old step surgery in the same zone keeps the click
	var/datum/surgery/legacy = new /datum/surgery(patient, BODY_ZONE_CHEST, chest)
	TEST_ASSERT(!surgeon.try_tg_surgery(patient, cautery), "The new skeleton took the click from an old surgery in progress")
	qdel(legacy)

	// Removing the prep clears the trait
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE) && !HAS_TRAIT(chest, TRAIT_READY_TO_OPERATE), "Removing the prep left the patient ready to operate")

/// Is this operation among the ones from get_available_operations()
/datum/unit_test/aquila_surgery_tg/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

#undef TEST_ASSERT
