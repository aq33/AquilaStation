// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - new surgery skeleton (tgstation#93697): limb surgery state, prepping, availability and surgical aids
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

	// Removing the prep clears the trait
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE) && !HAS_TRAIT(chest, TRAIT_READY_TO_OPERATE), "Removing the prep left the patient ready to operate")

	// Drapes and bedsheets are surgical aids (tg surgery_aid): applying them toggles the prep of the selected zone
	var/obj/item/surgical_drapes/drapes = allocate(/obj/item/surgical_drapes)
	var/obj/item/bedsheet/bedsheet = allocate(/obj/item/bedsheet)
	TEST_ASSERT(HAS_TRAIT(drapes, TRAIT_SURGERY_AID) && HAS_TRAIT(bedsheet, TRAIT_SURGERY_AID), "Drapes or a bedsheet are not a surgical aid")
	surgeon.zone_selected = BODY_ZONE_R_ARM
	drapes.attack(patient, surgeon)
	TEST_ASSERT(HAS_TRAIT(arm, TRAIT_READY_TO_OPERATE) && !HAS_TRAIT(chest, TRAIT_READY_TO_OPERATE), "Drapes did not prep the selected arm")
	// on a prepped patient the drapes are not a tool for the operations (e.g. cavity implant takes any item)
	TEST_ASSERT(!surgeon.try_tg_surgery(patient, drapes), "Drapes were used as a surgery tool")
	bedsheet.attack(patient, surgeon)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE) && !HAS_TRAIT(arm, TRAIT_READY_TO_OPERATE), "A bedsheet did not remove the prep")

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

	// Locked operations need a disk, research or TRAIT_SURGEON
	TEST_ASSERT(!(/datum/surgery_operation/basic/revival in surgeon.get_unlocked_operations(patient)), "Revival unlocked without a disk")
	ADD_TRAIT(surgeon, TRAIT_SURGEON, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(/datum/surgery_operation/basic/revival in surgeon.get_unlocked_operations(patient), "TRAIT_SURGEON did not unlock revival")
	REMOVE_TRAIT(surgeon, TRAIT_SURGEON, TRAIT_SOURCE_UNIT_TESTS)

/// Is this operation among the ones from get_available_operations()
/datum/unit_test/aquila_surgery_tg_medical/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

/// AQUILA - etap 2b/3 of the new skeleton: plastic surgery, identity recalibration, lobotomy, dental implant, gender reassignment, bioware and unlocks
/datum/unit_test/aquila_surgery_tg_advanced

/datum/unit_test/aquila_surgery_tg_advanced/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	ADD_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS, TRAIT_SOURCE_UNIT_TESTS)
	patient.set_resting(TRUE)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)

	// Plastic surgery restores a disfigured face
	ADD_TRAIT(patient, TRAIT_DISFIGURED, TRAIT_GENERIC)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_HEAD)
	head.add_surgical_state(SURGERY_SKIN_OPEN)
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	var/datum/surgery_operation/plastic = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/plastic_surgery]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, scalpel, BODY_ZONE_HEAD), plastic), "No plastic surgery offered for a scalpel on an opened head")
	surgeon.put_in_active_hand(scalpel)
	plastic.try_perform(head, surgeon, scalpel, list(OPERATION_TARGET_ZONE = BODY_ZONE_HEAD))
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_DISFIGURED), "Plastic surgery left the face disfigured")

	// Lobotomy cures a brain trauma (locked, but try_perform does not check unlocks)
	var/obj/item/organ/brain/brain = patient.getorganslot(ORGAN_SLOT_BRAIN)
	var/datum/brain_trauma/mild/stuttering/trauma = new
	brain.gain_trauma(trauma, TRAUMA_RESILIENCE_SURGERY)
	TEST_ASSERT(!QDELETED(trauma) && (trauma in brain.traumas), "The test trauma was not applied")
	head.add_surgical_state(SURGERY_BONE_SAWED|SURGERY_VESSELS_CLAMPED)
	var/datum/surgery_operation/lobotomy = GLOB.operations.operations_by_typepath[/datum/surgery_operation/organ/lobotomy]
	lobotomy.try_perform(brain, surgeon, scalpel, list(OPERATION_TARGET_ZONE = BODY_ZONE_HEAD))
	TEST_ASSERT(QDELETED(trauma) || !(trauma in brain.traumas), "Lobotomy did not cure the trauma")
	// the lobotomy may leave a random trauma (spasms, narcolepsy...) that would interrupt the next operations
	brain.cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
	patient.set_resting(TRUE)
	surgeon.dropItemToGround(scalpel)
	head.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

	// Dental implant puts the pill in the patient and gives the bite action
	head.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_BONE_DRILLED|SURGERY_VESSELS_CLAMPED)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/surgery_operation/dental = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/add_dental_implant]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, pill, BODY_ZONE_PRECISE_MOUTH), dental), "No dental implant offered for a pill on a drilled mouth")
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, pill, BODY_ZONE_HEAD), dental), "Dental implant offered outside the mouth")
	surgeon.put_in_active_hand(pill)
	dental.try_perform(head, surgeon, pill, list(OPERATION_TARGET_ZONE = BODY_ZONE_PRECISE_MOUTH))
	TEST_ASSERT(pill.loc == patient, "Dental implant did not put the pill in the patient")
	TEST_ASSERT(locate(/datum/action/item_action/hands_free/activate_pill) in patient.actions, "Dental implant did not give the bite action")

	// Gender reassignment swaps the gender
	patient.gender = MALE
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	var/obj/item/scalpel/scalpel2 = allocate(/obj/item/scalpel)
	var/datum/surgery_operation/gender = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/gender_reassignment]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, scalpel2, BODY_ZONE_PRECISE_GROIN), gender), "No gender reassignment offered for a scalpel on the groin")
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, scalpel2, BODY_ZONE_CHEST), gender), "Gender reassignment offered on the chest")
	surgeon.put_in_active_hand(scalpel2)
	gender.try_perform(chest, surgeon, scalpel2, list(OPERATION_TARGET_ZONE = BODY_ZONE_PRECISE_GROIN))
	TEST_ASSERT(patient.gender == FEMALE, "Gender reassignment did not change the gender")
	surgeon.dropItemToGround(scalpel2)

	// Bioware: vein threading adds the modification, only once
	chest.add_surgical_state(SURGERY_ORGANS_CUT)
	var/datum/surgery_operation/veins = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/bioware/vein_threading]
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, IMPLEMENT_HAND, BODY_ZONE_CHEST), veins), "Vein threading offered without a disk")
	var/old_bleed_mod = patient.physiology.bleed_mod
	veins.try_perform(chest, surgeon, IMPLEMENT_HAND, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(locate(/datum/bioware/threaded_veins) in patient.bioware, "Vein threading did not add the bioware")
	TEST_ASSERT(patient.physiology.bleed_mod < old_bleed_mod, "Vein threading did not lower bleeding")
	ADD_TRAIT(surgeon, TRAIT_SURGEON, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, IMPLEMENT_HAND, BODY_ZONE_CHEST), veins), "Vein threading offered again on threaded veins")
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, IMPLEMENT_HAND, BODY_ZONE_CHEST), GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/bioware/nerve_splicing]), "Nerve splicing not offered to an unlocked surgeon")
	REMOVE_TRAIT(surgeon, TRAIT_SURGEON, TRAIT_SOURCE_UNIT_TESTS)
	chest.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

	// Identity recalibration renames a robotic chest
	chest.bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_ORGANS_CUT)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_name = "Jan Testowy"
	var/datum/surgery_operation/rename = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/identity_recalibration]
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, card, BODY_ZONE_CHEST), rename), "No identity recalibration offered for an ID on an opened robotic chest")
	surgeon.put_in_active_hand(card)
	rename.try_perform(chest, surgeon, card, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT(patient.real_name == "Jan Testowy", "Identity recalibration did not rename the patient: [patient.real_name]")

	// Abductors unlock their organ surgery (GLOB.abductor_operations)
	var/abductor_manip = /datum/surgery_operation/limb/organ_manipulation/internal/abductor
	TEST_ASSERT(!(abductor_manip in surgeon.get_unlocked_operations(patient)), "Abductor organ surgery unlocked for a human")
	surgeon.set_species(/datum/species/abductor)
	TEST_ASSERT(abductor_manip in surgeon.get_unlocked_operations(patient), "Abductor species did not unlock the abductor organ surgery")

/// Is this operation among the ones from get_available_operations()
/datum/unit_test/aquila_surgery_tg_advanced/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

#undef TEST_ASSERT
