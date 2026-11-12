// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - augmenting an arm with the new surgery: incision, retracting, augmentation, then the mechanical operations
/// on the prosthesis. Regression: the bleeding from the incision stayed on the zone of the prosthesis, which no
/// operation could close. A mechanical tool with nothing to do on a prepped prosthesis gives a hint, not a hit.
/datum/unit_test/aquila_surgery_augmentation

/datum/unit_test/aquila_surgery_augmentation/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	var/obj/item/retractor/retractor = allocate(/obj/item/retractor)
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver)
	var/obj/item/crowbar/crowbar = allocate(/obj/item/crowbar)
	var/obj/item/bodypart/r_arm/robot/augment = allocate(/obj/item/bodypart/r_arm/robot)
	var/datum/surgery_operation/incise = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]
	var/datum/surgery_operation/retract = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/retract_skin]
	var/datum/surgery_operation/limb/replace_limb/replace = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/replace_limb]
	var/datum/surgery_operation/mech_incise = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/mechanical_incision]
	var/datum/surgery_operation/mech_open = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/mechanical_open]
	var/datum/surgery_operation/mech_close = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/mechanical_close]
	TEST_ASSERT(incise && retract && replace && mech_incise && mech_open && mech_close, "Augmentation operations have no singletons")

	// no randomness and no slowdown from the room
	ADD_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(surgeon, TRAIT_STUNIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(patient, TRAIT_STUNIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	surgeon.zone_selected = BODY_ZONE_R_ARM
	patient.set_resting(TRUE)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_R_ARM)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	TEST_ASSERT(HAS_TRAIT(arm, TRAIT_READY_TO_OPERATE), "Prepping the right arm did not make it ready to operate")

	// Incision bleeds from the arm
	surgeon.put_in_active_hand(scalpel)
	incise.try_perform(arm, surgeon, scalpel, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(arm, SURGERY_SKIN_CUT), "Incision did not cut the skin of the arm")
	TEST_ASSERT(patient.is_bleeding(BODY_ZONE_R_ARM), "Incision did not make the arm bleed")
	surgeon.dropItemToGround(scalpel)

	surgeon.put_in_active_hand(retractor)
	retract.try_perform(arm, surgeon, retractor, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(arm, SURGERY_SKIN_OPEN), "Retracting did not open the skin of the arm")
	surgeon.dropItemToGround(retractor)

	// Augmentation: the radial option shows the prosthesis (its icon is in static_icon), the prosthesis replaces the arm
	surgeon.put_in_active_hand(augment)
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, augment, BODY_ZONE_R_ARM), replace), "Augmentation not offered on an open arm")
	var/datum/radial_menu_choice/option = replace.get_radial_options(arm, augment, BODY_ZONE_R_ARM)
	var/image/option_image = option.image
	TEST_ASSERT(option_image?.icon == initial(augment.static_icon) && option_image.icon_state == initial(augment.icon_state), "The augmentation option has no prosthesis icon: [option_image?.icon] [option_image?.icon_state]")
	replace.try_perform(arm, surgeon, augment, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(patient.get_bodypart(BODY_ZONE_R_ARM) == augment, "The prosthesis was not attached")
	TEST_ASSERT(!IS_ORGANIC_LIMB(augment), "The attached prosthesis is organic")
	TEST_ASSERT(!patient.is_bleeding(BODY_ZONE_R_ARM), "The prosthesis still bleeds from the incision of the old arm")
	TEST_ASSERT(HAS_TRAIT(augment, TRAIT_READY_TO_OPERATE), "The prosthesis is not prepped after augmentation")

	// Only the mechanical operations on the prosthesis
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, scalpel, BODY_ZONE_R_ARM), incise), "Organic incision offered on a prosthesis")
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, screwdriver, BODY_ZONE_R_ARM), mech_incise), "Unscrewing the shell not offered on a prosthesis")

	surgeon.put_in_active_hand(screwdriver)
	mech_incise.try_perform(augment, surgeon, screwdriver, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(augment, SURGERY_SKIN_CUT), "Unscrewing did not open the shell")
	surgeon.dropItemToGround(screwdriver)

	surgeon.put_in_active_hand(crowbar)
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, crowbar, BODY_ZONE_R_ARM), mech_open), "Opening the hatch not offered on an unscrewed prosthesis")
	mech_open.try_perform(augment, surgeon, crowbar, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(augment, SURGERY_SKIN_OPEN), "The crowbar did not open the hatch")
	surgeon.dropItemToGround(crowbar)

	surgeon.put_in_active_hand(screwdriver)
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, screwdriver, BODY_ZONE_R_ARM), mech_close), "Screwing the shell shut not offered on an open prosthesis")
	mech_close.try_perform(augment, surgeon, screwdriver, list(OPERATION_TARGET_ZONE = BODY_ZONE_R_ARM))
	TEST_ASSERT(!LIMB_HAS_ANY_SURGERY_STATE(augment, ALL_SURGERY_SKIN_STATES), "Screwing the shell shut left it open: [augment.surgery_state]")
	surgeon.dropItemToGround(screwdriver)

	// A crowbar with nothing to do on the prepped prosthesis gives a hint instead of a hit; on an organic arm it still hits
	surgeon.put_in_active_hand(crowbar)
	TEST_ASSERT(surgeon.perform_surgery(patient, crowbar, FALSE, BODY_ZONE_R_ARM) & ITEM_INTERACT_BLOCKING, "A crowbar with nothing to do on a prepped prosthesis does not block the attack")
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_L_ARM)
	TEST_ASSERT(!(surgeon.perform_surgery(patient, crowbar, FALSE, BODY_ZONE_L_ARM) & ITEM_INTERACT_BLOCKING), "A crowbar on a prepped organic arm blocks the attack")

/datum/unit_test/aquila_surgery_augmentation/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

#undef TEST_ASSERT
