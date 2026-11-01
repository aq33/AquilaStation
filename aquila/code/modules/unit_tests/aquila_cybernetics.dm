// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - Monkestation cybernetics: leg implants work only as a pair, arm sets and muscle implants use their own slots
/datum/unit_test/aquila_cybernetics

/datum/unit_test/aquila_cybernetics/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	// Leg slots follow the zone, a screwdriver swaps the side
	var/obj/item/organ/cyberimp/leg/trait/table_glider/right = allocate(/obj/item/organ/cyberimp/leg/trait/table_glider)
	var/obj/item/organ/cyberimp/leg/trait/table_glider/left = allocate(/obj/item/organ/cyberimp/leg/trait/table_glider)
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver)
	TEST_ASSERT_EQUAL(right.slot, ORGAN_SLOT_RIGHT_LEG_AUG, "A right leg implant is not in the right leg slot")
	left.screwdriver_act(patient, screwdriver)
	TEST_ASSERT_EQUAL(left.zone, BODY_ZONE_L_LEG, "The screwdriver did not move the implant to the left leg")
	TEST_ASSERT_EQUAL(left.slot, ORGAN_SLOT_LEFT_LEG_AUG, "The screwdriver did not change the slot")

	// One leg does nothing, both legs give the trait, removing either takes it away
	right.Insert(patient)
	TEST_ASSERT(patient.getorganslot(ORGAN_SLOT_RIGHT_LEG_AUG) == right, "The right leg implant was not inserted")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_FAST_CLIMBER), "A single leg implant already works")
	left.Insert(patient)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_FAST_CLIMBER), "A full pair of leg implants does not work")
	right.Remove(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_FAST_CLIMBER), "The trait stayed after the right implant was removed")
	TEST_ASSERT(!left.pair_active, "The left implant still thinks it is in a pair")
	right.Insert(patient)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_FAST_CLIMBER), "Putting the implant back did not restore the pair")
	left.Remove(patient)
	right.Remove(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_FAST_CLIMBER), "The trait stayed after both implants were removed")

	// Leg implants go in with the organ manipulation on the leg (the new skeleton reaches organs by zone)
	var/datum/surgery_operation/limb/organ_manipulation/internal/manip = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/organ_manipulation/internal]
	TEST_ASSERT(manip.is_insert_available(patient.get_bodypart(BODY_ZONE_L_LEG), left, BODY_ZONE_L_LEG), "Organ manipulation cannot reach the legs")

	// Arm sets build their tools, Strong-Arm takes the muscle slot and does not block the toolset
	var/obj/item/organ/cyberimp/arm/cook/cook = allocate(/obj/item/organ/cyberimp/arm/cook)
	TEST_ASSERT_EQUAL(length(cook.items_list), 3, "The kitchen implant has the wrong tools")
	cook.Insert(patient)
	var/obj/item/organ/cyberimp/arm/strongarm/strong_right = allocate(/obj/item/organ/cyberimp/arm/strongarm)
	var/obj/item/organ/cyberimp/arm/strongarm/l/strong_left = allocate(/obj/item/organ/cyberimp/arm/strongarm/l)
	strong_right.Insert(patient)
	strong_left.Insert(patient)
	TEST_ASSERT(patient.getorganslot(ORGAN_SLOT_RIGHT_ARM_AUG) == cook, "Strong-Arm replaced the arm toolset")
	TEST_ASSERT(strong_right.has_working_pair(patient), "Two Strong-Arms are not counted as a pair")
	strong_left.Remove(patient)
	TEST_ASSERT(!strong_right.has_working_pair(patient), "One Strong-Arm still counts as a pair")

	// S.M.A.R.T. follows the gun held in the implanted hand and counts its shots
	var/obj/item/organ/cyberimp/arm/ammo_counter/l/counter_implant = allocate(/obj/item/organ/cyberimp/arm/ammo_counter/l)
	counter_implant.Insert(patient)
	var/obj/item/gun/ballistic/automatic/pistol/pistol = allocate(/obj/item/gun/ballistic/automatic/pistol)
	patient.put_in_l_hand(pistol)
	TEST_ASSERT_EQUAL(counter_implant.our_gun, pistol, "The ammo counter did not pick up the gun in the implanted hand")
	TEST_ASSERT_EQUAL(counter_implant.shots_left(), pistol.get_ammo(TRUE), "The ammo counter shows the wrong number of shots")
	patient.dropItemToGround(pistol)
	TEST_ASSERT(isnull(counter_implant.our_gun), "The ammo counter still tracks a dropped gun")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
