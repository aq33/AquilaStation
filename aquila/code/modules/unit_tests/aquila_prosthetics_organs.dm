// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - tgstation#91573: an item becomes the arm, falls off while loose, takes the arm with it
/datum/unit_test/aquila_item_prosthetic

/datum/unit_test/aquila_item_prosthetic/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/extinguisher/tool = allocate(/obj/item/extinguisher)
	var/obj/item/bodypart/old_arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	old_arm.drop_limb()
	qdel(old_arm)

	var/obj/item/bodypart/pseudo = patient.make_item_prosthetic(tool, BODY_ZONE_R_ARM, 100)
	TEST_ASSERT(pseudo?.is_pseudopart, "No pseudopart arm was made")
	TEST_ASSERT(patient.get_item_for_held_index(pseudo.held_index) == tool, "The item is not held by its arm")
	TEST_ASSERT(HAS_TRAIT_FROM(tool, TRAIT_NODROP, PROSTHETIC_ITEM_TRAIT), "The item arm can be dropped")
	TEST_ASSERT(tool.item_flags & ABSTRACT, "The item arm is not abstract")
	TEST_ASSERT(length(patient.prosthetic_item_examine_lines(victim)), "The item arm is missing from examine")
	var/mutable_appearance/raised = tool.build_worn_icon(HANDS_LAYER, tool.righthand_file, TRUE)
	TEST_ASSERT(raised.pixel_y > 0, "The item arm inhand sprite is not raised to the shoulder")

	// a loose arm falls off on the first swing
	patient.a_intent = INTENT_HARM
	tool.attack(victim, patient)
	TEST_ASSERT(!patient.get_bodypart(BODY_ZONE_R_ARM), "The loose item arm did not fall off")
	TEST_ASSERT(tool.loc == get_turf(patient), "The item did not land under the patient")
	TEST_ASSERT(!HAS_TRAIT(tool, TRAIT_NODROP) && !(tool.item_flags & ABSTRACT), "The fallen item kept its arm flags")
	TEST_ASSERT(QDELETED(pseudo), "The pseudopart stayed after the item fell off")

	// a secured arm stays on
	pseudo = patient.make_item_prosthetic(tool, BODY_ZONE_R_ARM, 100)
	var/datum/component/item_as_prosthetic_limb/prosthetic = pseudo.GetComponent(/datum/component/item_as_prosthetic_limb)
	prosthetic.secure()
	tool.attack(victim, patient)
	TEST_ASSERT(patient.get_bodypart(BODY_ZONE_R_ARM) == pseudo, "The secured item arm fell off")

	// deleting the item takes the arm
	qdel(tool)
	TEST_ASSERT(!patient.get_bodypart(BODY_ZONE_R_ARM), "The arm stayed after its item was deleted")

	// an item without an inhand sprite is drawn from its own icon, and the human arm is hidden
	var/obj/item/food/pizzaslice/margherita/pizza = allocate(/obj/item/food/pizzaslice/margherita)
	pseudo = patient.make_item_prosthetic(pizza, BODY_ZONE_R_ARM, 0)
	TEST_ASSERT(!length(pseudo.get_limb_icon()), "The human arm is still drawn under the item arm")
	var/mutable_appearance/inhand = pizza.build_worn_icon(HANDS_LAYER, pizza.righthand_file, TRUE)
	TEST_ASSERT(inhand?.icon_state == "arm" && ("arm" in icon_states(inhand.icon)), "The pizza arm has no fallback sprite")

/// AQUILA - tgstation#98023: an opened chest exposes the organs until the operations close it
/datum/unit_test/aquila_exposed_organs

/datum/unit_test/aquila_exposed_organs/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)

	chest.add_surgical_state(SURGERY_SKIN_CUT|SURGERY_SKIN_OPEN) // skin open, the bone not sawed yet
	TEST_ASSERT(!length(patient.exposed_organ_zones), "Organs got exposed before the bone was sawed")

	chest.add_surgical_state(SURGERY_BONE_SAWED)
	TEST_ASSERT(BODY_ZONE_CHEST in patient.exposed_organ_zones, "Sawed chest does not expose the organs")
	TEST_ASSERT(patient.alerts[ALERT_EXPOSED_ORGANS], "No exposed organs alert")

	chest.remove_surgical_state(SURGERY_SKIN_CUT|SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED)
	TEST_ASSERT(!length(patient.exposed_organ_zones), "Organs stayed exposed after the chest was closed")
	TEST_ASSERT(!patient.alerts[ALERT_EXPOSED_ORGANS], "Exposed organs alert stayed after the chest was closed")

	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	arm.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED)
	TEST_ASSERT(!length(patient.exposed_organ_zones), "An opened arm exposed the organs")
	arm.remove_surgical_state(SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED)

/// AQUILA - tgstation#94761: every SDSM-35 entry is filled in and every phobia has a page
/datum/unit_test/aquila_sdsm_book

/datum/unit_test/aquila_sdsm_book/Run()
	var/obj/item/tgui_book/manual/dsm/book = allocate(/obj/item/tgui_book/manual/dsm)
	for(var/list/entry as anything in book.build_dsm_entries())
		for(var/field in list("full_name", "scan_name", "desc", "symptoms", "id"))
			TEST_ASSERT(length(entry[field]), "SDSM-35 entry [entry["id"]] has no [field]")
	var/list/phobias = book.dsm_phobia_texts()
	for(var/phobia_type in SStraumas.phobia_types)
		TEST_ASSERT(phobias[phobia_type], "SDSM-35 has no page for the [phobia_type] phobia")

/// AQUILA - station mapping: 1 to 3 rooms, done only after the last one is scanned, no reward
/datum/unit_test/aquila_mapping_objective

/datum/unit_test/aquila_mapping_objective/Run()
	var/datum/objective/plant_device/mapping/mapping = new
	for(var/i in 1 to 20)
		if(mapping.pick_target_areas())
			TEST_ASSERT(length(mapping.target_areas) >= 1 && length(mapping.target_areas) <= 3, "Picked [length(mapping.target_areas)] rooms")
	var/list/rooms = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		rooms += A
		if(length(rooms) == 2)
			break
	mapping.target_areas = rooms.Copy()
	mapping.department_name = "test"
	mapping.update_explanation_text()
	TEST_ASSERT(mapping.is_target_area(rooms[1]), "Unscanned room is not a target")
	TEST_ASSERT(!mapping.room_scanned(rooms[1]), "The objective finished after the first of two rooms")
	TEST_ASSERT(!mapping.is_target_area(rooms[1]), "A scanned room is still a target")
	TEST_ASSERT(!mapping.check_completion(), "The objective is complete with a room left")
	TEST_ASSERT(mapping.room_scanned(rooms[2]), "The objective did not finish after the last room")
	TEST_ASSERT(mapping.check_completion(), "The objective is not complete after every room was scanned")
	qdel(mapping)

#undef TEST_ASSERT
