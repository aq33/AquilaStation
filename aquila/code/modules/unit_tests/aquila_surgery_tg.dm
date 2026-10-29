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

/// AQUILA - medical operations of the new skeleton (etap 2a): amputation, bones, punctures and foreign bodies on our wounds
/datum/unit_test/aquila_surgery_tg_medical

/datum/unit_test/aquila_surgery_tg_medical/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	ADD_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS, TRAIT_SOURCE_UNIT_TESTS)
	patient.set_resting(TRUE)

	// Amputation cuts off the limb
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_R_ARM)
	arm.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED)
	var/obj/item/circular_saw/saw = allocate(/obj/item/circular_saw)
	var/datum/surgery_operation/amputate = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/amputate]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, saw, BODY_ZONE_R_ARM), amputate), "No amputation offered for a saw on an opened arm")
	surgeon.put_in_active_hand(saw)
	amputate.try_perform(arm, surgeon, saw, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(!patient.get_bodypart(BODY_ZONE_R_ARM), "Amputation left the arm on")
	surgeon.dropItemToGround(saw)

	// Setting the bone removes the fracture
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	var/datum/wound/blunt/fracture/fracture = new
	fracture.apply_wound(leg, silent = TRUE)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_L_LEG)
	leg.add_surgical_state(SURGERY_SKIN_CUT)
	var/obj/item/bonesetter/bonesetter = allocate(/obj/item/bonesetter)
	var/datum/surgery_operation/repair_hairline = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/repair_hairline]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, bonesetter, BODY_ZONE_L_LEG), repair_hairline), "No bone setting offered for a fractured leg")
	surgeon.put_in_active_hand(bonesetter)
	repair_hairline.try_perform(leg, surgeon, bonesetter, list(OPERATION_TARGET_ZONE = BODY_ZONE_L_LEG))
	TEST_ASSERT(!leg.get_wound(WOUND_BLUNT), "Setting the bone left the fracture")

	// Compound fracture: reset with the bonesetter, then glue with bone gel
	var/datum/wound/blunt/compound/compound = new
	compound.apply_wound(leg, silent = TRUE)
	leg.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	var/datum/surgery_operation/reset_compound = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/reset_compound]
	reset_compound.try_perform(leg, surgeon, bonesetter, list(OPERATION_TARGET_ZONE = BODY_ZONE_L_LEG))
	TEST_ASSERT(compound.reset, "Resetting did not reset the compound fracture")
	surgeon.dropItemToGround(bonesetter)
	var/obj/item/stack/medical/bone_gel/gel = allocate(/obj/item/stack/medical/bone_gel)
	var/datum/surgery_operation/repair_compound = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/repair_compound]
	surgeon.put_in_active_hand(gel)
	repair_compound.try_perform(leg, surgeon, gel, list(OPERATION_TARGET_ZONE = BODY_ZONE_L_LEG))
	TEST_ASSERT(!leg.get_wound(WOUND_BLUNT), "Bone gel left the compound fracture")
	if(!QDELETED(gel))
		surgeon.dropItemToGround(gel)

	// Realigning and sealing the vessels removes a puncture
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/wound/pierce/puncture/puncture = new
	puncture.apply_wound(chest, silent = TRUE)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_VESSELS_CLAMPED)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)
	var/datum/surgery_operation/repair_puncture = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/repair_puncture]
	surgeon.put_in_active_hand(hemostat)
	repair_puncture.try_perform(chest, surgeon, hemostat, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(puncture.mend_state, "Realigning did not mend the puncture")
	surgeon.dropItemToGround(hemostat)
	var/obj/item/cautery/cautery = allocate(/obj/item/cautery)
	var/datum/surgery_operation/seal_veins = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/seal_veins]
	surgeon.put_in_active_hand(cautery)
	seal_veins.try_perform(chest, surgeon, cautery, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(!chest.get_wound(WOUND_PIERCE), "Sealing the vessels left the puncture")
	surgeon.dropItemToGround(cautery)

	// Removing foreign bodies takes out a lodged bullet fragment
	var/obj/item/bullet_fragment/fragment = new(patient.loc)
	fragment.tryEmbed(chest, forced = TRUE, silent = TRUE)
	TEST_ASSERT(fragment in chest.embedded_objects, "The bullet fragment did not embed")
	var/datum/surgery_operation/remove_foreign = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/remove_embedded_objects]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, IMPLEMENT_HAND, BODY_ZONE_CHEST), remove_foreign), "No foreign body removal offered for an empty hand")
	remove_foreign.try_perform(chest, surgeon, IMPLEMENT_HAND, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(!(fragment in chest.embedded_objects) && fragment.loc != patient, "Foreign body removal left the bullet fragment in")
	if(!QDELETED(fragment))
		qdel(fragment)

	// Locked operations come from the same source as the old advanced surgeries
	TEST_ASSERT(!(/datum/surgery_operation/basic/revival in surgeon.get_legacy_unlocked_operations(patient)), "Revival unlocked without a disk")
	ADD_TRAIT(surgeon, TRAIT_SURGEON, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(/datum/surgery_operation/basic/revival in surgeon.get_legacy_unlocked_operations(patient), "TRAIT_SURGEON did not unlock revival")
	REMOVE_TRAIT(surgeon, TRAIT_SURGEON, TRAIT_SOURCE_UNIT_TESTS)

/// Is this operation among the ones from get_available_operations()
/datum/unit_test/aquila_surgery_tg_medical/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

#undef TEST_ASSERT
